import 'dart:convert';

/// Whether the alert fires above or below a threshold.
enum SensorAlertCondition { above, below }

/// How the user wants to be notified.
enum SensorAlertNotification { push, banner }

/// A configured threshold alert for a temperature or humidity sensor.
class SensorAlert {
  final String id;
  final String equipmentId;
  final SensorAlertCondition condition;

  /// The threshold value — °C for thermometers, % for hygrometers.
  final double threshold;

  final Set<SensorAlertNotification> notifications;
  final bool isEnabled;

  /// True when this alert watches humidity (%), false for temperature (°C).
  /// Defaults to false for backward-compatibility with persisted data.
  final bool isHumidity;

  const SensorAlert({
    required this.id,
    required this.equipmentId,
    required this.condition,
    required this.threshold,
    required this.notifications,
    this.isEnabled = true,
    this.isHumidity = false,
  });

  SensorAlert copyWith({
    SensorAlertCondition? condition,
    double? threshold,
    Set<SensorAlertNotification>? notifications,
    bool? isEnabled,
    bool? isHumidity,
  }) =>
      SensorAlert(
        id: id,
        equipmentId: equipmentId,
        condition: condition ?? this.condition,
        threshold: threshold ?? this.threshold,
        notifications: notifications ?? this.notifications,
        isEnabled: isEnabled ?? this.isEnabled,
        isHumidity: isHumidity ?? this.isHumidity,
      );

  // ── JSON ─────────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'equipmentId': equipmentId,
        'condition': condition.name,
        'threshold': threshold,
        'notifications': notifications.map((n) => n.name).toList(),
        'isEnabled': isEnabled,
        'isHumidity': isHumidity,
      };

  factory SensorAlert.fromJson(Map<String, dynamic> json) => SensorAlert(
        id: json['id'] as String,
        equipmentId: json['equipmentId'] as String,
        condition: SensorAlertCondition.values.firstWhere(
          (c) => c.name == json['condition'],
          orElse: () => SensorAlertCondition.above,
        ),
        threshold: (json['threshold'] as num).toDouble(),
        notifications: (json['notifications'] as List)
            .map((n) => SensorAlertNotification.values.firstWhere(
                  (v) => v.name == n,
                  orElse: () => SensorAlertNotification.banner,
                ))
            .toSet(),
        isEnabled: json['isEnabled'] as bool? ?? true,
        isHumidity: json['isHumidity'] as bool? ?? false,
      );

  static List<SensorAlert> listFromJson(String raw) {
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => SensorAlert.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<SensorAlert> alerts) =>
      jsonEncode(alerts.map((a) => a.toJson()).toList());
}
