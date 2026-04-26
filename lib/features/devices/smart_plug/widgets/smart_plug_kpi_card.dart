import 'package:flutter/material.dart';

import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/device_accent_scope.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';

// ─── SmartPlugLiveData ────────────────────────────────────────────────────────
/// Display model for the KPI card — computed from [LiveState] + kWh price.

class SmartPlugLiveData {
  final String watts;
  final String costPerHour;
  final String costToday; // derived from today's history, not device total
  final String kwhCumulated;
  final int trendPower; // -1 falling · 0 stable · +1 rising

  const SmartPlugLiveData({
    required this.watts,
    required this.costPerHour,
    required this.costToday,
    required this.kwhCumulated,
    required this.trendPower,
  });
}

// ─── KPI loading placeholder ─────────────────────────────────────────────────

class SmartPlugKpiLoading extends StatelessWidget {
  const SmartPlugKpiLoading({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
    variant: AppCardVariant.card,
    child: const SizedBox(
      height: 56,
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

// ─── KPI card ─────────────────────────────────────────────────────────────────

class SmartPlugKpiCard extends StatelessWidget {
  final SmartPlugLiveData live;
  final bool isOffline;

  /// Current kWh price shown next to the edit icon.
  final double kwhPrice;

  /// Callback to open the kWh price edit dialog.
  final VoidCallback onEditKwhPrice;

  const SmartPlugKpiCard({
    super.key,
    required this.live,
    required this.kwhPrice,
    required this.onEditKwhPrice,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accent = DeviceAccentScope.of(context);
    final valueColor = isOffline ? AppColors.textSecondary : accent;
    final costColor = isOffline ? AppColors.textSecondary : const Color(0xFFF0B429);
    // Rising = red (costs more), falling = accent (saving power), offline = grey.
    final arrowColor = isOffline
        ? AppColors.textSecondary
        : (live.trendPower > 0 ? AppColors.danger : accent);

    return AppCard(
      variant: AppCardVariant.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Watts  [fixed arrow slot]  cost/h  ···  kWh price [edit] ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${live.watts} ${l10n.smartPlugKpiUnit}',
                style: TextStyle(
                  fontFamily: 'ShareTech',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: valueColor,
                ),
              ),
              // Fixed-width slot — prevents cost/h from shifting
              // when the trend arrow appears or disappears.
              SizedBox(
                width: 20,
                child: live.trendPower != 0
                    ? Icon(
                        live.trendPower > 0
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 14,
                        color: arrowColor,
                      )
                    : null,
              ),
              Text(
                l10n.smartPlugCostPerHour(live.costPerHour),
                style: TextStyle(
                  fontFamily: 'ShareTech',
                  fontSize: AppFontSizes.body,
                  color: costColor,
                ),
              ),
              const Spacer(),
              // kWh price badge — tap to edit
              GestureDetector(
                onTap: onEditKwhPrice,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${kwhPrice.toStringAsFixed(2)} €/kWh',
                      style: const TextStyle(
                        fontFamily: 'ShareTech',
                        fontSize: AppFontSizes.xs,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.gapHXs,
                    const Icon(
                      Icons.edit_outlined,
                      size: 11,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: AppColors.surface, height: AppSpacing.x5l),
          // ── Cost today (reset midnight)  ·  kWh cumulated ────────────
          Row(
            children: [
              Text(
                l10n.smartPlugCostToday(live.costToday),
                style: TextStyle(
                  fontFamily: 'ShareTech',
                  fontSize: AppFontSizes.sm,
                  color: costColor,
                ),
              ),
              const Spacer(),
              Text(
                l10n.smartPlugKwhCumulated(live.kwhCumulated),
                style: const TextStyle(
                  fontFamily: 'ShareTech',
                  fontSize: AppFontSizes.sm,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
