import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import 'cob_led_effect_dropdown.dart';
import 'detail_section_card.dart';

/// Shared WLED controls section for COB LED devices.
///
/// Always renders: effect selector + speed slider.
/// Renders intensity slider only when [intensity] is non-null (RGB only).
class CobLedWledSection extends StatelessWidget {
  const CobLedWledSection({
    super.key,
    required this.effectId,
    required this.effectNames,
    required this.speed,
    required this.accentColor,
    required this.onDragStart,
    required this.onSpeedChanged,
    required this.onSpeedEnd,
    required this.onEffectChanged,
    this.intensity,
    this.onIntensityChanged,
    this.onIntensityEnd,
    this.isLoadingEffects = false,
  });

  final int effectId;
  final List<String> effectNames;

  /// Normalised speed in [0.0 … 1.0].
  final double speed;

  /// Normalised intensity in [0.0 … 1.0]. Pass null to hide the slider (CCT).
  final double? intensity;

  final Color accentColor;

  /// True while the initial effects fetch is in-flight.
  final bool isLoadingEffects;

  final VoidCallback onDragStart;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<double> onSpeedEnd;
  final ValueChanged<double>? onIntensityChanged;
  final ValueChanged<double>? onIntensityEnd;
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
          // ── Effect selector ─────────────────────────────────────────────
          Text(
            context.l10n.cobLedEffectLabel,
            style: const TextStyle(
              fontSize: AppFontSizes.body,
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.gapXs,
          CobLedEffectDropdown(
            selectedIndex: effectId,
            effectNames: effectNames,
            accentColor: accentColor,
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

          // ── Intensity slider (RGB only) ──────────────────────────────────
          if (intensity != null) ...[
            AppSpacing.gapMd,
            _SliderRow(
              label: context.l10n.cobLedIntensityLabel,
              value: intensity!,
              sliderTheme: sliderTheme,
              onChangeStart: onDragStart,
              onChanged: onIntensityChanged!,
              onChangeEnd: onIntensityEnd!,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Slider row ────────────────────────────────────────────────────────────────

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
