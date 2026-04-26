import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../devices/cob_led_rgb/domain/rgb_color.dart';

/// Live state of a WLED device, fetched from the JSON API.
class CobLedRgbState {
  final bool isOn;
  final int brightness;       // 0–255
  final RgbColor primaryColor;
  final int effectId;
  final int effectSpeed;      // 0–255
  final int effectIntensity;  // 0–255
  final int presetId;         // -1 = no preset
  final bool audioReactive;

  const CobLedRgbState({
    required this.isOn,
    required this.brightness,
    required this.primaryColor,
    required this.effectId,
    required this.effectSpeed,
    required this.effectIntensity,
    required this.presetId,
    this.audioReactive = false,
  });

  CobLedRgbState copyWith({
    bool? isOn,
    int? brightness,
    RgbColor? primaryColor,
    int? effectId,
    int? effectSpeed,
    int? effectIntensity,
    int? presetId,
    bool? audioReactive,
  }) =>
      CobLedRgbState(
        isOn: isOn ?? this.isOn,
        brightness: brightness ?? this.brightness,
        primaryColor: primaryColor ?? this.primaryColor,
        effectId: effectId ?? this.effectId,
        effectSpeed: effectSpeed ?? this.effectSpeed,
        effectIntensity: effectIntensity ?? this.effectIntensity,
        presetId: presetId ?? this.presetId,
        audioReactive: audioReactive ?? this.audioReactive,
      );

  factory CobLedRgbState.fromJson(Map<String, dynamic> json) {
    final segs = json['seg'] as List<dynamic>? ?? [];
    final seg = segs.isNotEmpty ? segs.first as Map<String, dynamic> : {};

    RgbColor color = const RgbColor(red: 255, green: 255, blue: 255);
    final cols = seg['col'] as List<dynamic>?;
    if (cols != null && cols.isNotEmpty) {
      final c = cols.first;
      if (c is List && c.length >= 3) {
        color = RgbColor(
          red: (c[0] as num).toInt(),
          green: (c[1] as num).toInt(),
          blue: (c[2] as num).toInt(),
        );
      }
    }

    return CobLedRgbState(
      isOn: (json['on'] as bool?) ?? false,
      brightness: (json['bri'] as num?)?.toInt() ?? 128,
      primaryColor: color,
      effectId: (seg['fx'] as num?)?.toInt() ?? 0,
      effectSpeed: (seg['sx'] as num?)?.toInt() ?? 128,
      effectIntensity: (seg['ix'] as num?)?.toInt() ?? 128,
      presetId: (json['ps'] as num?)?.toInt() ?? -1,
      audioReactive: ((json['audio'] as Map?))?['on'] as bool? ?? false,
    );
  }

  static CobLedRgbState get defaultState => const CobLedRgbState(
        isOn: true,
        brightness: 128,
        primaryColor: RgbColor(red: 255, green: 255, blue: 255),
        effectId: 0,
        effectSpeed: 128,
        effectIntensity: 128,
        presetId: -1,
      );
}

/// A WLED preset (scene).
class CobLedRgbPreset {
  final int id;
  final String name;

  const CobLedRgbPreset({required this.id, required this.name});
}

/// HTTP client for the WLED JSON API (port 80).
class CobLedRgbApiClient {
  final http.Client _http;
  static const _timeout = Duration(seconds: 4);

  CobLedRgbApiClient(this._http);

  Uri _url(String ip, String path) =>
      Uri.parse('http://$ip$path');

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  /// Fetches the current WLED state.
  Future<CobLedRgbState?> getState(String ip) async {
    try {
      final res = await _http
          .get(_url(ip, '/json/state'))
          .timeout(_timeout);
      if (res.statusCode != 200) return null;
      return CobLedRgbState.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Fetches the list of effect names.
  Future<List<String>> getEffects(String ip) async {
    try {
      final res = await _http
          .get(_url(ip, '/json/effects'))
          .timeout(_timeout);
      if (res.statusCode != 200) return [];
      final list = jsonDecode(res.body) as List<dynamic>;
      return list.cast<String>();
    } catch (_) {
      return [];
    }
  }

  /// Fetches saved presets / scenes.
  Future<List<CobLedRgbPreset>> getPresets(String ip) async {
    try {
      final res = await _http
          .get(_url(ip, '/json/presets'))
          .timeout(_timeout);
      if (res.statusCode != 200) return [];
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final presets = <CobLedRgbPreset>[];
      map.forEach((key, value) {
        final id = int.tryParse(key);
        if (id == null || id == 0) return; // 0 = emergency preset, skip
        final name = (value as Map<String, dynamic>)['n'] as String? ?? 'Preset $id';
        presets.add(CobLedRgbPreset(id: id, name: name));
      });
      presets.sort((a, b) => a.id.compareTo(b.id));
      return presets;
    } catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  /// Sends a partial state update to the device.
  Future<bool> patchState(String ip, Map<String, dynamic> body) async {
    try {
      final res = await _http
          .post(
            _url(ip, '/json/state'),
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

  Future<void> setColor(String ip, RgbColor color) =>
      patchState(ip, {
        'seg': [
          {
            'id': 0,
            'col': [
              [
                color.red,
                color.green,
                color.blue,
              ]
            ],
          }
        ],
      });

  Future<void> setEffect(String ip, int effectId,
          {int speed = 128, int intensity = 128}) =>
      patchState(ip, {
        'seg': [
          {'id': 0, 'fx': effectId, 'sx': speed, 'ix': intensity},
        ],
      });

  Future<void> loadPreset(String ip, int presetId) =>
      patchState(ip, {'ps': presetId});

  Future<void> setAudio(String ip, {required bool enabled}) =>
      patchState(ip, {
        'audio': {'on': enabled},
      });

  // ---------------------------------------------------------------------------
  // Utility
  // ---------------------------------------------------------------------------

  /// Returns true if the device responds to a basic ping.
  Future<bool> testConnection(String ip) async {
    try {
      final res = await _http
          .get(_url(ip, '/json/info'))
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
