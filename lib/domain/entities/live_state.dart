class LiveState {
  final bool online;
  final bool? output;
  final num? powerW;
  final num? energyWh;
  final int? rssi;

  final int trendPower;
  final DateTime? lastUpdatedAt;

  final DateTime nextPollAt;
  final int failCount;
  final bool toggling;

  // Thermometer / environmental sensors
  final double? temperatureC;
  final double? humidity;
  final int trendTemperature; // -1 falling, 0 stable, +1 rising
  final int trendHumidity;    // -1 falling, 0 stable, +1 rising

  const LiveState({
    required this.online,
    required this.nextPollAt,
    required this.failCount,
    required this.toggling,
    this.output,
    this.powerW,
    this.energyWh,
    this.rssi,
    this.trendPower = 0,
    this.lastUpdatedAt,
    this.temperatureC,
    this.humidity,
    this.trendTemperature = 0,
    this.trendHumidity = 0,
  });

  Duration get backoff {
    if (failCount <= 0) return const Duration(seconds: 2);
    final secs = (2 << (failCount - 1));
    return Duration(seconds: secs > 30 ? 30 : secs);
  }

  LiveState copyWith({
    bool? online,
    bool? output,
    num? powerW,
    num? energyWh,
    int? rssi,
    int? trendPower,
    DateTime? lastUpdatedAt,
    DateTime? nextPollAt,
    int? failCount,
    bool? toggling,
    double? temperatureC,
    double? humidity,
    int? trendTemperature,
    int? trendHumidity,
  }) {
    return LiveState(
      online: online ?? this.online,
      output: output ?? this.output,
      powerW: powerW ?? this.powerW,
      energyWh: energyWh ?? this.energyWh,
      rssi: rssi ?? this.rssi,
      trendPower: trendPower ?? this.trendPower,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      nextPollAt: nextPollAt ?? this.nextPollAt,
      failCount: failCount ?? this.failCount,
      toggling: toggling ?? this.toggling,
      temperatureC: temperatureC ?? this.temperatureC,
      humidity: humidity ?? this.humidity,
      trendTemperature: trendTemperature ?? this.trendTemperature,
      trendHumidity: trendHumidity ?? this.trendHumidity,
    );
  }
}
