import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/device_endpoint.dart';
import '../../../domain/entities/history_window.dart';
import '../../../domain/entities/live_point.dart';
import '../../../domain/entities/live_state.dart';
import '../../../domain/repositories/live_device_repository.dart';
import '../data/live_point_dto.dart';
import '../data/live_point_mapper.dart';
import '../domain/live_polling_config.dart';

class LivePollingController extends ChangeNotifier {
  LivePollingController(this._repo, this._config);

  final LiveDeviceRepository _repo;
  final LivePollingConfig _config;

  static const String _historyStorageKey = 'live_history_v1';

  /// Higher cap so long ranges remain useful.
  static const int _maxPointsPerDevice = 50000;

  /// Keep enough retained data for long-range charts.
  static const Duration _historyRetention = Duration(days: 400);

  static const Duration _historySaveDebounceDuration =
      Duration(milliseconds: 500);

  /// Public live states by device id.
  final Map<String, LiveState> live = {};

  int get onlineCount => live.values.where((s) => s.online == true).length;
  int get offlineCount => live.values.where((s) => s.online == false).length;

  /// Prevent duplicate concurrent fetches per device.
  final Map<String, bool> _inFlight = {};

  /// Devices currently followed by the UI.
  final List<DeviceEndpoint> _followed = [];

  /// In-memory power history per device.
  final Map<String, List<LivePoint>> _history = {};

  Timer? _tick;
  Timer? _historySaveDebounce;

  bool _polling = false;
  bool _historyLoaded = false;
  bool _disposed = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  void start() {
    _tick?.cancel();

    // Load persisted history before fresh polling appends new points.
    unawaited(loadHistory());

    _tick = Timer.periodic(_config.tickPeriod, (_) {
      unawaited(pollTick());
    });

    // Trigger an immediate polling wave.
    unawaited(pollTick());
  }

  void stop() {
    _tick?.cancel();
    _tick = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _historySaveDebounce?.cancel();
    stop();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Followed devices
  // ---------------------------------------------------------------------------

  void syncFollowed(
    Iterable<DeviceEndpoint> endpoints, {
    bool forcePollNow = true,
  }) {
    _followed
      ..clear()
      ..addAll(endpoints);

    final followedIds = _followed.map((endpoint) => endpoint.deviceId).toSet();
    final now = DateTime.now();

    for (final endpoint in _followed) {
      live.putIfAbsent(
        endpoint.deviceId,
        () => LiveState(
          online: false,
          nextPollAt: DateTime.fromMillisecondsSinceEpoch(0),
          failCount: 0,
          toggling: false,
        ),
      );

      if (forcePollNow) {
        live[endpoint.deviceId] = live[endpoint.deviceId]!.copyWith(
          nextPollAt: now,
        );
      }
    }

    // Keep only transient live states for currently followed devices.
    // Persisted history must stay available even if the screen changes.
    live.removeWhere((deviceId, _) => !followedIds.contains(deviceId));

    notifyListeners();

    if (forcePollNow) {
      unawaited(pollTick());
    }
  }

  /// Removes a single device from live tracking without affecting others.
  void unfollowDevice(String deviceId) {
    _followed.removeWhere((endpoint) => endpoint.deviceId == deviceId);
    _inFlight.remove(deviceId);
    live.remove(deviceId);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // History persistence
  // ---------------------------------------------------------------------------

  Future<void> loadHistory() async {
    if (_historyLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyStorageKey);

      if (raw == null || raw.isEmpty) {
        _historyLoaded = true;
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        _historyLoaded = true;
        return;
      }

      _history.clear();

      decoded.forEach((deviceId, rawPoints) {
        if (rawPoints is! List) return;

        final points = rawPoints
            .map((item) {
              final dto = LivePointDto.tryFromMap(item);
              return dto != null ? LivePointMapper.toDomain(dto) : null;
            })
            .whereType<LivePoint>()
            .toList();

        points.sort((a, b) => a.at.compareTo(b.at));

        if (points.isNotEmpty) {
          _history[deviceId] = _trimHistory(points);
        }
      });
    } catch (_) {
      // Ignore corrupted persisted data and recover with a clean state.
      _history.clear();
    } finally {
      _historyLoaded = true;

      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  void _scheduleHistorySave() {
    _historySaveDebounce?.cancel();
    _historySaveDebounce = Timer(_historySaveDebounceDuration, () {
      unawaited(_saveHistory());
    });
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final encoded = <String, dynamic>{};

      _history.forEach((deviceId, points) {
        encoded[deviceId] = points
            .map((p) => LivePointMapper.fromDomain(p).toMap())
            .toList(growable: false);
      });

      await prefs.setString(_historyStorageKey, jsonEncode(encoded));
    } catch (_) {
      // Persistence failure must not break live polling.
    }
  }

  // ---------------------------------------------------------------------------
  // History
  // ---------------------------------------------------------------------------

  List<LivePoint> historyFor(String deviceId, HistoryWindow window) {
    final list = _history[deviceId];
    if (list == null || list.isEmpty) return const [];

    final sorted = List<LivePoint>.of(list)
      ..sort((a, b) => a.at.compareTo(b.at));

    final end = DateTime.now();

    if (window == HistoryWindow.max) {
      return List<LivePoint>.unmodifiable(sorted);
    }

    final since = window.startDate(
      end: end,
      oldestPointAt: sorted.first.at,
    );

    return sorted
        .where((point) => !point.at.isBefore(since))
        .toList(growable: false);
  }

  void _appendHistoryPoint(String deviceId, double powerW, DateTime at) {
    final list = _history.putIfAbsent(deviceId, () => <LivePoint>[]);

    // Avoid storing almost identical values too often.
    if (list.isNotEmpty) {
      final last = list.last;
      final sameValue = (last.powerW - powerW).abs() < 0.5;
      final tooSoon = at.difference(last.at) < const Duration(seconds: 10);

      if (sameValue && tooSoon) {
        return;
      }
    }

    list.add(LivePoint(at: at, powerW: powerW));

    final trimmed = _trimHistory(list);
    if (!identical(trimmed, list)) {
      _history[deviceId] = trimmed;
    }

    _scheduleHistorySave();
  }

  /// Deletes all persisted and in-memory history for a single device.
  Future<void> deleteHistoryForDevice(String deviceId) async {
    _history.remove(deviceId);
    _scheduleHistorySave();
    notifyListeners();
  }

  List<LivePoint> _trimHistory(List<LivePoint> points) {
    final cutoff = DateTime.now().subtract(_historyRetention);

    final trimmed = points
        .where((point) => !point.at.isBefore(cutoff))
        .toList(growable: true);

    if (trimmed.length > _maxPointsPerDevice) {
      return trimmed.sublist(trimmed.length - _maxPointsPerDevice);
    }

    return trimmed;
  }

  bool _applyLive(String deviceId, LiveState nextState) {
    final previous = live[deviceId];
    live[deviceId] = nextState;

    final power = nextState.powerW;
    if (power != null) {
      _appendHistoryPoint(
        deviceId,
        power.toDouble(),
        nextState.lastUpdatedAt ?? DateTime.now(),
      );
    }

    return previous != nextState;
  }

  // ---------------------------------------------------------------------------
  // Polling
  // ---------------------------------------------------------------------------

  Future<void> pollTick() async {
    if (_followed.isEmpty) return;
    if (_polling) return;

    _polling = true;

    try {
      final now = DateTime.now();
      final followedSnapshot = List<DeviceEndpoint>.of(_followed);

      final dueEndpoints = followedSnapshot.where((endpoint) {
        final state = live[endpoint.deviceId];
        if (state == null) return false;
        if (state.toggling) return false;
        if (_inFlight[endpoint.deviceId] == true) return false;
        if (state.nextPollAt.isAfter(now)) return false;
        return true;
      }).toList(growable: true);

      if (dueEndpoints.isEmpty) return;

      dueEndpoints.sort((a, b) {
        final aNextPoll = live[a.deviceId]?.nextPollAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bNextPoll = live[b.deviceId]?.nextPollAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return aNextPoll.compareTo(bNextPoll);
      });

      final selected =
          dueEndpoints.take(_config.budget).toList(growable: false);

      final results = await Future.wait(selected.map(_pollOne));

      if (results.any((changed) => changed)) {
        notifyListeners();
      }
    } finally {
      _polling = false;
    }
  }

  Future<bool> pollDeviceNow(DeviceEndpoint endpoint) async {
    final state = live[endpoint.deviceId];
    if (state == null) return false;
    if (_inFlight[endpoint.deviceId] == true) return false;

    final changed = await _pollOne(endpoint);
    if (changed) {
      notifyListeners();
    }

    return changed;
  }

  Future<bool> _pollOne(DeviceEndpoint endpoint) async {
    final current = live[endpoint.deviceId];
    if (current == null) return false;

    _inFlight[endpoint.deviceId] = true;

    try {
      final fetched = await _repo.fetch(endpoint, current);

      final nextPollAt = fetched.online
          ? DateTime.now().add(_config.okInterval)
          : DateTime.now().add(fetched.backoff);

      final nextState = fetched.copyWith(
        nextPollAt: nextPollAt,
        trendPower: _computeTrend(current.powerW, fetched.powerW),
      );

      return _applyLive(endpoint.deviceId, nextState);
    } catch (_) {
      // A single polling error must not break the whole polling wave.
      return false;
    } finally {
      _inFlight[endpoint.deviceId] = false;
    }
  }

  int _computeTrend(num? previous, num? next) {
    if (previous == null || next == null) return 0;
    if (next > previous) return 1;
    if (next < previous) return -1;
    return 0;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> toggle(DeviceEndpoint endpoint) async {
    final current = live[endpoint.deviceId];
    if (current == null) return;
    if (current.toggling) return;

    // Do not block the command just because the latest status fetch failed.
    live[endpoint.deviceId] = current.copyWith(toggling: true);
    notifyListeners();

    final targetOutput = !(current.output == true);

    try {
      await _repo.setOutput(endpoint, targetOutput);

      final latest = live[endpoint.deviceId];
      if (latest != null) {
        live[endpoint.deviceId] = latest.copyWith(
          online: true,
          output: targetOutput,
          lastUpdatedAt: DateTime.now(),
          nextPollAt: DateTime.now(),
        );
      }

      // Force an immediate refresh instead of waiting for the next periodic tick.
      await pollDeviceNow(endpoint);
    } finally {
      final latest = live[endpoint.deviceId];
      if (latest != null) {
        live[endpoint.deviceId] = latest.copyWith(toggling: false);
      }
      notifyListeners();
    }
  }
}