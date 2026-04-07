import 'chart_type.dart';
import 'metric_type.dart';
import 'time_range.dart';

/// The kind of visualisation a stat widget renders.
enum StatWidgetType { chart, table, history, kpi }

/// Configuration for a single stat widget on the dashboard.
class StatWidgetConfig {
  final String id;
  final StatWidgetType type;
  final String title;
  final String deviceId;
  final MetricType metric;
  final TimeRange range;
  final ChartType? chartType;

  const StatWidgetConfig({
    required this.id,
    required this.type,
    required this.title,
    required this.deviceId,
    required this.metric,
    required this.range,
    this.chartType,
  });

  StatWidgetConfig copyWith({
    String? id,
    StatWidgetType? type,
    String? title,
    String? deviceId,
    MetricType? metric,
    TimeRange? range,
    ChartType? chartType,
  }) {
    return StatWidgetConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      deviceId: deviceId ?? this.deviceId,
      metric: metric ?? this.metric,
      range: range ?? this.range,
      chartType: chartType ?? this.chartType,
    );
  }
}

/// Represents the stats page for a room: an ordered list of widgets.
class StatDashboard {
  final String roomName;
  final List<StatWidgetConfig> widgets;

  const StatDashboard({
    required this.roomName,
    required this.widgets,
  });
}
