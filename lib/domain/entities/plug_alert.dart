import 'dart:convert';

/// What triggers the alert.
enum PlugAlertCondition {
  /// Instantaneous power exceeds a watt threshold.
  wattsExceeded,

  /// Estimated daily energy cost exceeds a euro threshold.
  dailyCostExceeded,
}

/// How the user wants to be notified.
enum PlugAlertNotification { push, banner }

/// A configured threshold alert for a smart plug.
class PlugAlert {
  final String id;
  final String equipmentId;
  final PlugAlertCondition condition;

  /// The threshold value — watts for [PlugAlertCondition.wattsExceeded],
  /// euros for [PlugAlertCondition.dailyCostExceeded].
  final double threshold;

  final Set<PlugAlertNotification> notifications;
  final bool isEnabled;

  const PlugAlert({
    required this.id,
    required this.equipmentId,
    required this.condition,
    required this.threshold,
    required this.notifications,
    this.isEnabled = true,
  });

  PlugAlert copyWith({
    PlugAlertCondition? condition,
    double? threshold,
    Set<PlugAlertNotification>? notifications,
    bool? isEnabled,
  }) =>
      PlugAlert(
        id: id,
        equipmentId: equipmentId,
        condition: condition ?? this.condition,
        threshold: threshold ?? this.threshold,
        notifications: notifications ?? this.notifications,
        isEnabled: isEnabled ?? this.isEnabled,
      );

  // ── JSON ────────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'equipmentId': equipmentId,
        'condition': condition.name,
        'threshold': threshold,
        'notifications': notifications.map((n) => n.name).toList(),
        'isEnabled': isEnabled,
      };

  factory PlugAlert.fromJson(Map<String, dynamic> json) => PlugAlert(
        id: json['id'] as String,
        equipmentId: json['equipmentId'] as String,
        condition: PlugAlertCondition.values.firstWhere(
          (c) => c.name == json['condition'],
          orElse: () => PlugAlertCondition.wattsExceeded,
        ),
        threshold: (json['threshold'] as num).toDouble(),
        notifications: (json['notifications'] as List)
            .map((n) => PlugAlertNotification.values.firstWhere(
                  (v) => v.name == n,
                  orElse: () => PlugAlertNotification.banner,
                ))
            .toSet(),
        isEnabled: json['isEnabled'] as bool? ?? true,
      );

  static List<PlugAlert> listFromJson(String raw) {
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => PlugAlert.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<PlugAlert> alerts) =>
      jsonEncode(alerts.map((a) => a.toJson()).toList());
}
