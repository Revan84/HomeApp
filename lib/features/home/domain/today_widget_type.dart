/// Types of aggregated stats that can appear in the "Today" section.
enum TodayWidgetType {
  consumption,
  temperature,
  humidity;

  /// Human-readable label for display in the manage sheet.
  String get displayName {
    switch (this) {
      case TodayWidgetType.consumption:
        return 'Consumption';
      case TodayWidgetType.temperature:
        return 'Temperature';
      case TodayWidgetType.humidity:
        return 'Humidity';
    }
  }
}
