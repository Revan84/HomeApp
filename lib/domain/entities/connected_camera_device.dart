import 'camera_brand.dart';
import 'camera_capabilities.dart';

/// Domain entity for an IP camera (Reolink E1 Zoom and future brands).
///
/// Stores connectivity credentials and brand metadata.
/// The credential fields are required for RTSP access — empty strings mean
/// the device was added without authentication (probe-only mode).
class ConnectedCameraDevice {
  final String id;
  final String name;
  final String ipAddress;
  final String? roomId;
  final bool isFavorite;
  final String modelName;
  final String firmwareVersion;
  final CameraBrand brand;
  final CameraCapabilities capabilities;

  // SECURITY: cameraAccountPassword is currently persisted in plain text via
  // shared_preferences alongside other device data. This is acceptable for a
  // personal IoT app on a trusted device, but should be migrated to
  // flutter_secure_storage before any production / multi-user use.
  // Tracked as: TODO(security): migrate camera credentials to secure storage.
  final String cameraAccountUser;
  final String cameraAccountPassword;

  /// Default 554. Configurable for cameras running RTSP on a non-standard port.
  final int rtspPort;

  /// HTTP API port for `/api.cgi` probing and info fetch. Default 80 on Reolink.
  /// This is the port used today for connectivity checks and device info.
  final int httpApiPort;

  /// ONVIF port for PTZ commands, motion config, etc. (PR-3+).
  /// Default 8000 on Reolink. NOT used by the HTTP API probe — see [httpApiPort].
  final int onvifPort;

  final bool privacyModeEnabled;

  const ConnectedCameraDevice({
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

  ConnectedCameraDevice copyWith({
    String? id,
    String? name,
    String? ipAddress,
    String? roomId,
    bool? isFavorite,
    String? modelName,
    String? firmwareVersion,
    CameraBrand? brand,
    CameraCapabilities? capabilities,
    String? cameraAccountUser,
    String? cameraAccountPassword,
    int? rtspPort,
    int? httpApiPort,
    int? onvifPort,
    bool? privacyModeEnabled,
    bool clearRoomId = false,
  }) {
    return ConnectedCameraDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      roomId: clearRoomId ? null : (roomId ?? this.roomId),
      isFavorite: isFavorite ?? this.isFavorite,
      modelName: modelName ?? this.modelName,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      brand: brand ?? this.brand,
      capabilities: capabilities ?? this.capabilities,
      cameraAccountUser: cameraAccountUser ?? this.cameraAccountUser,
      cameraAccountPassword:
          cameraAccountPassword ?? this.cameraAccountPassword,
      rtspPort: rtspPort ?? this.rtspPort,
      httpApiPort: httpApiPort ?? this.httpApiPort,
      onvifPort: onvifPort ?? this.onvifPort,
      privacyModeEnabled: privacyModeEnabled ?? this.privacyModeEnabled,
    );
  }
}
