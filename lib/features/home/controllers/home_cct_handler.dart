import 'package:http/http.dart' as http;

import '../../../domain/entities/cob_led_cct_device.dart';
import '../../integrations/cob_led_cct/data/cob_led_cct_api_client.dart';

class HomeCctHandler {
  final http.Client _httpClient;
  final void Function() _notify;

  HomeCctHandler({required http.Client httpClient, required void Function() notify})
      : _httpClient = httpClient,
        _notify = notify;

  final Map<String, CctDeviceState> _states = {};

  CctDeviceState? stateFor(String id) => _states[id];

  Future<void> fetchStates(Iterable<CobLedCctDevice> devices) async {
    final api = CobLedCctApiClient(_httpClient);
    for (final device in devices) {
      try {
        final state = await api.getState(device.ipAddress);
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
      await CobLedCctApiClient(_httpClient).setOn(device.ipAddress, on: newOn);
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
      await CobLedCctApiClient(_httpClient).setBrightness(device.ipAddress, bri);
    } catch (_) {}
  }
}
