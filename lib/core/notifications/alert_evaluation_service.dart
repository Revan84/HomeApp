import 'dart:async';

import '../../core/storage/local_storage.dart';
import '../../core/storage/storage_keys.dart';
import '../../domain/entities/plug_alert.dart';
import '../../domain/entities/sensor_alert.dart';
import '../../features/live/controllers/live_polling_controller.dart';
import 'notification_service.dart';

// ── Event ─────────────────────────────────────────────────────────────────────

/// Emitted when an alert fires with the [banner] notification type selected.
/// The UI layer subscribes to [AlertEvaluationService.bannerStream] and shows
/// an in-app banner.
class AlertBannerEvent {
  final String title;
  final String body;

  const AlertBannerEvent({required this.title, required this.body});
}

// ── Service ───────────────────────────────────────────────────────────────────

/// Listens to [LivePollingController] and evaluates every configured alert
/// after each poll cycle.
///
/// • Push alerts  → [NotificationService.showPush]
/// • Banner alerts → [bannerStream] (consumed by [AppShell])
///
/// Alert thresholds are re-loaded from [LocalStorage] every
/// [_cacheLifetime] so that newly-added alerts are picked up without
/// requiring an app restart.
///
/// A per-alert [_cooldown] prevents the same alert from firing more than
/// once every 5 minutes.
class AlertEvaluationService {
  AlertEvaluationService({
    required LivePollingController live,
    required LocalStorage storage,
  })  : _live = live,
        _storage = storage {
    _live.addListener(_onLiveUpdate);
  }

  final LivePollingController _live;
  final LocalStorage _storage;

  // ── Cache ─────────────────────────────────────────────────────────────────

  final Map<String, List<PlugAlert>> _plugAlerts = {};
  final Map<String, List<SensorAlert>> _sensorAlerts = {};
  DateTime _lastCacheReset = DateTime.fromMillisecondsSinceEpoch(0);

  static const _cacheLifetime = Duration(seconds: 60);

  // ── Cooldown ──────────────────────────────────────────────────────────────

  /// alertId → last time it fired
  final Map<String, DateTime> _lastFired = {};
  static const _cooldown = Duration(minutes: 5);

  // ── Banner stream ─────────────────────────────────────────────────────────

  final _bannerCtrl = StreamController<AlertBannerEvent>.broadcast();

  /// Subscribe to this stream to receive in-app banner events.
  Stream<AlertBannerEvent> get bannerStream => _bannerCtrl.stream;

  // ── Constants ─────────────────────────────────────────────────────────────

  static const _defaultKwhPrice = 0.20;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  void dispose() {
    _live.removeListener(_onLiveUpdate);
    _bannerCtrl.close();
  }

  // ── Core ──────────────────────────────────────────────────────────────────

  Future<void> _onLiveUpdate() async {
    // Periodically flush cache so new/removed alerts are picked up.
    if (DateTime.now().difference(_lastCacheReset) > _cacheLifetime) {
      _plugAlerts.clear();
      _sensorAlerts.clear();
      _lastCacheReset = DateTime.now();
    }

    for (final entry in _live.live.entries) {
      final deviceId = entry.key;
      final state = entry.value;

      // Only evaluate devices that are actively reporting data.
      if (!state.online) continue;

      await _loadAlertsIfNeeded(deviceId);
      _evaluatePlugAlerts(deviceId, state);
      _evaluateSensorAlerts(deviceId, state);
    }
  }

  Future<void> _loadAlertsIfNeeded(String deviceId) async {
    if (!_plugAlerts.containsKey(deviceId)) {
      final raw = await _storage.getString(StorageKeys.plugAlerts(deviceId));
      _plugAlerts[deviceId] = (raw != null && raw.isNotEmpty)
          ? _tryParse(() => PlugAlert.listFromJson(raw)) ?? []
          : [];
    }

    if (!_sensorAlerts.containsKey(deviceId)) {
      final raw = await _storage.getString(StorageKeys.sensorAlerts(deviceId));
      _sensorAlerts[deviceId] = (raw != null && raw.isNotEmpty)
          ? _tryParse(() => SensorAlert.listFromJson(raw)) ?? []
          : [];
    }
  }

  // ── Plug alerts ───────────────────────────────────────────────────────────

  Future<void> _evaluatePlugAlerts(String deviceId, liveState) async {
    final alerts = _plugAlerts[deviceId];
    if (alerts == null || alerts.isEmpty) return;

    final watts = liveState.powerW?.toDouble();
    if (watts == null) return;

    // Lazy-load kWh price only when needed.
    double? cachedPrice;
    Future<double> kwhPrice() async {
      if (cachedPrice != null) return cachedPrice!;
      final s = await _storage.getString(StorageKeys.kwhPrice);
      cachedPrice = (s != null ? double.tryParse(s) : null) ?? _defaultKwhPrice;
      return cachedPrice!;
    }

    for (final alert in alerts) {
      if (!alert.isEnabled) continue;
      if (_isInCooldown(alert.id)) continue;

      bool triggered = false;
      String currentVal = '';

      switch (alert.condition) {
        case PlugAlertCondition.wattsExceeded:
          if (watts > alert.threshold) {
            triggered = true;
            currentVal = '${watts.toStringAsFixed(0)} W';
          }
        case PlugAlertCondition.dailyCostExceeded:
          final price = await kwhPrice();
          final dailyCost = watts * 24 / 1000 * price;
          if (dailyCost > alert.threshold) {
            triggered = true;
            currentVal = '${dailyCost.toStringAsFixed(2)} €/day';
          }
      }

      if (triggered) {
        final condLabel = switch (alert.condition) {
          PlugAlertCondition.wattsExceeded =>
            'Power exceeded ${alert.threshold.toStringAsFixed(0)} W',
          PlugAlertCondition.dailyCostExceeded =>
            'Daily cost exceeded ${alert.threshold.toStringAsFixed(2)} €',
        };
        _fire(
          alertId: alert.id,
          notifications: _plugNotifNames(alert.notifications),
          title: 'Device Alert',
          body: '$condLabel (currently $currentVal)',
        );
      }
    }
  }

  // ── Sensor alerts ─────────────────────────────────────────────────────────

  void _evaluateSensorAlerts(String deviceId, liveState) {
    final alerts = _sensorAlerts[deviceId];
    if (alerts == null || alerts.isEmpty) return;

    for (final alert in alerts) {
      if (!alert.isEnabled) continue;
      if (_isInCooldown(alert.id)) continue;

      final double? value =
          alert.isHumidity ? liveState.humidity : liveState.temperatureC;
      if (value == null) continue;

      final triggered = switch (alert.condition) {
        SensorAlertCondition.above => value > alert.threshold,
        SensorAlertCondition.below => value < alert.threshold,
      };

      if (triggered) {
        final unit = alert.isHumidity ? '%' : '°C';
        final cond =
            alert.condition == SensorAlertCondition.above ? 'above' : 'below';
        final threshStr =
            alert.threshold.toStringAsFixed(alert.threshold == alert.threshold.truncateToDouble() ? 0 : 1);
        final valStr =
            value.toStringAsFixed(value == value.truncateToDouble() ? 0 : 1);
        _fire(
          alertId: alert.id,
          notifications: _sensorNotifNames(alert.notifications),
          title: 'Sensor Alert',
          body: 'Value $valStr $unit is $cond threshold $threshStr $unit',
        );
      }
    }
  }

  // ── Fire ──────────────────────────────────────────────────────────────────

  void _fire({
    required String alertId,
    required Set<String> notifications,
    required String title,
    required String body,
  }) {
    _lastFired[alertId] = DateTime.now();

    if (notifications.contains('push')) {
      NotificationService.showPush(title: title, body: body);
    }

    if (notifications.contains('banner') && !_bannerCtrl.isClosed) {
      _bannerCtrl.add(AlertBannerEvent(title: title, body: body));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _isInCooldown(String alertId) {
    final last = _lastFired[alertId];
    return last != null && DateTime.now().difference(last) < _cooldown;
  }

  Set<String> _plugNotifNames(Set<PlugAlertNotification> s) =>
      s.map((n) => n.name).toSet();

  Set<String> _sensorNotifNames(Set<SensorAlertNotification> s) =>
      s.map((n) => n.name).toSet();

  T? _tryParse<T>(T Function() fn) {
    try {
      return fn();
    } catch (_) {
      return null;
    }
  }
}
