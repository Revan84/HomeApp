class DeviceEndpoint {
  final String deviceId;
  final String ip;
  final int channel; // ex: Switch id

  const DeviceEndpoint({
    required this.deviceId,
    required this.ip,
    this.channel = 0,
  });
}
