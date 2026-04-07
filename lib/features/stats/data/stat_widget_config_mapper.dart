import '../domain/chart_type.dart';
import '../domain/metric_type.dart';
import '../domain/stat_widget.dart';
import '../domain/time_range.dart';
import 'stat_widget_config_dto.dart';

/// Maps between [StatWidgetConfigDto] and [StatWidgetConfig].
class StatWidgetConfigMapper {
  StatWidgetConfigMapper._();

  static StatWidgetConfig toDomain(StatWidgetConfigDto dto) {
    final rawChart = dto.extra?['chartType'] as String?;
    final chartType = rawChart != null
        ? ChartType.values.asNameMap()[rawChart] ?? ChartType.line
        : null;

    return StatWidgetConfig(
      id: dto.id,
      type: StatWidgetType.values.asNameMap()[dto.type] ?? StatWidgetType.chart,
      title: dto.title,
      deviceId: dto.deviceId,
      metric: MetricType.values.asNameMap()[dto.metric] ?? MetricType.temperature,
      range: TimeRange.values.asNameMap()[dto.range] ?? TimeRange.day1,
      chartType: chartType,
    );
  }

  static StatWidgetConfigDto fromDomain(StatWidgetConfig c) {
    final extra = c.chartType != null
        ? <String, dynamic>{'chartType': c.chartType!.name}
        : null;

    return StatWidgetConfigDto(
      id: c.id,
      type: c.type.name,
      title: c.title,
      deviceId: c.deviceId,
      metric: c.metric.name,
      range: c.range.name,
      extra: extra,
    );
  }
}
