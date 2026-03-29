import 'metric_type.dart';
import 'time_range.dart';

/// The kind of visualisation a stat widget renders.
enum StatWidgetType { chart, table, history, kpi }

/// Configuration for a single stat widget on the dashboard.
///
/// [extra] carries renderer-specific options, e.g. `{'chartType': 'line'}`.
class StatWidgetConfig {
  final String id;
  final StatWidgetType type;
  final String title;
  final String deviceId;
  final MetricType metric;
  final TimeRange range;
  final Map<String, dynamic>? extra;

  const StatWidgetConfig({
    required this.id,
    required this.type,
    required this.title,
    required this.deviceId,
    required this.metric,
    required this.range,
    this.extra,
  });

  StatWidgetConfig copyWith({
    String? id,
    StatWidgetType? type,
    String? title,
    String? deviceId,
    MetricType? metric,
    TimeRange? range,
    Map<String, dynamic>? extra,
  }) {
    return StatWidgetConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      deviceId: deviceId ?? this.deviceId,
      metric: metric ?? this.metric,
      range: range ?? this.range,
      extra: extra ?? this.extra,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'deviceId': deviceId,
        'metric': metric.name,
        'range': range.name,
        'extra': extra,
      };

  static StatWidgetConfig fromJson(Map<String, dynamic> json) {
    return StatWidgetConfig(
      id: json['id'] as String,
      type: StatWidgetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StatWidgetType.chart,
      ),
      title: json['title'] as String,
      deviceId: json['deviceId'] as String,
      metric: MetricType.values.firstWhere(
        (e) => e.name == json['metric'],
        orElse: () => MetricType.temperature,
      ),
      range: TimeRange.values.firstWhere(
        (e) => e.name == json['range'],
        orElse: () => TimeRange.day1,
      ),
      extra: json['extra'] as Map<String, dynamic>?,
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
