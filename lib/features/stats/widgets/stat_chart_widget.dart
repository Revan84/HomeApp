import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/chart_type.dart';
import '../../../domain/entities/history_window.dart';
import '../../../domain/entities/live_point.dart';
import '../domain/metric_series.dart';
import '../domain/metric_type.dart';
import '../domain/time_range.dart';
import '../../live/widgets/charts/line_chart/interactive_line_chart.dart';

/// Renders a chart (line, bar, or pie) for a [MetricSeries].
///
/// Header shows the current value in green + an expand icon.
/// Below: time range tabs (1D/1W/1M/1Y) + the chart itself.
class StatChartWidget extends StatefulWidget {
  final MetricSeries series;
  final TimeRange selectedRange;
  final ChartType chartType;
  final ValueChanged<TimeRange>? onRangeChanged;

  const StatChartWidget({
    super.key,
    required this.series,
    required this.selectedRange,
    this.chartType = ChartType.line,
    this.onRangeChanged,
  });

  @override
  State<StatChartWidget> createState() => _StatChartWidgetState();
}

class _StatChartWidgetState extends State<StatChartWidget> {
  late TimeRange _range;

  @override
  void initState() {
    super.initState();
    _range = widget.selectedRange;
  }

  @override
  void didUpdateWidget(covariant StatChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedRange != widget.selectedRange) {
      _range = widget.selectedRange;
    }
  }

  void _setRange(TimeRange range) {
    setState(() => _range = range);
    widget.onRangeChanged?.call(range);
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.series.points;
    if (points.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(
          child: Text(context.l10n.noData,
              style: const TextStyle(fontFamily: 'ShareTech', color: AppColors.textSecondary)),
        ),
      );
    }

    final currentValue = points.last.value;
    final metricType = widget.series.type;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- Header: current value (green) + expand icon --
        Row(
          children: [
            Text(
              metricType.formatValue(currentValue),
              style: const TextStyle(
                fontFamily: 'ShareTech',
                fontSize: AppFontSizes.display,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.open_in_full, size: 16, color: AppColors.textSecondary),
          ],
        ),
        AppSpacing.gapMd,
        // -- Time range tabs --
        _buildRangeChips(),
        AppSpacing.gapMd,
        // -- Chart --
        SizedBox(
          height: 180,
          child: _buildChart(),
        ),
      ],
    );
  }

  Widget _buildRangeChips() {
    return Row(
      children: TimeRange.values.map((r) {
        final selected = r == _range;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: ChoiceChip(
            label: Text(
              r.shortLabel,
              style: TextStyle(
                fontFamily: 'ShareTech',
                fontSize: AppFontSizes.xs,
                color: selected ? AppColors.bg : AppColors.textSecondary,
              ),
            ),
            selected: selected,
            selectedColor: AppColors.primary,
            backgroundColor: Colors.transparent,
            side: BorderSide(
              color: selected
                  ? AppColors.primary
                  : AppColors.border.withValues(alpha: 0.3),
            ),
            onSelected: (_) => _setRange(r),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChart() {
    switch (widget.chartType) {
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.pie:
        return _buildPieChart();
      case ChartType.line:
        return _buildLineChart();
    }
  }

  // ---------------------------------------------------------------------------
  // Line — reuse the existing InteractiveLineChart (CustomPaint-based)
  // ---------------------------------------------------------------------------

  HistoryWindow _toHistoryWindow(TimeRange range) {
    switch (range) {
      case TimeRange.day1:
        return HistoryWindow.d1;
      case TimeRange.week1:
        return HistoryWindow.w1;
      case TimeRange.month1:
        return HistoryWindow.m1;
      case TimeRange.year1:
        return HistoryWindow.y1;
      case TimeRange.max:
        return HistoryWindow.max;
    }
  }

  Widget _buildLineChart() {
    final series = widget.series;
    final metricType = series.type;

    final livePoints = series.points
        .map((p) => LivePoint(at: p.timestamp, powerW: p.value))
        .toList();

    return InteractiveLineChart(
      points: livePoints,
      window: _toHistoryWindow(_range),
      minY: series.min ?? 0,
      maxY: series.max ?? 100,
      height: 180,
      powerUnitLabel: metricType.unit,
    );
  }

  // ---------------------------------------------------------------------------
  // Bar — fl_chart
  // ---------------------------------------------------------------------------

  Widget _buildBarChart() {
    final points = widget.series.points;
    final step = (points.length / 20).ceil().clamp(1, points.length);
    final sampled = <int>[];
    for (int i = 0; i < points.length; i += step) {
      sampled.add(i);
    }

    return BarChart(
      BarChartData(
        barGroups: sampled.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: points[e.value].value,
                color: AppColors.primary,
                width: 8,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(3)),
              ),
            ],
          );
        }).toList(),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pie — fl_chart
  // ---------------------------------------------------------------------------

  Widget _buildPieChart() {
    final series = widget.series;
    final sections = <PieChartSectionData>[
      if (series.min != null)
        PieChartSectionData(
          value: series.min!,
          title: 'Min',
          color: AppColors.danger,
          titleStyle: const TextStyle(fontFamily: 'ShareTech', fontSize: AppFontSizes.xs, color: Colors.white),
          radius: 50,
        ),
      if (series.avg != null)
        PieChartSectionData(
          value: series.avg!,
          title: 'Avg',
          color: AppColors.primary,
          titleStyle: const TextStyle(fontFamily: 'ShareTech', fontSize: AppFontSizes.xs, color: Colors.white),
          radius: 50,
        ),
      if (series.max != null)
        PieChartSectionData(
          value: series.max!,
          title: 'Max',
          color: const Color(0xFF4FC3F7),
          titleStyle: const TextStyle(fontFamily: 'ShareTech', fontSize: AppFontSizes.xs, color: Colors.white),
          radius: 50,
        ),
    ];

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }
}
