import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../domain/models/device_endpoint.dart';
import '../../../domain/models/live_state.dart';
import '../../../domain/repositories/live_device_repository.dart';
import '../domain/live_polling_config.dart';

class LivePollingController extends ChangeNotifier {
  final LiveDeviceRepository _repo;
  final LivePollingConfig _config;

  LivePollingController(this._repo, this._config);

  final Map<String, LiveState> live = {};
  final Map<String, bool> _inFlight = {};

  final List<DeviceEndpoint> _followed = [];

  Timer? _tick;

  void start() {
    _tick?.cancel();
    _tick = Timer.periodic(_config.tickPeriod, (_) => pollTick());
  }

  void stop() => _tick?.cancel();

  void syncFollowed(Iterable<DeviceEndpoint> endpoints, {bool forcePollNow = true}) {
    _followed
      ..clear()
      ..addAll(endpoints);

    final ids = _followed.map((e) => e.deviceId).toSet();

    for (final ep in _followed) {
      live.putIfAbsent(
        ep.deviceId,
        () => LiveState(
          online: false,
          nextPollAt: DateTime.fromMillisecondsSinceEpoch(0),
          failCount: 0,
          toggling: false,
        ),
      );

      if (forcePollNow) {
        live[ep.deviceId] = live[ep.deviceId]!.copyWith(nextPollAt: DateTime.now());
      }
    }

    live.removeWhere((id, _) => !ids.contains(id));
    notifyListeners();
  }

  Future<void> pollTick() async {
    if (_followed.isEmpty) return;

    final now = DateTime.now();
    var budget = _config.budget;

    for (final ep in _followed) {
      if (budget <= 0) break;

      final st = live[ep.deviceId];
      if (st == null) continue;
      if (st.toggling) continue;
      if (_inFlight[ep.deviceId] == true) continue;
      if (st.nextPollAt.isAfter(now)) continue;

      budget--;
      _inFlight[ep.deviceId] = true;

      try {
        final next = await _repo.fetch(ep, st);

        final nextPoll = next.online
            ? DateTime.now().add(_config.okInterval)
            : DateTime.now().add(next.backoff);

        live[ep.deviceId] = next.copyWith(nextPollAt: nextPoll);
      } finally {
        _inFlight[ep.deviceId] = false;
      }
    }

    notifyListeners();
  }

  Future<void> toggle(DeviceEndpoint ep) async {
    final st = live[ep.deviceId];
    if (st == null) return;
    if (!st.online || st.toggling) return;

    live[ep.deviceId] = st.copyWith(toggling: true);
    notifyListeners();

    final target = !(st.output == true);

    try {
      await _repo.setOutput(ep, target);
      // poll ASAP
      live[ep.deviceId] = live[ep.deviceId]!.copyWith(nextPollAt: DateTime.now());
    } finally {
      live[ep.deviceId] = live[ep.deviceId]!.copyWith(toggling: false);
      notifyListeners();
    }
  }
}
