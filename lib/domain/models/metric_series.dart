import 'metric_data_point.dart';
import 'metric_type.dart';

/// An ordered collection of data points for one device and metric,
/// with optional pre-computed aggregates.
class MetricSeries {
  final String deviceId;
  final String deviceName;
  final MetricType type;
  final List<MetricDataPoint> points;
  final double? min;
  final double? max;
  final double? avg;

  const MetricSeries({
    required this.deviceId,
    required this.deviceName,
    required this.type,
    required this.points,
    this.min,
    this.max,
    this.avg,
  });

  MetricSeries copyWith({
    String? deviceId,
    String? deviceName,
    MetricType? type,
    List<MetricDataPoint>? points,
    double? min,
    double? max,
    double? avg,
  }) {
    return MetricSeries(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      type: type ?? this.type,
      points: points ?? this.points,
      min: min ?? this.min,
      max: max ?? this.max,
      avg: avg ?? this.avg,
    );
  }

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'type': type.name,
        'points': points.map((p) => p.toJson()).toList(),
        'min': min,
        'max': max,
        'avg': avg,
      };

  static MetricSeries fromJson(Map<String, dynamic> json) {
    final metricType = MetricType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => MetricType.state,
    );
    return MetricSeries(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      type: metricType,
      points: (json['points'] as List)
          .map((e) => MetricDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      avg: (json['avg'] as num?)?.toDouble(),
    );
  }
}
