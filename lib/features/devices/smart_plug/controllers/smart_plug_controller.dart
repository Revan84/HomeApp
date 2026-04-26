import '../../../../core/device/base_equipment_controller.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../data/mappers/equipment_mapper.dart';
import '../../../../domain/entities/equipment.dart';
import '../../../../domain/entities/history_window.dart';
import '../../../../domain/entities/plug_alert.dart';
import '../../../live/controllers/live_polling_controller.dart';

class SmartPlugController extends BaseEquipmentController {
  final LivePollingController _live;
  final LocalStorage _storage;
  List<PlugAlert> _alerts = const [];

  SmartPlugController({
    required super.equipment,
    required super.equipmentRepo,
    required super.roomRepo,
    required LivePollingController live,
    required LocalStorage storage,
  })  : _live = live,
        _storage = storage {
    Future.microtask(_init);
  }

  List<PlugAlert> get alerts => List.unmodifiable(_alerts);

  // ── Init ─────────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    _live.syncFollowed([equipment.toEndpoint()], forcePollNow: true);
    await Future.wait([
      loadRooms(),
      _loadAlerts(),
    ]);
    notify();
  }

  // ── Energy helpers ────────────────────────────────────────────────────────────

  /// Estimates energy consumed today (Wh) via trapezoidal integration of the
  /// last-24 h history. Returns 0 when there are fewer than 2 data points.
  double get todayEnergyWh {
    final points = _live.historyFor(equipment.id, HistoryWindow.d1);
    return _computeTodayEnergyWh(points);
  }

  static double _computeTodayEnergyWh(List<dynamic> points) {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    final today = points
        .where((p) => !(p.at as DateTime).isBefore(midnight))
        .toList()
      ..sort((a, b) => (a.at as DateTime).compareTo(b.at as DateTime));

    if (today.length < 2) return 0;

    double energyWh = 0;
    for (int i = 1; i < today.length; i++) {
      final dt = (today[i].at as DateTime)
              .difference(today[i - 1].at as DateTime)
              .inSeconds /
          3600.0;
      final avgPower =
          ((today[i].powerW as double) + (today[i - 1].powerW as double)) / 2;
      energyWh += avgPower * dt;
    }
    return energyWh;
  }

  // ── Live ─────────────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    await _live.pollDeviceNow(equipment.toEndpoint());
  }

  Future<void> toggle() async {
    await _live.toggle(equipment.toEndpoint());
  }

  // ── Equipment fields ─────────────────────────────────────────────────────────

  Future<void> updateIp(String ip) =>
      persistEquipment(equipment.copyWith(ip: ip));

  Future<void> updateType(EquipmentType type) =>
      persistEquipment(equipment.copyWith(type: type));

  Future<void> delete() async {
    await deleteFromRepo();
    _live.unfollowDevice(equipment.id);
    await _live.deleteHistoryForDevice(equipment.id);
    await _storage.remove(StorageKeys.plugAlerts(equipment.id));
  }

  // ── Alerts ───────────────────────────────────────────────────────────────────

  Future<void> _loadAlerts() async {
    try {
      final raw =
          await _storage.getString(StorageKeys.plugAlerts(equipment.id));
      _alerts = raw != null ? PlugAlert.listFromJson(raw) : const [];
    } catch (_) {
      _alerts = const [];
    }
  }

  Future<void> _saveAlerts() async {
    await _storage.setString(
      StorageKeys.plugAlerts(equipment.id),
      PlugAlert.listToJson(_alerts),
    );
  }

  Future<void> addAlert(PlugAlert alert) async {
    _alerts = [..._alerts, alert];
    await _saveAlerts();
    notify();
  }

  Future<void> deleteAlert(String alertId) async {
    _alerts = _alerts.where((a) => a.id != alertId).toList();
    await _saveAlerts();
    notify();
  }

  Future<void> toggleAlert(String alertId) async {
    _alerts = _alerts
        .map((a) => a.id == alertId ? a.copyWith(isEnabled: !a.isEnabled) : a)
        .toList();
    await _saveAlerts();
    notify();
  }
}
