import 'dart:convert';
import 'dart:developer' as dev;

import '../../domain/entities/camera_brand.dart';
import '../../domain/entities/camera_capabilities.dart';

/// Storage/transport shape for [ConnectedCameraDevice].
///
/// Migration contract (PR-0 → PR-1 → fix/camera-http-api-port):
/// - If [brand] is absent or 'reolink' (legacy dev value) → [CameraBrand.generic].
/// - If [capabilities] is absent → default [CameraCapabilities.unknown].
/// - If [cameraAccountUser] is absent → fall back to legacy [rtspUsername].
/// - If [cameraAccountPassword] is absent → fall back to legacy [rtspPassword].
/// - If [rtspPort] is absent → default 554.
/// - Port migration (PR-1 → fix): PR-1 stored a single `onvifPort` field
///   (default 8000) that was semantically used as the HTTP API port. We now
///   split into `httpApiPort` (default 80) + `onvifPort` (default 8000).
///   See [fromMap] for the full migration table.
class ConnectedCameraDeviceDto {
  final String id;
  final String name;
  final String ipAddress;
  final String? roomId;
  final bool isFavorite;
  final String modelName;
  final String firmwareVersion;
  final CameraBrand brand;
  final CameraCapabilities capabilities;
  final String cameraAccountUser;
  final String cameraAccountPassword;
  final int rtspPort;
  final int httpApiPort;
  final int onvifPort;
  final bool privacyModeEnabled;

  const ConnectedCameraDeviceDto({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.roomId,
    this.isFavorite = false,
    this.modelName = '',
    this.firmwareVersion = '',
    this.brand = CameraBrand.generic,
    this.capabilities = CameraCapabilities.unknown,
    this.cameraAccountUser = '',
    this.cameraAccountPassword = '',
    this.rtspPort = 554,
    this.httpApiPort = 80,
    this.onvifPort = 8000,
    this.privacyModeEnabled = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'ipAddress': ipAddress,
        'roomId': roomId,
        'isFavorite': isFavorite,
        'modelName': modelName,
        'firmwareVersion': firmwareVersion,
        'brand': brand.name,
        'capabilities': capabilities.toMap(),
        'cameraAccountUser': cameraAccountUser,
        'cameraAccountPassword': cameraAccountPassword,
        'rtspPort': rtspPort,
        'httpApiPort': httpApiPort,
        'onvifPort': onvifPort,
        'privacyModeEnabled': privacyModeEnabled,
      };

  factory ConnectedCameraDeviceDto.fromMap(Map<String, dynamic> m) {
    // ── Brand migration ────────────────────────────────────────────────────
    // Why: 'reolink' was the only persisted value in the dev branch before
    // the generalization. Map it to 'generic' so old stored devices still
    // load correctly. Any future unknown value also falls back to generic.
    CameraBrand brand;
    try {
      final raw = m['brand'] as String?;
      if (raw == null || raw == 'reolink') {
        brand = CameraBrand.generic;
      } else {
        brand = CameraBrand.values.byName(raw);
      }
    } catch (_) {
      dev.log('ConnectedCameraDeviceDto: unknown brand "${m['brand']}", defaulting to generic');
      brand = CameraBrand.generic;
    }

    // ── Capabilities migration ─────────────────────────────────────────────
    final capMap = m['capabilities'] as Map<String, dynamic>?;
    final capabilities = capMap != null
        ? CameraCapabilities.fromMap(capMap)
        : CameraCapabilities.unknown;

    // ── Credential migration (PR-0 → PR-1 field rename) ────────────────────
    final cameraAccountUser =
        (m['cameraAccountUser'] as String?) ??
        (m['rtspUsername'] as String?) ??
        '';
    final cameraAccountPassword =
        (m['cameraAccountPassword'] as String?) ??
        (m['rtspPassword'] as String?) ??
        '';

    // ── Port migration (PR-1 → fix/camera-http-api-port) ─────────────────
    // Why: PR-1 stored a single `onvifPort` field (default 8000) that was
    // semantically the HTTP API port. We now split into:
    //   - httpApiPort: used for /api.cgi (correct default: 80)
    //   - onvifPort: reserved for PR-3 (PTZ, motion); default 8000
    // If `httpApiPort` is present, this is a post-fix payload → read both
    // fields directly. Otherwise re-interpret the legacy `onvifPort` value
    // as the intended HTTP API port; the new `onvifPort` always defaults to
    // 8000 for legacy data since PR-1 never used a real ONVIF port.
    final int httpApiPort;
    final int onvifPort;
    if (m.containsKey('httpApiPort')) {
      httpApiPort = (m['httpApiPort'] as int?) ?? 80;
      onvifPort   = (m['onvifPort']   as int?) ?? 8000;
    } else {
      final legacy = m['onvifPort'] as int?;
      if (legacy == null || legacy == 8000) {
        // Either absent or the PR-1 default — apply the correct defaults.
        httpApiPort = 80;
      } else {
        // User had an explicit non-default value — preserve as the HTTP port.
        httpApiPort = legacy;
      }
      onvifPort = 8000;
    }

    return ConnectedCameraDeviceDto(
      id: (m['id'] ?? '') as String,
      name: (m['name'] ?? '') as String,
      ipAddress: (m['ipAddress'] ?? '') as String,
      roomId: m['roomId'] as String?,
      isFavorite: (m['isFavorite'] as bool?) ?? false,
      modelName: (m['modelName'] as String?) ?? '',
      firmwareVersion: (m['firmwareVersion'] as String?) ?? '',
      brand: brand,
      capabilities: capabilities,
      cameraAccountUser: cameraAccountUser,
      cameraAccountPassword: cameraAccountPassword,
      rtspPort: (m['rtspPort'] as int?) ?? 554,
      httpApiPort: httpApiPort,
      onvifPort: onvifPort,
      privacyModeEnabled: (m['privacyModeEnabled'] as bool?) ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ConnectedCameraDeviceDto.fromJson(String s) =>
      ConnectedCameraDeviceDto.fromMap(jsonDecode(s) as Map<String, dynamic>);
}
