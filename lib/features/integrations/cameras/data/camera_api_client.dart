import '../../../../domain/entities/camera_brand.dart';

/// Abstract surface that every camera-brand implementation must satisfy.
///
/// PR-1 wires connectivity probing and info fetching. Streaming, PTZ, motion,
/// and recording will be added in subsequent PRs — each concrete impl will be
/// extended at that point.
abstract interface class CameraApiClient {
  /// The brand this client handles.
  CameraBrand get brand;

  /// Returns true if the camera at [ip]:[httpApiPort] responds with a
  /// brand-compatible payload. Credentials are optional — some cameras answer
  /// unauthenticated probes with enough data to confirm presence.
  ///
  /// [httpApiPort] is the HTTP API port (typically 80 for Reolink's `/api.cgi`),
  /// NOT the ONVIF port (8000). The ONVIF interface is reserved for PR-3.
  Future<bool> testConnection({
    required String ip,
    required int httpApiPort,
    String? username,
    String? password,
  });

  /// Fetches model name and firmware version string. Returns empty strings on
  /// any failure so callers can display '—' without special-casing.
  ///
  /// [httpApiPort] is the HTTP API port (typically 80 for Reolink's `/api.cgi`).
  Future<({String model, String firmware})> getInfo({
    required String ip,
    required int httpApiPort,
    String? username,
    String? password,
  });

  /// Builds the RTSP URL that the live-stream player will consume (PR-2).
  /// Returns null when credentials are missing — the player must not be started.
  String? buildStreamUrl({
    required String ip,
    required int rtspPort,
    required String username,
    required String password,
    bool subStream = false,
  });
}
