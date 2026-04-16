import '../../../domain/entities/enums.dart';
import '../../../domain/entities/equipment.dart';
import '../domain/metric_type.dart';
import '../domain/stat_widget.dart';

/// Maps [EquipmentType] to the logical [DeviceType] used for filtering.
DeviceType deviceTypeForEquipment(Equipment eq) {
  switch (eq.type) {
    case EquipmentType.shellyPlusPlugS:
    case EquipmentType.shellyPlugS:
      return DeviceType.plug;
    case EquipmentType.shellyHT:
      return DeviceType.thermoHygro;
    case EquipmentType.other:
      return DeviceType.plug;
  }
}

/// Widget types allowed per [DeviceType].
const Map<DeviceType, List<StatWidgetType>> allowedWidgetTypes = {
  DeviceType.plug: [
    StatWidgetType.kpi,
    StatWidgetType.chart,
    StatWidgetType.table,
    StatWidgetType.history,
  ],
  DeviceType.thermo: [
    StatWidgetType.kpi,
    StatWidgetType.chart,
    StatWidgetType.history,
  ],
  DeviceType.hygro: [
    StatWidgetType.kpi,
    StatWidgetType.chart,
    StatWidgetType.history,
  ],
  DeviceType.thermoHygro: [
    StatWidgetType.kpi,
    StatWidgetType.chart,
    StatWidgetType.history,
  ],
};

/// Metric types exposed per [DeviceType].
const Map<DeviceType, List<MetricType>> allowedMetricTypes = {
  DeviceType.plug: [MetricType.power, MetricType.energy],
  DeviceType.thermo: [MetricType.temperature],
  DeviceType.hygro: [MetricType.humidity],
  DeviceType.thermoHygro: [MetricType.temperature, MetricType.humidity],
};

/// Returns the [StatWidgetType]s available for [equipment].
List<StatWidgetType> widgetTypesFor(Equipment equipment) {
  final dt = deviceTypeForEquipment(equipment);
  return allowedWidgetTypes[dt] ?? StatWidgetType.values;
}

/// Returns the [MetricType]s available for [equipment].
List<MetricType> metricsFor(Equipment equipment) {
  final dt = deviceTypeForEquipment(equipment);
  return allowedMetricTypes[dt] ?? MetricType.values;
}
