import '../domain/metric_data_point.dart';
import '../domain/metric_type.dart';
import 'metric_data_point_dto.dart';

/// Maps between [MetricDataPointDto] and [MetricDataPoint].
class MetricDataPointMapper {
  MetricDataPointMapper._();

  static MetricDataPoint toDomain(MetricDataPointDto dto) => MetricDataPoint(
        timestamp: DateTime.parse(dto.timestamp),
        value: dto.value,
        type: MetricType.values.asNameMap()[dto.type] ?? MetricType.state,
      );

  static MetricDataPointDto fromDomain(MetricDataPoint p) => MetricDataPointDto(
        timestamp: p.timestamp.toIso8601String(),
        value: p.value,
        type: p.type.name,
      );
}
