import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../shared/widgets/detail_section_card.dart';
import 'cct_helpers.dart';
import 'cob_led_cct_gradient_slider.dart';

/// Section card showing the current colour temperature and a gradient slider.
class CobLedCctColourTempSection extends StatelessWidget {
  const CobLedCctColourTempSection({
    super.key,
    required this.value,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
  });

  /// Normalised colour temperature in [0.0 … 1.0] (0 = 2700 K, 1 = 6500 K).
  final double value;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final ctK = (2700 + (value * (6500 - 2700))).round();
    final tempColor = cctTempToColor(ctK);

    return DetailSectionCard(
      title: context.l10n.cobLedCctSectionColourTemp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tempColor.withValues(alpha: 0.18),
                  border: Border.all(color: tempColor, width: 2),
                ),
                child: Center(
                  child:
                      Icon(Icons.wb_sunny_outlined, color: tempColor, size: 22),
                ),
              ),
              AppSpacing.gapHMd,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$ctK K',
                    style: const TextStyle(
                      fontFamily: 'ShareTech',
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    cctTempLabel(ctK),
                    style: const TextStyle(
                      fontFamily: 'ShareTech',
                      fontSize: AppFontSizes.body,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.gapX2l,
          CobLedCctGradientSlider(
            value: value,
            onChangeStart: onChangeStart,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
          AppSpacing.gapSm,
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '2700 K',
                style: TextStyle(
                  fontFamily: 'ShareTech',
                  fontSize: AppFontSizes.xs,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '6500 K',
                style: TextStyle(
                  fontFamily: 'ShareTech',
                  fontSize: AppFontSizes.xs,
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
