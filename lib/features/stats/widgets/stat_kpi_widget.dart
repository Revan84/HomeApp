import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/theme/app_spacing.dart';
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
              style: const TextStyle(fontFamily: 'ShareTech', color: AppColors.textSecondary)),
        ),
      );
    }

    final current = points.last.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppSpacing.gapXs,
        // Current value (hero) in green
        Text(
          metricType.formatValue(current),
          style: const TextStyle(
            fontFamily: 'ShareTech',
            fontSize: AppFontSizes.kpi,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        AppSpacing.gapXxs,
        Text(
          metricType.label,
          style: const TextStyle(fontFamily: 'ShareTech', fontSize: 12.0, color: AppColors.textSecondary),
        ),
        AppSpacing.gapXl,
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
        AppSpacing.gapXs,
      ],
    );
  }

  Widget _kpiCell(String label, double? value, MetricType metricType) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'ShareTech', fontSize: AppFontSizes.xs, color: AppColors.textSecondary),
        ),
        AppSpacing.gapXxs,
        Text(
          value != null ? metricType.formatValue(value) : '\u2014',
          style: const TextStyle(
            fontFamily: 'ShareTech',
            fontSize: AppFontSizes.md,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
