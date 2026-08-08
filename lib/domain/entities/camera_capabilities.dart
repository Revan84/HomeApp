/// Hardware capability set for a [ConnectedCameraDevice].
///
/// Defaults to [unknown] until a brand-specific implementation can probe
/// the camera. Future brand PRs will populate this from the device info API.
class CameraCapabilities {
  const CameraCapabilities({
    required this.hasPtz,
    required this.hasOpticalZoom,
    required this.hasTwoWayAudio,
    required this.hasOnDeviceAi,
    required this.hasNightVision,
    required this.maxResolution,
  });

  final bool hasPtz;
  final bool hasOpticalZoom;
  final bool hasTwoWayAudio;
  final bool hasOnDeviceAi;
  final bool hasNightVision;

  /// Human-readable resolution string, e.g. "5MP", "4K", "unknown".
  final String maxResolution;

  /// Conservative defaults — used when capabilities are not yet known.
  // Why: a brand-specific PR will overwrite this once the camera is probed.
  static const CameraCapabilities unknown = CameraCapabilities(
    hasPtz: false,
    hasOpticalZoom: false,
    hasTwoWayAudio: false,
    hasOnDeviceAi: false,
    hasNightVision: false,
    maxResolution: 'unknown',
  );

  Map<String, dynamic> toMap() => {
        'hasPtz': hasPtz,
        'hasOpticalZoom': hasOpticalZoom,
        'hasTwoWayAudio': hasTwoWayAudio,
        'hasOnDeviceAi': hasOnDeviceAi,
        'hasNightVision': hasNightVision,
        'maxResolution': maxResolution,
      };

  factory CameraCapabilities.fromMap(Map<String, dynamic> m) =>
      CameraCapabilities(
        hasPtz: (m['hasPtz'] as bool?) ?? false,
        hasOpticalZoom: (m['hasOpticalZoom'] as bool?) ?? false,
        hasTwoWayAudio: (m['hasTwoWayAudio'] as bool?) ?? false,
        hasOnDeviceAi: (m['hasOnDeviceAi'] as bool?) ?? false,
        hasNightVision: (m['hasNightVision'] as bool?) ?? false,
        maxResolution: (m['maxResolution'] as String?) ?? 'unknown',
      );
}
