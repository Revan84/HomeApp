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
}
