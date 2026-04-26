import 'package:http/http.dart' as http;

import '../../../domain/entities/cob_led_rgb_device.dart';
import '../../integrations/cob_led_rgb/data/cob_led_rgb_api_client.dart';

class HomeRgbHandler {
  final http.Client _httpClient;
  final void Function() _notify;

  HomeRgbHandler({required http.Client httpClient, required void Function() notify})
      : _httpClient = httpClient,
        _notify = notify;

  final Map<String, CobLedRgbState> _states = {};

  CobLedRgbState? stateFor(String id) => _states[id];

  Future<void> fetchStates(Iterable<CobLedRgbDevice> devices) async {
    final api = CobLedRgbApiClient(_httpClient);
    for (final device in devices) {
      try {
        final state = await api.getState(device.ipAddress);
        if (state != null) _states[device.id] = state;
      } catch (_) {}
    }
    _notify();
  }

  Future<void> toggle(CobLedRgbDevice device) async {
    final currentlyOn = _states[device.id]?.isOn ?? true;
    final newOn = !currentlyOn;
    _states[device.id] =
        (_states[device.id] ?? CobLedRgbState.defaultState).copyWith(isOn: newOn);
    _notify();
    try {
      await CobLedRgbApiClient(_httpClient).setOn(device.ipAddress, on: newOn);
    } catch (_) {
      _states[device.id] = _states[device.id]!.copyWith(isOn: currentlyOn);
      _notify();
    }
  }

  Future<void> setBrightness(CobLedRgbDevice device, double value) async {
    final bri = (value * 255).round().clamp(1, 255);
    _states[device.id] =
        (_states[device.id] ?? CobLedRgbState.defaultState).copyWith(brightness: bri);
    _notify();
    try {
      await CobLedRgbApiClient(_httpClient).setBrightness(device.ipAddress, bri);
    } catch (_) {}
  }
}
