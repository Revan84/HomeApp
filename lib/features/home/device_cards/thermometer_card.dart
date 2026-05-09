import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/device_accent_scope.dart';
import '../../../../core/utils/time_label.dart';
import '../../../../domain/entities/equipment.dart';
import '../../../../domain/entities/live_state.dart';
import 'card_shared.dart';

class ThermometerCard extends StatelessWidget {
  const ThermometerCard({
    super.key,
    required this.equipment,
    required this.liveState,
    required this.onTap,
    this.onToggle,
  });

  final Equipment equipment;
  final LiveState? liveState;
  final VoidCallback onTap;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final temp = liveState?.temperatureC;
    final humidity = liveState?.humidity;
    final trendT = liveState?.trendTemperature ?? 0;
    final online = liveState?.online ?? false;
    final isOn = liveState?.output != false;
    final toggling = liveState?.toggling ?? false;
    final updatedLabel = ageLabel(context, liveState?.lastUpdatedAt);

    return CardShell(
      onTap: onTap,
      accentColor: AppColors.thermometerAccent,
      online: online,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            icon: Icons.thermostat_rounded,
            name: equipment.name,
          ),
          AppSpacing.gapLg,
          const MetaLabel('Live'),
          AppSpacing.gapXxs,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                temp != null ? '${temp.toStringAsFixed(1)} °C' : '— °C',
                style: TextStyle(
                  color: AppColors.thermometerAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: AppFontSizes.display,
                ),
              ),
              if (trendT != 0) ...[
                AppSpacing.gapHXs,
                Icon(
                  trendT > 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: trendT > 0 ? Colors.orange : Colors.lightBlueAccent,
                ),
              ],
            ],
          ),
          if (humidity != null) ...[
            AppSpacing.gapSm,
            const MetaLabel('Average'),
            AppSpacing.gapXxs,
            Text(
              '${humidity.toStringAsFixed(0)} %',
              style: TextStyle(
                color: DeviceAccentScope.of(context),
                fontWeight: FontWeight.w600,
                fontSize: AppFontSizes.md,
              ),
            ),
          ],
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
