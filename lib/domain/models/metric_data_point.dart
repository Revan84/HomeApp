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

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'value': value,
        'type': type.name,
      };

  static MetricDataPoint fromJson(Map<String, dynamic> json) {
    return MetricDataPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      value: (json['value'] as num).toDouble(),
      type: MetricType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MetricType.state,
      ),
    );
  }
}
