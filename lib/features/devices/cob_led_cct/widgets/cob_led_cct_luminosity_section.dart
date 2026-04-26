import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../shared/widgets/detail_section_card.dart';

/// Section card showing the current brightness percentage and a slider.
class CobLedCctLuminositySection extends StatelessWidget {
  const CobLedCctLuminositySection({
    super.key,
    required this.brightness,
    required this.accentColor,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
  });

  /// Normalised brightness in [0.0 … 1.0].
  final double brightness;
  final Color accentColor;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return DetailSectionCard(
      title: context.l10n.cobLedSectionLuminosity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${(brightness * 100).round()} %',
            style: const TextStyle(
              fontFamily: 'ShareTech',
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.gapMd,
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined,
                  size: 16, color: AppColors.textSecondary),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: accentColor,
                    thumbColor: accentColor,
                    inactiveTrackColor:
                        AppColors.border.withValues(alpha: 0.4),
                    overlayColor: accentColor.withValues(alpha: 0.12),
                  ),
                  child: Slider(
                    value: brightness,
                    onChangeStart: onChangeStart,
                    onChanged: onChanged,
                    onChangeEnd: onChangeEnd,
                  ),
                ),
              ),
              const Icon(Icons.wb_sunny_rounded,
                  size: 22, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}
