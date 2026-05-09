import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/time_label.dart';
import '../../../../domain/entities/live_point.dart';
import '../../../../domain/entities/live_state.dart';
import '../../shared/widgets/detail_section_card.dart';
import '../../shared/widgets/device_stat_box.dart';
import 'hygrometer_comfort_range_bar.dart';

/// The "LIVE" section card for the hygrometer detail screen.
///
/// Displays the current humidity reading, trend indicator, comfort bar,
/// and aggregated stats (avg week/month, comfort label, today min/max).
class HygrometerLiveSection extends StatelessWidget {
  const HygrometerLiveSection({
    super.key,
    required this.humidity,
    required this.trendH,
    required this.liveState,
    required this.todayHistory,
    required this.weekHistory,
    required this.monthHistory,
  });

  final double? humidity;
  final double trendH;
  final LiveState? liveState;
  final List<LivePoint> todayHistory;
  final List<LivePoint> weekHistory;
  final List<LivePoint> monthHistory;

  @override
  Widget build(BuildContext context) {
    // ── Derived stats ─────────────────────────────────────────────────────
    final todayValues = todayHistory.map((p) => p.powerW).toList();
    final double? todayMin = todayValues.isEmpty
        ? null
        : todayValues.reduce((a, b) => a < b ? a : b).toDouble();
    final double? todayMax = todayValues.isEmpty
        ? null
        : todayValues.reduce((a, b) => a > b ? a : b).toDouble();

    final double? avgWeek = weekHistory.isEmpty
        ? null
        : weekHistory.map((p) => p.powerW).reduce((a, b) => a + b) /
            weekHistory.length;
    final double? avgMonth = monthHistory.isEmpty
        ? null
        : monthHistory.map((p) => p.powerW).reduce((a, b) => a + b) /
            monthHistory.length;

    return DetailSectionCard(
      title: context.l10n.detailSectionLive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Big value + trend arrow ───────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                humidity != null ? '${humidity!.toStringAsFixed(0)} %' : '— %',
                style: const TextStyle(
                  fontSize: AppFontSizes.kpi,
                  fontWeight: FontWeight.w700,
                  color: AppColors.hygrometerAccent,
                ),
              ),
              if (trendH != 0) ...[
                AppSpacing.gapHSm,
                Icon(
                  trendH > 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 20,
                  color: trendH > 0 ? Colors.orange : AppColors.hygrometerAccent,
                ),
                AppSpacing.gapHXxs,
                Text(
                  trendH > 0 ? context.l10n.detailTrendUpward : context.l10n.detailTrendDownward,
                  style: const TextStyle(
                    fontSize: AppFontSizes.sm,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),

          // ── Last updated label ────────────────────────────────────────
          if (liveState?.lastUpdatedAt != null) ...[
            AppSpacing.gapXxs,
            Text(
              ageLabel(context, liveState!.lastUpdatedAt),
              style: const TextStyle(
                fontSize: AppFontSizes.sm,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          // ── Comfort range bar ─────────────────────────────────────────
          if (humidity != null) ...[
            AppSpacing.gapX2l,
            HygrometerComfortRangeBar(humidity: humidity!),
            AppSpacing.gapXs,
            Text(
              context.l10n.hygrometerComfortRangeLabel,
              style: TextStyle(
                fontSize: AppFontSizes.xs,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          // ── Avg week / avg month / comfort label ──────────────────────
          if (avgWeek != null || avgMonth != null || humidity != null) ...[
            AppSpacing.gapX2l,
            Row(
              children: [
                if (avgWeek != null) ...[
                  DeviceStatBox(
                    label: context.l10n.detailStatAvgWeek,
                    value: '${avgWeek.toStringAsFixed(0)} %',
                  ),
                  AppSpacing.gapHXl,
                ],
                if (avgMonth != null) ...[
                  DeviceStatBox(
                    label: context.l10n.detailStatAvgMonth,
                    value: '${avgMonth.toStringAsFixed(0)} %',
                  ),
                  AppSpacing.gapHXl,
                ],
                if (humidity != null)
                  DeviceStatBox(
                    label: context.l10n.hygrometerStatComfort,
                    value: comfortLabel(humidity!),
                    valueColor: comfortColor(humidity!),
                  ),
              ],
            ),
          ],

          // ── Today MIN / MAX ───────────────────────────────────────────
          if (todayMin != null) ...[
            AppSpacing.gapX2l,
            Row(
              children: [
                DeviceStatBox(
                  label: context.l10n.detailStatMin,
                  value: '${todayMin.toStringAsFixed(0)} %',
                  valueColor: AppColors.hygrometerAccent,
                ),
                AppSpacing.gapHXl,
                DeviceStatBox(
                  label: context.l10n.detailStatMax,
                  value: '${todayMax!.toStringAsFixed(0)} %',
                  valueColor: Colors.orange,
                ),
                AppSpacing.gapHXl,
                DeviceStatBox(label: '', value: context.l10n.detailStatToday),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
