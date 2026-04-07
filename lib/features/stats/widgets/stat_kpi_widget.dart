import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/metric_series.dart';
import '../domain/metric_type.dart';

/// Displays the current (latest) value in large green type with
/// min / max / avg as a summary row underneath.
///
/// Transparent background — the parent card provides the surface.
class StatKpiWidget extends StatelessWidget {
  final MetricSeries series;

  const StatKpiWidget({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final points = series.points;
    final metricType = series.type;

    if (points.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(context.l10n.statsNoData,
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final current = points.last.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 4),
        // Current value (hero) in green
        Text(
          metricType.formatValue(current),
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          metricType.label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        // Min / Max / Avg row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Min / Max / Avg are universal abbreviations kept as-is.
            _kpiCell('Min', series.min, metricType),
            _kpiCell('Max', series.max, metricType),
            _kpiCell('Avg', series.avg, metricType),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _kpiCell(String label, double? value, MetricType metricType) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value != null ? metricType.formatValue(value) : '\u2014',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}
