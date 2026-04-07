/// Storage shape for [StatWidgetConfig].
/// Contains only field declarations and Map conversion.
/// All domain mapping is handled by [StatWidgetConfigMapper].
class StatWidgetConfigDto {
  final String id;
  final String type;
  final String title;
  final String deviceId;
  final String metric;
  final String range;
  final Map<String, dynamic>? extra;

  const StatWidgetConfigDto({
    required this.id,
    required this.type,
    required this.title,
    required this.deviceId,
    required this.metric,
    required this.range,
    this.extra,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'title': title,
        'deviceId': deviceId,
        'metric': metric,
        'range': range,
        'extra': extra,
      };

  factory StatWidgetConfigDto.fromMap(Map<String, dynamic> m) =>
      StatWidgetConfigDto(
        id: m['id'] as String,
        type: (m['type'] ?? 'chart') as String,
        title: (m['title'] ?? '') as String,
        deviceId: (m['deviceId'] ?? '') as String,
        metric: (m['metric'] ?? 'temperature') as String,
        range: (m['range'] ?? 'day1') as String,
        extra: m['extra'] as Map<String, dynamic>?,
      );
}
