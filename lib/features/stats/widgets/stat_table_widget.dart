import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../domain/metric_series.dart';
import '../domain/metric_type.dart';

/// Renders a scrollable list of date/value rows for a [MetricSeries].
///
/// Same scrolling pattern as [StatHistoryWidget]. Values in green,
/// labels in secondary gray. Transparent background.
class StatTableWidget extends StatelessWidget {
  final MetricSeries series;

  const StatTableWidget({super.key, required this.series});

  @override
  Widget build(BuildContext context) {
    final points = series.points;
    if (points.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(context.l10n.statsNoData,
              style: const TextStyle(fontFamily: 'ShareTech', color: AppColors.textSecondary)),
        ),
      );
    }

    final locale = Localizations.localeOf(context).toLanguageTag();
    final metricType = series.type;

    // Show latest first, limit to 50 rows.
    final visible = points.reversed.take(50).toList();

    return SizedBox(
      height: 240,
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                // "Date" is a universal abbreviation kept as-is.
                const Text('Date',
                    style: TextStyle(
                        fontFamily: 'ShareTech',
                        fontSize: AppFontSizes.sm,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                const Spacer(),
                Text(
                  '${metricType.label} (${metricType.unit})',
                  style: const TextStyle(
                      fontFamily: 'ShareTech',
                      fontSize: AppFontSizes.sm,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.3)),
          // Scrollable rows
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: visible.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: AppColors.border.withValues(alpha: 0.2),
              ),
              itemBuilder: (context, index) {
                final point = visible[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('dd/MM/yy HH:mm', locale)
                            .format(point.timestamp),
                        style: const TextStyle(
                            fontFamily: 'ShareTech', fontSize: AppFontSizes.sm, color: AppColors.textSecondary),
                      ),
                      const Spacer(),
                      Text(
                        metricType.formatValue(point.value),
                        style: const TextStyle(
                          fontFamily: 'ShareTech',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
