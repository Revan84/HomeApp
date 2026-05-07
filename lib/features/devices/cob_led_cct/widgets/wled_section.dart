import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../shared/widgets/detail_section_card.dart';
import 'effect_dropdown.dart';
import 'gradient_slider.dart';

/// Section card for WLED controls: effect selector and speed slider.
class CobLedCctWledSection extends StatelessWidget {
  const CobLedCctWledSection({
    super.key,
    required this.effectId,
    required this.effectNames,
    required this.speed,
    required this.accentColor,
    required this.onEffectChanged,
    required this.onSpeedChangeStart,
    required this.onSpeedChanged,
    required this.onSpeedChangeEnd,
  });

  final int effectId;
  final List<String> effectNames;

  /// Normalised speed in [0.0 … 1.0].
  final double speed;
  final Color accentColor;

  final void Function(int) onEffectChanged;
  final ValueChanged<double> onSpeedChangeStart;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onSpeedChangeEnd;

  @override
  Widget build(BuildContext context) {
    return DetailSectionCard(
      title: context.l10n.cobLedSectionWledControls,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.cobLedEffectLabel,
            style: const TextStyle(
              fontFamily: 'ShareTech',
              fontSize: AppFontSizes.body,
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.gapXs,
          CobLedCctEffectDropdown(
            selectedIndex: effectId,
            effectNames: effectNames,
            accentColor: accentColor,
            onChanged: onEffectChanged,
          ),
          AppSpacing.gapX2l,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.cobLedSpeedLabel,
                style: const TextStyle(
                  fontFamily: 'ShareTech',
                  fontSize: AppFontSizes.body,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(speed * 100).round()} %',
                style: const TextStyle(
                  fontFamily: 'ShareTech',
                  fontSize: AppFontSizes.body,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          CobLedCctAccentSlider(
            value: speed,
            accentColor: accentColor,
            activeTrackColor: accentColor,
            inactiveTrackColor: AppColors.inactiveSlider,
            onChangeStart: onSpeedChangeStart,
            onChanged: onSpeedChanged,
            onChangeEnd: onSpeedChangeEnd,
          ),
        ],
      ),
    );
  }
}
