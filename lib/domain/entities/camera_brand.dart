/// Brand of a connected camera.
///
/// Drives which [CameraApiClient] implementation handles network operations
/// for the device. Persisted as a string in the DTO so new values can be
/// added without breaking existing stored devices.
///
/// Only [generic] is registered today. Brand-specific implementations
/// (Reolink, Tapo, Amcrest, etc.) will be added when a real camera is
/// available for testing.
enum CameraBrand {
  generic,
}
