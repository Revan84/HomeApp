class ShellySwitchStatusDto {
  final bool? output;
  final num? apower;
  final num? energyWh;
  final int? rssi;

  ShellySwitchStatusDto({
    this.output,
    this.apower,
    this.energyWh,
    this.rssi,
  });

  factory ShellySwitchStatusDto.fromJson(Map<String, dynamic> json) {
    final aenergy = json['aenergy'];
    final energyWh = aenergy is Map ? (aenergy['total'] as num?) : null;

    return ShellySwitchStatusDto(
      output: json['output'] as bool?,
      apower: json['apower'] as num?,
      energyWh: energyWh,
      rssi: json['rssi'] is num ? (json['rssi'] as num).toInt() : null,
    );
  }
}
