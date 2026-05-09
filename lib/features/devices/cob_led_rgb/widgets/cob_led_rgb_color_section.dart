import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../shared/widgets/detail_section_card.dart';
import '../domain/rgb_color.dart';
import 'cob_led_rgb_color_wheel.dart';

/// Section card showing the current colour preview and the interactive
/// colour wheel.
class CobLedRgbColorSection extends StatelessWidget {
  const CobLedRgbColorSection({
    super.key,
    required this.color,
    required this.rgbColor,
    required this.onColorChanged,
  });

  /// The current colour as a Flutter [Color] (used for UI rendering).
  final Color color;

  /// The current colour in domain format (used to display hex/RGB labels).
  final RgbColor rgbColor;

  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    return DetailSectionCard(
      title: context.l10n.cobLedRgbSectionColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Colour swatch + labels ──────────────────────────────────────
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.18),
                  border: Border.all(color: color, width: 2),
                ),
                child: Center(
                  child: Icon(Icons.circle, color: color, size: 22),
                ),
              ),
              AppSpacing.gapHMd,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rgbColor.hex,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'RGB (${rgbColor.red}, ${rgbColor.green}, ${rgbColor.blue})',
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

          // ── Colour wheel ────────────────────────────────────────────────
          SizedBox(
            height: 220,
            child: CobLedRgbColorWheel(
              color: color,
              onColorChanged: onColorChanged,
            ),
          ),
        ],
      ),
    );
  }
}
