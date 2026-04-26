import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/cob_led_cct_device.dart';
import 'card_shared.dart';
import 'cob_led_rgb_card.dart' show BrightnessBar;

/// Home-grid card for a COB LED CCT device.
///
/// Shows device name, colour-temperature hint (warm → cool), brightness bar.
class CobLedCctCard extends StatelessWidget {
  const CobLedCctCard({
    super.key,
    required this.device,
    required this.isOn,
    required this.brightness,  // 0–255
    required this.colorTempK,  // 2700–6500
    required this.onTap,
    this.onToggle,
    this.onBrightnessDrag,
    this.updatedLabel = '',
  });

  final CobLedCctDevice device;
  final bool isOn;
  final int brightness;
  final int colorTempK;
  final VoidCallback onTap;
  final VoidCallback? onToggle;
  final ValueChanged<double>? onBrightnessDrag;
  final String updatedLabel;

  // ── Colour helpers ───────────────────────────────────────────────────────────

  static const _warmColor = Color(0xFFFF9F00);
  static const _coolColor = Color(0xFFE8F4FF);

  static Color _tempToColor(int kelvin) {
    final t = ((kelvin - 2700) / (6500 - 2700)).clamp(0.0, 1.0);
    return Color.lerp(_warmColor, _coolColor, t)!;
  }

  static String _tempLabel(int kelvin) {
    if (kelvin <= 3000) return 'Warm white';
    if (kelvin <= 4500) return 'Neutral white';
    return 'Cool white';
  }

  @override
  Widget build(BuildContext context) {
    final tempColor = _tempToColor(colorTempK);
    final displayColor = isOn ? tempColor : Colors.grey.shade700;
    final briNorm = (brightness / 255.0).clamp(0.0, 1.0);

    return CardShell(
      onTap: onTap,
      accentColor: AppColors.cobLedCctAccent,
      online: isOn,
      content: Row(
        children: [
          // ── left content ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(
                  icon: Icons.wb_incandescent_outlined,
                  name: device.name,
                ),
                AppSpacing.gapMd,
                const MetaLabel('Colour temp.'),
                AppSpacing.gapXxs,
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: displayColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.gapHXxs,
                    Text(
                      '$colorTempK K',
                      style: const TextStyle(
                        fontFamily: 'ShareTech',
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: AppFontSizes.sectionTitle,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapXxs,
                Text(
                  _tempLabel(colorTempK),
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    color: AppColors.textSecondary,
                    fontSize: 11.0,
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.gapHXl,

          // ── right: brightness bar ──
          SizedBox(
            height: 90,
            child: BrightnessBar(
              value: briNorm,
              color: displayColor,
              onChanged: onBrightnessDrag,
            ),
          ),
        ],
      ),
      footer: CardFooter(
        updatedLabel: updatedLabel,
        isOn: isOn,
        toggling: false,
        canToggle: true,
        onToggle: onToggle,
      ),
    );
  }
}
