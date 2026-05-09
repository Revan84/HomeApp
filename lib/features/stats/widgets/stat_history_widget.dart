import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/metric_series.dart';
import '../domain/metric_type.dart';

/// Compact chronological list showing each data point with an event icon,
/// timestamp, and value in green.
///
/// Transparent background — the parent card provides the surface.
class StatHistoryWidget extends StatelessWidget {
  final MetricSeries series;

  const StatHistoryWidget({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final points = series.points;
    if (points.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(context.l10n.noData,
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final locale = Localizations.localeOf(context).toLanguageTag();
    final metricType = series.type;

    // Show latest first.
    final reversed = points.reversed.toList();

    return SizedBox(
      height: 240,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: reversed.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          color: AppColors.border.withValues(alpha: 0.2),
        ),
        itemBuilder: (context, index) {
          final point = reversed[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                // Event icon
                Icon(
                  _eventIcon(metricType, point.value),
                  size: 16,
                  color: AppColors.primary,
                ),
                AppSpacing.gapHMd,
                // Timestamp
                Text(
                  DateFormat('dd/MM HH:mm', locale).format(point.timestamp),
                  style: const TextStyle(
                    fontSize: AppFontSizes.sm,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                // Value in green
                Text(
                  metricType.formatValue(point.value),
                  style: const TextStyle(
                    fontSize: AppFontSizes.body,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Picks an icon depending on the metric type and value.
  IconData _eventIcon(MetricType type, double value) {
    switch (type) {
      case MetricType.state:
        return value > 0 ? Icons.toggle_on : Icons.toggle_off;
      case MetricType.temperature:
        return Icons.thermostat;
      case MetricType.humidity:
        return Icons.water_drop;
      case MetricType.power:
        return Icons.bolt;
      case MetricType.energy:
        return Icons.electrical_services;
      case MetricType.brightness:
        return Icons.light_mode;
    }
  }
}
