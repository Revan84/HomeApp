import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/device_accent_scope.dart';
import '../../../../core/utils/time_label.dart';
import '../../../../domain/entities/equipment.dart';
import '../../../../domain/entities/live_state.dart';
import 'card_shared.dart';

class HygrometerCard extends StatelessWidget {
  const HygrometerCard({
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
    final humidity = liveState?.humidity;
    final temp = liveState?.temperatureC;
    final online = liveState?.online ?? false;
    final isOn = liveState?.output != false;
    final toggling = liveState?.toggling ?? false;
    final updatedLabel = ageLabel(context, liveState?.lastUpdatedAt);

    return CardShell(
      onTap: onTap,
      accentColor: AppColors.hygrometerAccent,
      online: online,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(
            icon: Icons.water_drop_outlined,
            name: equipment.name,
          ),
          AppSpacing.gapLg,
          const MetaLabel('Humidity'),
          AppSpacing.gapXxs,
          Text(
            humidity != null ? '${humidity.toStringAsFixed(0)} %' : '— %',
            style: TextStyle(
              fontFamily: 'ShareTech',
              color: AppColors.hygrometerAccent,
              fontWeight: FontWeight.w700,
              fontSize: AppFontSizes.display,
            ),
          ),
          if (temp != null) ...[
            AppSpacing.gapSm,
            const MetaLabel('Temperature'),
            AppSpacing.gapXxs,
            Text(
              '${temp.toStringAsFixed(1)} °C',
              style: TextStyle(
                fontFamily: 'ShareTech',
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
