import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../shared/widgets/detail_section_card.dart';
import 'cct_helpers.dart';
import 'gradient_slider.dart';

/// Combined card showing colour temperature and luminosity, separated by a
/// divider — matches the screen design where both controls live in one card.
class CobLedCctColourTempSection extends StatelessWidget {
  const CobLedCctColourTempSection({
    super.key,
    // Colour temperature
    required this.value,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
    // Luminosity
    required this.brightness,
    required this.accentColor,
    required this.onBrightnessChangeStart,
    required this.onBrightnessChanged,
    required this.onBrightnessChangeEnd,
  });

  /// Normalised colour temperature [0 = 2700 K, 1 = 6500 K].
  final double value;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  /// Normalised brightness [0.0 … 1.0].
  final double brightness;
  final Color accentColor;
  final ValueChanged<double> onBrightnessChangeStart;
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<double> onBrightnessChangeEnd;

  // Why: shared style for the four K-axis tick labels — keeps loop concise.
  static const _kAxisLabelStyle = TextStyle(
    fontSize: AppFontSizes.xs,
    color: AppColors.textSecondary,
  );

  /// Tick values shown beneath the gradient slider.
  static const _kAxisTicks = <int>[2700, 4000, 5500, 6500];

  @override
  Widget build(BuildContext context) {
    final ctK = (2700 + (value * (6500 - 2700))).round();
    final tempColor = cctTempToColor(ctK);

    return DetailSectionCard(
      title: context.l10n.cobLedCctSectionColourTemp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Temperature indicator ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.card,
                  border: Border.all(color: tempColor, width: 1),
                ),
                child: Center(
                  child: Icon(
                    Icons.wb_sunny_outlined,
                    color: tempColor,
                    size: 22,
                  ),
                ),
              ),
              AppSpacing.gapHMd,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$ctK K',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: tempColor,
                    ),
                  ),
                  Text(
                    cctTempLabel(context, ctK),
                    style: const TextStyle(
                      fontSize: AppFontSizes.body,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          AppSpacing.gapX2l,

          // ── Warm / Cold axis labels ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.cobLedCctWarm,
                style: const TextStyle(
                  fontSize: AppFontSizes.xs,
                  color: AppColors.cobLedCctAccent,
                ),
              ),
              Text(
                context.l10n.cobLedCctCold,
                style: const TextStyle(
                  fontSize: AppFontSizes.xs,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          // ── Gradient slider ────────────────────────────────────────────
          CobLedCctGradientSlider(
            value: value,
            onChangeStart: onChangeStart,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),

          AppSpacing.gapSm,

          // ── K tick labels (looped) ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final k in _kAxisTicks)
                Text('${k}K', style: _kAxisLabelStyle),
            ],
          ),

          AppSpacing.gapX6l,
          const Divider(height: 1, color: AppColors.border, thickness: 0.5),
          AppSpacing.gapX2l,

          // ── Luminosity ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.cobLedSectionLuminosity,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSizes.sectionTitle,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${(brightness * 100).round()} %',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppFontSizes.sectionTitle,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          Row(
            children: [
              const Icon(
                Icons.wb_sunny_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              Expanded(
                child: CobLedCctAccentSlider(
                  value: brightness,
                  accentColor: accentColor,
                  activeTrackColor: accentColor,
                  inactiveTrackColor: AppColors.card,
                  onChangeStart: onBrightnessChangeStart,
                  onChanged: onBrightnessChanged,
                  onChangeEnd: onBrightnessChangeEnd,
                ),
              ),
              const Icon(
                Icons.wb_sunny_rounded,
                size: 22,
                color: AppColors.cobLedCctAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
