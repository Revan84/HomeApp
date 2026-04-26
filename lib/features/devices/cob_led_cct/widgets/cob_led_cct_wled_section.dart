import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../shared/widgets/detail_section_card.dart';
import 'cob_led_cct_effect_dropdown.dart';

/// Section card for WLED controls: effect selector, speed slider, audio toggle.
class CobLedCctWledSection extends StatelessWidget {
  const CobLedCctWledSection({
    super.key,
    required this.effectId,
    required this.effectNames,
    required this.speed,
    required this.audioReactive,
    required this.accentColor,
    required this.onEffectChanged,
    required this.onSpeedChangeStart,
    required this.onSpeedChanged,
    required this.onSpeedChangeEnd,
    required this.onAudioChanged,
  });

  final int effectId;
  final List<String> effectNames;

  /// Normalised speed in [0.0 … 1.0].
  final double speed;
  final bool audioReactive;
  final Color accentColor;

  final void Function(int) onEffectChanged;
  final ValueChanged<double> onSpeedChangeStart;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onSpeedChangeEnd;
  final void Function(bool) onAudioChanged;

  @override
  Widget build(BuildContext context) {
    return DetailSectionCard(
      title: context.l10n.cobLedSectionWledControls,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Effect',
            style: TextStyle(
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
              const Text(
                'Speed',
                style: TextStyle(
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
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accentColor,
              thumbColor: accentColor,
              inactiveTrackColor: AppColors.border.withValues(alpha: 0.4),
              overlayColor: accentColor.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: speed,
              onChangeStart: onSpeedChangeStart,
              onChanged: onSpeedChanged,
              onChangeEnd: onSpeedChangeEnd,
            ),
          ),
          AppSpacing.gapMd,
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio Reactive',
                      style: TextStyle(
                        fontFamily: 'ShareTech',
                        fontSize: AppFontSizes.body,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'React to microphone input',
                      style: TextStyle(
                        fontFamily: 'ShareTech',
                        fontSize: AppFontSizes.xs,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: audioReactive,
                activeTrackColor: accentColor,
                activeThumbColor: Colors.white,
                onChanged: onAudioChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
