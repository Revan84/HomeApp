import 'dart:convert';

import 'package:http/http.dart' as http;

/// Live state of a COB LED CCT controller device.
class CctDeviceState {
  final bool isOn;
  final int brightness;    // 0–255
  final int colorTempK;    // 2700–6500 K
  final int effectId;      // 0 = Static
  final int effectSpeed;   // 0–255

  const CctDeviceState({
    required this.isOn,
    required this.brightness,
    required this.colorTempK,
    this.effectId = 0,
    this.effectSpeed = 128,
  });

  CctDeviceState copyWith({
    bool? isOn,
    int? brightness,
    int? colorTempK,
    int? effectId,
    int? effectSpeed,
  }) =>
      CctDeviceState(
        isOn: isOn ?? this.isOn,
        brightness: brightness ?? this.brightness,
        colorTempK: colorTempK ?? this.colorTempK,
        effectId: effectId ?? this.effectId,
        effectSpeed: effectSpeed ?? this.effectSpeed,
      );

  factory CctDeviceState.fromJson(Map<String, dynamic> json) {
    final seg = ((json['seg'] as List<dynamic>?)?.isNotEmpty == true
        ? (json['seg'] as List<dynamic>).first as Map<String, dynamic>
        : null);

    // Colour temperature: this device (WLED-SR) stores CCT in seg[0].cct (0–255).
    // Priority: seg CCT → root cct → root ct.
    // If the value is ≥ 2000 we treat it as Kelvin; otherwise convert 0–255.
    final rawCt = (seg?['cct'] as num?)?.toInt() ??
                  (json['cct'] as num?)?.toInt() ??
                  (json['ct']  as num?)?.toInt();
    final colorTempK = rawCt == null
        ? 3000
        : rawCt >= 2000
            ? rawCt.clamp(2700, 6500)                            // already Kelvin
            : (2700 + (rawCt / 255.0) * (6500 - 2700)).round(); // 0–255 → K

    return CctDeviceState(
      isOn: (json['on'] as bool?) ?? false,
      brightness: (json['bri'] as num?)?.toInt() ?? 200,
      colorTempK: colorTempK,
      effectId: (seg?['fx'] as num?)?.toInt() ?? 0,
      effectSpeed: (seg?['sx'] as num?)?.toInt() ?? 128,
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

  // Why: testConnection probes up to 7 paths sequentially; using the same 4 s
  // per-path timeout would block the UI for up to 28 s on a fully unreachable
  // host. 2 s × 7 = 14 s is still high but acceptable for an explicit tap.
  static const _probeTimeout = Duration(seconds: 2);

  CobLedCctApiClient(this._http);

  Uri _url(String ip, String path) => Uri.parse('http://$ip$path');

  // ── Read ────────────────────────────────────────────────────────────────────

  Future<CctDeviceState?> getState(String ip) async {
    // Try /json/state first (standard WLED), then /json root (some firmware
    // returns the full payload there with a nested "state" key).
    for (final path in ['/json/state', '/json']) {
      try {
        final res = await _http.get(_url(ip, path)).timeout(_timeout);
        if (res.statusCode != 200) continue;
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        // /json root wraps state under a "state" key; /json/state is flat.
        final stateMap =
            (body['state'] as Map<String, dynamic>?) ?? body;
        return CctDeviceState.fromJson(stateMap);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  /// Fetches device info from `/json/info` and returns a human-readable model
  /// string such as "ESP32 · WLED 0.14.0" or "ESP8266 · WLED-SR 0.13.3".
  /// Returns null if the endpoint is unreachable or the response is malformed.
  Future<String?> getInfo(String ip) async {
    try {
      final res = await _http
          .get(_url(ip, '/json/info'))
          .timeout(_timeout);
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;

      // Why: capitalise 'esp' prefix for display ('esp32' → 'ESP32').
      final arch = (json['arch'] as String?)?.replaceAll('esp', 'ESP') ?? '';

      // ver: firmware version string
      final ver = (json['ver'] as String?) ?? '';

      // brand: "WLED" / "WLED-SR" / custom
      final brand = (json['brand'] as String?) ?? 'WLED';

      final parts = <String>[
        if (arch.isNotEmpty) arch,
        if (ver.isNotEmpty) '$brand $ver',
      ];
      return parts.isEmpty ? null : parts.join(' · ');
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

  // Why: private — all writes go through the typed helpers below. No external
  // caller posts arbitrary state payloads; keep the JSON shape encapsulated.
  Future<bool> _patchState(String ip, Map<String, dynamic> body) async {
    try {
      // tt: 0 — disable WLED's default 700 ms cross-fade transition so
      // changes feel instantaneous when dragging sliders.
      final payload = {'tt': 0, ...body};
      final res = await _http
          .post(
            _url(ip, '/json/state'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> setOn(String ip, {required bool on}) =>
      _patchState(ip, {'on': on});

  Future<void> setBrightness(String ip, int bri) =>
      _patchState(ip, {'bri': bri.clamp(0, 255)});

  /// Sends the colour temperature to the device covering all known field names
  /// and nesting levels used by different WLED firmware variants:
  ///   • root 'ct'        – standard WLED CCT write field (0–255)
  ///   • root 'cct'       – some custom firmware write field (0–255)
  ///   • seg[0].'cct'     – WLED-SR / newer WLED per-segment CCT (0–255)
  /// Sending all three at once is safe — the device will use whichever it
  /// understands and ignore the rest.
  Future<void> setColorTemp(String ip, int kelvin) {
    final cct = ((kelvin - 2700) / (6500 - 2700) * 255).round().clamp(0, 255);
    return _patchState(ip, {
      'ct': cct,
      'cct': cct,
      'seg': [
        {'id': 0, 'cct': cct},
      ],
    });
  }

  Future<void> setEffect(String ip, int effectId, {int speed = 128}) =>
      _patchState(ip, {
        'seg': [
          {'id': 0, 'fx': effectId, 'sx': speed},
        ],
      });

  /// Applies colour temperature + effect + speed in one PATCH.
  ///
  /// Sends CCT via every known field:
  ///   • root `ct` / `cct`         – standard WLED fields
  ///   • `seg[0].cct`              – WLED-SR per-segment CCT
  ///   • `seg[0].col[0]` = [ww, cw, 0] – RGB-mapped WW+CW strips where
  ///       R channel = Warm White and G channel = Cool White.
  ///       ww + cw always sum to ~319 so perceived brightness stays constant.
  Future<void> setFullSegment(
    String ip, {
    required int cct,       // 0–255  (0 = warmest, 255 = coolest)
    required int effectId,
    required int speed,     // 0–255
  }) {
    // RGB col[0] for WW+CW strips wired as R=WW, G=CW.
    final t = cct / 255.0;
    final ww = (255 - t * 191).round().clamp(0, 255); // 255 (warm) → 64 (cool)
    final cw = (64  + t * 191).round().clamp(0, 255); //  64 (warm) → 255 (cool)

    return _patchState(ip, {
      'ct':  cct,
      'cct': cct,
      'seg': [
        {
          'id': 0,
          'cct': cct,
          'col': [[ww, cw, 0], [0, 0, 0], [0, 0, 0]],
          'fx': effectId,
          'sx': speed,
        },
      ],
    });
  }

  // ── Utility ─────────────────────────────────────────────────────────────────

  /// Returns true if the device at [ip] responds with HTTP 200 on any
  /// of the known endpoints.  Tries the most common paths in order so
  /// both standard WLED firmware and custom CCT controllers are covered.
  Future<bool> testConnection(String ip) async {
    const candidates = [
      '/json',        // WLED root – returns full state, most universal
      '/json/state',  // WLED state endpoint
      '/json/info',   // WLED info endpoint (lightweight)
      '/state',       // custom firmware: flat /state
      '/api/state',   // custom firmware: /api prefix
      '/status',      // custom firmware: /status
      '/',            // bare root – last resort
    ];
    for (final path in candidates) {
      try {
        // Why: shorter per-path timeout caps worst-case UI block (see
        // _probeTimeout doc above).
        final res =
            await _http.get(_url(ip, path)).timeout(_probeTimeout);
        if (res.statusCode == 200) return true;
      } catch (_) {
        // timeout or network error on this path – try next
      }
    }
    return false;
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
