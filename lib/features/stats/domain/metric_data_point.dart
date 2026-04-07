import 'metric_type.dart';

/// A single timestamped measurement for a given metric.
class MetricDataPoint {
  final DateTime timestamp;
  final double value;
  final MetricType type;

  const MetricDataPoint({
    required this.timestamp,
    required this.value,
    required this.type,
  });

  MetricDataPoint copyWith({
    DateTime? timestamp,
    double? value,
    MetricType? type,
  }) {
    return MetricDataPoint(
      timestamp: timestamp ?? this.timestamp,
      value: value ?? this.value,
      type: type ?? this.type,
    );
  }
}
