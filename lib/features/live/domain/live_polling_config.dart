class LivePollingConfig {
  final Duration tickPeriod;
  final Duration okInterval;
  final int budget;

  const LivePollingConfig({
    this.tickPeriod = const Duration(milliseconds: 50),
    this.okInterval = const Duration(milliseconds: 200),
    this.budget = 3,
  });
}
