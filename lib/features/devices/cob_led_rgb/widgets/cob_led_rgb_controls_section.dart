import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../shared/widgets/detail_section_card.dart';
import 'cob_led_rgb_effect_dropdown.dart';

/// Section card exposing WLED-specific controls: effect, speed, and intensity.
///
/// Slider local state lives in the parent — [speed] and [intensity] are the
/// current display values (0–1). [onDragStart] is called at the start of any
/// slider interaction so the parent can suppress API-driven resets.
class CobLedRgbControlsSection extends StatelessWidget {
  const CobLedRgbControlsSection({
    super.key,
    required this.speed,
    required this.intensity,
    required this.effectId,
    required this.effectNames,
    required this.accentColor,
    required this.isLoadingEffects,
    required this.onDragStart,
    required this.onSpeedChanged,
    required this.onSpeedEnd,
    required this.onIntensityChanged,
    required this.onIntensityEnd,
    required this.onEffectChanged,
  });

  final double speed;
  final double intensity;
  final int effectId;
  final List<String> effectNames;
  final Color accentColor;

  /// True while the initial effects fetch is in-flight.
  final bool isLoadingEffects;

  final VoidCallback onDragStart;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onSpeedEnd;
  final ValueChanged<double> onIntensityChanged;
  final ValueChanged<double> onIntensityEnd;
  final ValueChanged<int> onEffectChanged;

  @override
  Widget build(BuildContext context) {
    final sliderTheme = SliderTheme.of(context).copyWith(
      trackHeight: 6,
      activeTrackColor: accentColor,
      inactiveTrackColor: AppColors.border.withValues(alpha: 0.35),
      thumbColor: Colors.white,
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 10,
        elevation: 4,
      ),
      overlayColor: accentColor.withValues(alpha: 0.12),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
    );

    return DetailSectionCard(
      title: context.l10n.cobLedSectionWledControls,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Effect dropdown ─────────────────────────────────────────────
          Text(
            context.l10n.cobLedEffectLabel,
            style: const TextStyle(
              fontSize: AppFontSizes.body,
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.gapXs,
          CobLedRgbEffectDropdown(
            selectedIndex: effectId,
            effectNames: effectNames,
            isLoading: isLoadingEffects,
            onChanged: onEffectChanged,
          ),

          AppSpacing.gapX2l,

          // ── Speed slider ────────────────────────────────────────────────
          _SliderRow(
            label: context.l10n.cobLedSpeedLabel,
            value: speed,
            sliderTheme: sliderTheme,
            onChangeStart: onDragStart,
            onChanged: onSpeedChanged,
            onChangeEnd: onSpeedEnd,
          ),

          AppSpacing.gapMd,

          // ── Intensity slider ────────────────────────────────────────────
          _SliderRow(
            label: context.l10n.cobLedIntensityLabel,
            value: intensity,
            sliderTheme: sliderTheme,
            onChangeStart: onDragStart,
            onChanged: onIntensityChanged,
            onChangeEnd: onIntensityEnd,
          ),
        ],
      ),
    );
  }
}

// ── Internal helper ───────────────────────────────────────────────────────────

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.sliderTheme,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String label;
  final double value;
  final SliderThemeData sliderTheme;
  final VoidCallback onChangeStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: AppFontSizes.body,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(value * 100).round()} %',
              style: const TextStyle(
                fontSize: AppFontSizes.body,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: sliderTheme,
          child: Slider(
            value: value,
            onChangeStart: (_) => onChangeStart(),
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ],
    );
  }
}
