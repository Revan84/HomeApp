import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';

/// A labeled slider row with a percentage display on the right.
class WledSliderRow extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final Color activeColor;

  const WledSliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'ShareTech',
              fontSize: 12.0,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor.withValues(alpha: 0.85),
              inactiveTrackColor: AppColors.border,
              thumbColor: activeColor,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 3,
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 14),
              overlayColor: activeColor.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value.clamp(0.0, 1.0),
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '${(value * 100).round()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'ShareTech',
              fontSize: AppFontSizes.sm,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
