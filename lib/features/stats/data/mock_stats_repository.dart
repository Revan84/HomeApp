import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import '../../../core/storage/local_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../domain/metric_data_point.dart';
import '../domain/metric_series.dart';
import '../domain/metric_type.dart';
import '../domain/stat_widget.dart';
import '../domain/stats_repository.dart';
import '../domain/time_range.dart';
import 'stat_widget_config_dto.dart';
import 'stat_widget_config_mapper.dart';

/// Mock implementation that generates realistic sensor data and persists
/// dashboards to [LocalStorage] so they survive app restarts.
class MockStatsRepository implements StatsRepository {
  final LocalStorage _storage;
  final _random = Random(42);

  MockStatsRepository(this._storage);

  @override
  Future<MetricSeries> fetchSeries(
    String deviceId,
    MetricType type,
    TimeRange range,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final start = now.subtract(range.duration);
    final points = _generatePoints(type, range, start, now);

    double? seriesMin;
    double? seriesMax;
    double sum = 0;
    for (final p in points) {
      if (seriesMin == null || p.value < seriesMin) seriesMin = p.value;
      if (seriesMax == null || p.value > seriesMax) seriesMax = p.value;
      sum += p.value;
    }

    return MetricSeries(
      deviceId: deviceId,
      deviceName: _deviceNameFor(deviceId),
      type: type,
      points: points,
      min: seriesMin,
      max: seriesMax,
      avg: points.isEmpty ? null : sum / points.length,
    );
  }

  @override
  Future<List<StatWidgetConfig>> fetchDashboard(String roomId) async {
    final raw = await _storage.getString(
      '${StorageKeys.statsDashboardPrefix}$roomId',
    );
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => StatWidgetConfigMapper.toDomain(
                StatWidgetConfigDto.fromMap(e as Map<String, dynamic>),
              ))
          .toList();
    } on FormatException catch (e, st) {
      dev.log('Failed to parse stats dashboard', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<void> saveDashboard(
    String roomId,
    List<StatWidgetConfig> widgets,
  ) async {
    final json = jsonEncode(
      widgets
          .map((w) => StatWidgetConfigMapper.fromDomain(w).toMap())
          .toList(),
    );
    await _storage.setString(
      '${StorageKeys.statsDashboardPrefix}$roomId',
      json,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _deviceNameFor(String deviceId) {
    if (deviceId.contains('thermo')) return 'Thermometer';
    if (deviceId.contains('plug')) return 'Smart Plug';
    if (deviceId.contains('hygro')) return 'Hygrometer';
    return 'Device $deviceId';
  }

  int _pointCount(TimeRange range) {
    switch (range) {
      case TimeRange.day1:
        return 96;
      case TimeRange.week1:
        return 168;
      case TimeRange.month1:
        return 360;
      case TimeRange.year1:
        return 365;
      case TimeRange.max:
        return 500;
    }
  }

  List<MetricDataPoint> _generatePoints(
    MetricType type,
    TimeRange range,
    DateTime start,
    DateTime end,
  ) {
    final count = _pointCount(range);
    final totalMs = end.difference(start).inMilliseconds;
    final step = totalMs ~/ max(1, count - 1);

    final points = <MetricDataPoint>[];
    double value = _baseValue(type);

    for (int i = 0; i < count; i++) {
      final timestamp = start.add(Duration(milliseconds: step * i));
      value = _nextValue(type, value);
      points.add(MetricDataPoint(
        timestamp: timestamp,
        value: double.parse(value.toStringAsFixed(2)),
        type: type,
      ));
    }
    return points;
  }

  double _baseValue(MetricType type) {
    switch (type) {
      case MetricType.temperature:
        return 21.0;
      case MetricType.humidity:
        return 55.0;
      case MetricType.power:
        return 35.0;
      case MetricType.energy:
        return 120.0;
      case MetricType.brightness:
        return 300.0;
      case MetricType.state:
        return 1.0;
    }
  }

  double _nextValue(MetricType type, double current) {
    switch (type) {
      case MetricType.temperature:
        return (current + (_random.nextDouble() - 0.48) * 0.6)
            .clamp(18.0, 25.0);
      case MetricType.humidity:
        return (current + (_random.nextDouble() - 0.5) * 2.0)
            .clamp(40.0, 70.0);
      case MetricType.power:
        return (current + (_random.nextDouble() - 0.5) * 5.0)
            .clamp(10.0, 64.0);
      case MetricType.energy:
        return current + _random.nextDouble() * 0.5;
      case MetricType.brightness:
        return (current + (_random.nextDouble() - 0.5) * 30.0)
            .clamp(0.0, 1000.0);
      case MetricType.state:
        return _random.nextDouble() > 0.95
            ? (current > 0 ? 0.0 : 1.0)
            : current;
    }
  }
}
