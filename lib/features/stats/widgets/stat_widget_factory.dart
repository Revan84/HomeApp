import 'package:flutter/material.dart';

import '../../../domain/models/metric_series.dart';
import '../../../domain/models/stat_widget.dart';
import '../../../domain/models/time_range.dart';
import 'stat_chart_widget.dart';
import 'stat_history_widget.dart';
import 'stat_kpi_widget.dart';
import 'stat_table_widget.dart';

/// Single entry point that maps a [StatWidgetConfig] to the correct renderer.
class StatWidgetFactory {
  const StatWidgetFactory._();

  /// Builds the appropriate stat widget for [config] using [series] data.
  ///
  /// [onRangeChanged] is forwarded to chart widgets so the parent can
  /// re-fetch data when the user picks a different time range.
  static Widget build(
    StatWidgetConfig config,
    MetricSeries? series, {
    ValueChanged<TimeRange>? onRangeChanged,
  }) {
    if (series == null || series.points.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'Loading…',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    switch (config.type) {
      case StatWidgetType.chart:
        return StatChartWidget(
          series: series,
          selectedRange: config.range,
          chartType: (config.extra?['chartType'] as String?) ?? 'line',
          onRangeChanged: onRangeChanged,
        );

      case StatWidgetType.table:
        return StatTableWidget(series: series);

      case StatWidgetType.history:
        return StatHistoryWidget(series: series);

      case StatWidgetType.kpi:
        return StatKpiWidget(series: series);
    }
  }
}
