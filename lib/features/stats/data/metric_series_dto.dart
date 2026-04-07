import 'metric_data_point_dto.dart';

/// Storage shape for [MetricSeries].
/// Contains only field declarations and Map conversion.
/// All domain mapping is handled by [MetricSeriesMapper].
class MetricSeriesDto {
  final String deviceId;
  final String deviceName;
  final String type;
  final List<MetricDataPointDto> points;
  final double? min;
  final double? max;
  final double? avg;

  const MetricSeriesDto({
    required this.deviceId,
    required this.deviceName,
    required this.type,
    required this.points,
    this.min,
    this.max,
    this.avg,
  });

  Map<String, dynamic> toMap() => {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'type': type,
        'points': points.map((p) => p.toMap()).toList(),
        'min': min,
        'max': max,
        'avg': avg,
      };

  factory MetricSeriesDto.fromMap(Map<String, dynamic> m) => MetricSeriesDto(
        deviceId: m['deviceId'] as String,
        deviceName: m['deviceName'] as String,
        type: (m['type'] ?? 'state') as String,
        points: (m['points'] as List)
            .map((e) => MetricDataPointDto.fromMap(e as Map<String, dynamic>))
            .toList(),
        min: (m['min'] as num?)?.toDouble(),
        max: (m['max'] as num?)?.toDouble(),
        avg: (m['avg'] as num?)?.toDouble(),
      );
}
