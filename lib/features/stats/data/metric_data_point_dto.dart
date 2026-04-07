/// Storage shape for [MetricDataPoint].
/// Contains only field declarations and Map conversion.
/// All domain mapping is handled by [MetricDataPointMapper].
class MetricDataPointDto {
  final String timestamp;
  final double value;
  final String type;

  const MetricDataPointDto({
    required this.timestamp,
    required this.value,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
        'timestamp': timestamp,
        'value': value,
        'type': type,
      };

  factory MetricDataPointDto.fromMap(Map<String, dynamic> m) =>
      MetricDataPointDto(
        timestamp: m['timestamp'] as String,
        value: (m['value'] as num).toDouble(),
        type: (m['type'] ?? 'state') as String,
      );
}
