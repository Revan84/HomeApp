import 'package:http/http.dart' as http;

import '../../../domain/entities/cob_led_cct_device.dart';
import '../../integrations/cob_led_cct/data/api_client.dart';

class HomeCctHandler {
  final http.Client _httpClient;
  final void Function() _notify;

  // Why: API client is stateless and IP-agnostic — keep one instance instead
  // of allocating a new one on every call site.
  late final CobLedCctApiClient _api = CobLedCctApiClient(_httpClient);

  HomeCctHandler({required http.Client httpClient, required void Function() notify})
      : _httpClient = httpClient,
        _notify = notify;

  final Map<String, CctDeviceState> _states = {};

  CctDeviceState? stateFor(String id) => _states[id];

  Future<void> fetchStates(Iterable<CobLedCctDevice> devices) async {
    for (final device in devices) {
      try {
        final state = await _api.getState(device.ipAddress);
        if (state != null) _states[device.id] = state;
      } catch (_) {}
    }
    _notify();
  }

  Future<void> toggle(CobLedCctDevice device) async {
    final current = _states[device.id] ?? CctDeviceState.defaultState;
    final newOn = !current.isOn;
    _states[device.id] = current.copyWith(isOn: newOn);
    _notify();
    try {
      await _api.setOn(device.ipAddress, on: newOn);
    } catch (_) {
      _states[device.id] = current.copyWith(isOn: current.isOn);
      _notify();
    }
  }

  Future<void> setBrightness(CobLedCctDevice device, double value) async {
    final bri = (value * 255).round().clamp(1, 255);
    final current = _states[device.id] ?? CctDeviceState.defaultState;
    _states[device.id] = current.copyWith(brightness: bri);
    _notify();
    try {
      await _api.setBrightness(device.ipAddress, bri);
    } catch (_) {}
  }

  /// Steps the effect speed up or down by ~12% (30/255).
  Future<void> stepSpeed(CobLedCctDevice device, {required bool up}) async {
    const step = 30;
    final current = _states[device.id] ?? CctDeviceState.defaultState;
    final next = (current.effectSpeed + (up ? step : -step)).clamp(0, 255);
    _states[device.id] = current.copyWith(effectSpeed: next);
    _notify();
    try {
      await _api.setEffect(device.ipAddress, current.effectId, speed: next);
    } catch (_) {}
  }
}
