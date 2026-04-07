import '../domain/metric_series.dart';
import '../domain/metric_type.dart';
import 'metric_data_point_mapper.dart';
import 'metric_series_dto.dart';

/// Maps between [MetricSeriesDto] and [MetricSeries].
class MetricSeriesMapper {
  MetricSeriesMapper._();

  static MetricSeries toDomain(MetricSeriesDto dto) => MetricSeries(
        deviceId: dto.deviceId,
        deviceName: dto.deviceName,
        type: MetricType.values.asNameMap()[dto.type] ?? MetricType.state,
        points: dto.points.map(MetricDataPointMapper.toDomain).toList(),
        min: dto.min,
        max: dto.max,
        avg: dto.avg,
      );

  static MetricSeriesDto fromDomain(MetricSeries s) => MetricSeriesDto(
        deviceId: s.deviceId,
        deviceName: s.deviceName,
        type: s.type.name,
        points: s.points.map(MetricDataPointMapper.fromDomain).toList(),
        min: s.min,
        max: s.max,
        avg: s.avg,
      );
}
