import 'package:flutter/foundation.dart';

import '../../../domain/models/metric_series.dart';
import '../../../domain/models/metric_type.dart';
import '../../../domain/models/stat_widget.dart';
import '../../../domain/models/time_range.dart';
import '../../../domain/repositories/stats_repository.dart';

/// Manages the stat dashboard widgets and their associated series data.
class StatsController extends ChangeNotifier {
  final StatsRepository _repo;

  StatsController(this._repo);

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<StatWidgetConfig> _widgets = [];
  List<StatWidgetConfig> get widgets => List.unmodifiable(_widgets);

  /// Cache keyed by "$deviceId:$metric:$range" to avoid redundant fetches.
  final Map<String, MetricSeries> _seriesCache = {};
  Map<String, MetricSeries> get seriesCache =>
      Map.unmodifiable(_seriesCache);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String? _currentRoomId;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Clears the current dashboard (e.g. when there is no room selected).
  void clearDashboard() {
    _currentRoomId = null;
    _widgets = [];
    _seriesCache.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Loads the dashboard for [roomId] and fetches all series.
  Future<void> loadDashboard(String roomId) async {
    _currentRoomId = roomId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _widgets = await _repo.fetchDashboard(roomId);

      // Pre-fetch series for every widget.
      await Future.wait(
        _widgets.map((w) => loadSeries(w.deviceId, w.metric, w.range)),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches (or returns cached) series for the given parameters.
  Future<MetricSeries> loadSeries(
    String deviceId,
    MetricType metric,
    TimeRange range,
  ) async {
    final key = _cacheKey(deviceId, metric, range);
    if (_seriesCache.containsKey(key)) return _seriesCache[key]!;

    final series = await _repo.fetchSeries(deviceId, metric, range);
    _seriesCache[key] = series;
    notifyListeners();
    return series;
  }

  /// Adds a new widget and persists the dashboard.
  Future<void> addWidget(StatWidgetConfig config) async {
    _widgets = [..._widgets, config];
    notifyListeners();
    await _persist();
    await loadSeries(config.deviceId, config.metric, config.range);
  }

  /// Replaces an existing widget config and re-fetches its series.
  Future<void> updateWidget(StatWidgetConfig config) async {
    _widgets = [
      for (final w in _widgets)
        if (w.id == config.id) config else w,
    ];
    notifyListeners();
    await _persist();
    // Invalidate old cache entry and fetch new data.
    _seriesCache.remove(_cacheKey(config.deviceId, config.metric, config.range));
    await loadSeries(config.deviceId, config.metric, config.range);
  }

  /// Removes a widget by [id] and persists the dashboard.
  Future<void> removeWidget(String id) async {
    _widgets = _widgets.where((w) => w.id != id).toList();
    notifyListeners();
    await _persist();
  }

  /// Reorders widgets according to the given list of [ids].
  Future<void> reorderWidgets(List<String> ids) async {
    final map = {for (final w in _widgets) w.id: w};
    _widgets = ids.where(map.containsKey).map((id) => map[id]!).toList();
    notifyListeners();
    await _persist();
  }

  /// Invalidates cache for a specific widget and re-fetches.
  Future<void> refreshSeries(
    String deviceId,
    MetricType metric,
    TimeRange range,
  ) async {
    _seriesCache.remove(_cacheKey(deviceId, metric, range));
    await loadSeries(deviceId, metric, range);
  }

  // ---------------------------------------------------------------------------
  // Grouped access
  // ---------------------------------------------------------------------------

  /// Widgets grouped by [deviceId] for the collapsible card UI.
  Map<String, List<StatWidgetConfig>> get widgetsByDevice {
    final map = <String, List<StatWidgetConfig>>{};
    for (final w in _widgets) {
      (map[w.deviceId] ??= []).add(w);
    }
    return map;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _cacheKey(String deviceId, MetricType metric, TimeRange range) =>
      '$deviceId:${metric.name}:${range.name}';

  /// Returns the cached series matching a widget config, or null.
  MetricSeries? seriesFor(StatWidgetConfig config) =>
      _seriesCache[_cacheKey(config.deviceId, config.metric, config.range)];

  Future<void> _persist() async {
    final roomId = _currentRoomId;
    if (roomId == null) return;
    await _repo.saveDashboard(roomId, _widgets);
  }
}
