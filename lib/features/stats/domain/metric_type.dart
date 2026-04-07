/// Types of metrics that can be tracked for IoT devices.
enum MetricType { temperature, humidity, power, energy, brightness, state }

extension MetricTypeX on MetricType {
  /// Short unit label displayed alongside values.
  String get unit {
    switch (this) {
      case MetricType.temperature:
        return '°C';
      case MetricType.humidity:
        return '%';
      case MetricType.power:
        return 'W';
      case MetricType.energy:
        return 'Wh';
      case MetricType.brightness:
        return 'lx';
      case MetricType.state:
        return '';
    }
  }

  /// Human-readable label for this metric.
  String get label {
    switch (this) {
      case MetricType.temperature:
        return 'Temperature';
      case MetricType.humidity:
        return 'Humidity';
      case MetricType.power:
        return 'Power';
      case MetricType.energy:
        return 'Energy';
      case MetricType.brightness:
        return 'Brightness';
      case MetricType.state:
        return 'State';
    }
  }

  /// Formats a raw [value] with the appropriate precision and unit.
  String formatValue(double value) {
    switch (this) {
      case MetricType.temperature:
        return '${value.toStringAsFixed(1)} $unit';
      case MetricType.humidity:
        return '${value.toStringAsFixed(0)} $unit';
      case MetricType.power:
        return '${value.toStringAsFixed(1)} $unit';
      case MetricType.energy:
        return '${value.toStringAsFixed(0)} $unit';
      case MetricType.brightness:
        return '${value.toStringAsFixed(0)} $unit';
      case MetricType.state:
        return value > 0 ? 'ON' : 'OFF';
    }
  }
}
