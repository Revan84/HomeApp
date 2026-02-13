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
    );
  }
}
