import 'dart:convert';

import 'package:http/http.dart' as http;

/// Live state of a COB LED CCT controller device.
class CctDeviceState {
  final bool isOn;
  final int brightness;    // 0–255
  final int colorTempK;    // 2700–6500 K
  final int effectId;      // 0 = Static
  final int effectSpeed;   // 0–255
  final bool audioReactive;

  const CctDeviceState({
    required this.isOn,
    required this.brightness,
    required this.colorTempK,
    this.effectId = 0,
    this.effectSpeed = 128,
    this.audioReactive = false,
  });

  CctDeviceState copyWith({
    bool? isOn,
    int? brightness,
    int? colorTempK,
    int? effectId,
    int? effectSpeed,
    bool? audioReactive,
  }) =>
      CctDeviceState(
        isOn: isOn ?? this.isOn,
        brightness: brightness ?? this.brightness,
        colorTempK: colorTempK ?? this.colorTempK,
        effectId: effectId ?? this.effectId,
        effectSpeed: effectSpeed ?? this.effectSpeed,
        audioReactive: audioReactive ?? this.audioReactive,
      );

  factory CctDeviceState.fromJson(Map<String, dynamic> json) {
    final seg = ((json['seg'] as List<dynamic>?)?.isNotEmpty == true
        ? (json['seg'] as List<dynamic>).first as Map<String, dynamic>
        : null);
    return CctDeviceState(
      isOn: (json['on'] as bool?) ?? false,
      brightness: (json['bri'] as num?)?.toInt() ?? 200,
      colorTempK: (json['ct'] as num?)?.toInt() ?? 3000,
      effectId: (seg?['fx'] as num?)?.toInt() ?? 0,
      effectSpeed: (seg?['sx'] as num?)?.toInt() ?? 128,
      audioReactive: ((json['audio'] as Map?))?['on'] as bool? ?? false,
    );
  }

  static CctDeviceState get defaultState => const CctDeviceState(
        isOn: true,
        brightness: 200,
        colorTempK: 3000,
      );
}

/// HTTP client for a COB LED CCT controller.
class CobLedCctApiClient {
  final http.Client _http;
  static const _timeout = Duration(seconds: 4);

  CobLedCctApiClient(this._http);

  Uri _url(String ip, String path) => Uri.parse('http://$ip$path');

  // ── Read ────────────────────────────────────────────────────────────────────

  Future<CctDeviceState?> getState(String ip) async {
    try {
      final res = await _http.get(_url(ip, '/state')).timeout(_timeout);
      if (res.statusCode != 200) return null;
      return CctDeviceState.fromJson(
        jsonDecode(res.body) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> getEffects(String ip) async {
    try {
      final res = await _http
          .get(_url(ip, '/json/effects'))
          .timeout(_timeout);
      if (res.statusCode != 200) return _defaultEffects;
      return (jsonDecode(res.body) as List<dynamic>).cast<String>();
    } catch (_) {
      return _defaultEffects;
    }
  }

  // ── Write ───────────────────────────────────────────────────────────────────

  Future<bool> patchState(String ip, Map<String, dynamic> body) async {
    try {
      final res = await _http
          .post(
            _url(ip, '/state'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> setOn(String ip, {required bool on}) =>
      patchState(ip, {'on': on});

  Future<void> setBrightness(String ip, int bri) =>
      patchState(ip, {'bri': bri.clamp(0, 255)});

  Future<void> setColorTemp(String ip, int ct) =>
      patchState(ip, {'ct': ct.clamp(2700, 6500)});

  Future<void> setEffect(String ip, int effectId, {int speed = 128}) =>
      patchState(ip, {
        'seg': [
          {'id': 0, 'fx': effectId, 'sx': speed},
        ],
      });

  Future<void> setAudio(String ip, {required bool enabled}) =>
      patchState(ip, {
        'audio': {'on': enabled},
      });

  // ── Utility ─────────────────────────────────────────────────────────────────

  Future<bool> testConnection(String ip) async {
    try {
      final res = await _http.get(_url(ip, '/state')).timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Defaults ────────────────────────────────────────────────────────────────

  static const List<String> _defaultEffects = [
    'Static',
    'Blink',
    'Breathe',
    'Wipe',
    'Fade',
    'Chase',
    'Twinkle',
    'Strobe',
  ];
}
