import 'metric_series.dart';
import 'metric_type.dart';
import 'stat_widget.dart';
import 'time_range.dart';

/// Contract for fetching metric series and persisting stat dashboards.
abstract class StatsRepository {
  /// Returns a time series for [deviceId] / [type] over [range].
  Future<MetricSeries> fetchSeries(
    String deviceId,
    MetricType type,
    TimeRange range,
  );

  /// Returns the list of widget configs saved for [roomId].
  Future<List<StatWidgetConfig>> fetchDashboard(String roomId);

  /// Persists widget configs for [roomId].
  Future<void> saveDashboard(String roomId, List<StatWidgetConfig> widgets);
}
