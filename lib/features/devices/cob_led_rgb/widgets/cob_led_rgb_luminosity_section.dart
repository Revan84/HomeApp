import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../shared/widgets/detail_section_card.dart';

/// Section card showing the brightness percentage and a draggable slider.
///
/// Slider local state lives in the parent — [brightness] is the current
/// display value, and the three callbacks mirror [Slider]'s own callbacks.
class CobLedRgbLuminositySection extends StatelessWidget {
  const CobLedRgbLuminositySection({
    super.key,
    required this.brightness,
    required this.color,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
  });

  /// Current brightness in [0, 1].
  final double brightness;

  /// Accent colour used for the slider track and thumb.
  final Color color;

  final VoidCallback onChangeStart;
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
                    activeTrackColor: color,
                    thumbColor: color,
                    inactiveTrackColor: AppColors.border.withValues(alpha: 0.4),
                    overlayColor: color.withValues(alpha: 0.12),
                  ),
                  child: Slider(
                    value: brightness,
                    onChangeStart: (_) => onChangeStart(),
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
