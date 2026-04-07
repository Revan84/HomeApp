/// DTO for the Shelly.GetDeviceInfo RPC response.
///
/// Only the fields consumed by the UI are mapped; unknown fields are ignored.
class ShellyDeviceInfoDto {
  final String name;
  final String model;
  final String mac;

  const ShellyDeviceInfoDto({
    required this.name,
    required this.model,
    required this.mac,
  });

  factory ShellyDeviceInfoDto.fromJson(Map<String, dynamic> json) =>
      ShellyDeviceInfoDto(
        name: (json['name'] as String?) ?? '',
        model: (json['model'] as String?) ?? '',
        mac: (json['mac'] as String?) ?? '',
      );
}
