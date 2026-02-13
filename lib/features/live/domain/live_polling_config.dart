class LivePollingConfig {
  final Duration tickPeriod;
  final Duration okInterval;
  final int budget;

  const LivePollingConfig({
    this.tickPeriod = const Duration(seconds: 1),
    this.okInterval = const Duration(seconds: 2),
    this.budget = 3,
  });
}
