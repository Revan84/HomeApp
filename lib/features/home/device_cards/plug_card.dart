import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/time_label.dart';
import '../../../../domain/entities/equipment.dart';
import '../../../../domain/entities/live_state.dart';
import 'card_shared.dart';

class PlugCard extends StatelessWidget {
  const PlugCard({
    super.key,
    required this.equipment,
    required this.liveState,
    required this.onTap,
    required this.onToggle,
  });

  final Equipment equipment;
  final LiveState? liveState;
  final VoidCallback onTap;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final isOn = liveState?.output == true;
    final online = liveState?.online ?? false;
    final toggling = liveState?.toggling ?? false;
    final powerW = liveState?.powerW;
    final energyKwh = liveState != null
        ? (liveState!.energyWh ?? 0).toDouble() / 1000.0
        : null;
    final trend = liveState?.trendPower ?? 0;
    final updatedLabel = ageLabel(context, liveState?.lastUpdatedAt);

    return CardShell(
      onTap: onTap,
      accentColor: AppColors.plugAccent,
      online: online,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            icon: Icons.bolt_rounded,
            name: equipment.name,
          ),
          AppSpacing.gapMd,
          const MetaLabel('Live'),
          AppSpacing.gapXxs,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                powerW != null ? '${powerW.toStringAsFixed(0)} W' : '— W',
                style: TextStyle(
                  fontFamily: 'ShareTech',
                  color: AppColors.plugAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: AppFontSizes.display,
                ),
              ),
              if (trend != 0) ...[
                AppSpacing.gapHXs,
                Icon(
                  trend > 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: trend > 0 ? AppColors.success : AppColors.danger,
                ),
              ],
            ],
          ),
          AppSpacing.gapSm,
          const MetaLabel('Total'),
          AppSpacing.gapXxs,
          Text(
            energyKwh != null ? '${energyKwh.toStringAsFixed(1)} KWH' : '— KWH',
            style: TextStyle(
              fontFamily: 'ShareTech',
              color: AppColors.plugAccent,
              fontWeight: FontWeight.w600,
              fontSize: AppFontSizes.display,
            ),
          ),
        ],
      ),
      footer: CardFooter(
        updatedLabel: updatedLabel,
        isOn: isOn,
        toggling: toggling,
        canToggle: equipment.showToggle,
        onToggle: onToggle,
      ),
    );
  }
}
