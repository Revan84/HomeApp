import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../widgets/brightness_bar.dart';
import 'card_shared.dart';

export '../widgets/brightness_bar.dart';

class CobLedRgbCard extends StatelessWidget {
  const CobLedRgbCard({
    super.key,
    required this.device,
    required this.isOn,
    required this.brightness,
    required this.sceneName,
    required this.color,
    required this.onTap,
    this.onToggle,
    this.onBrightnessDrag,
    this.onSpeedDown,
    this.onSpeedUp,
    this.updatedLabel = '',
  });

  final dynamic device; // CobLedRgbDevice
  final bool isOn;
  final double brightness; // 0.0 – 1.0
  final String sceneName;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onToggle;
  final ValueChanged<double>? onBrightnessDrag;
  final VoidCallback? onSpeedDown;
  final VoidCallback? onSpeedUp;
  final String updatedLabel;

  @override
  Widget build(BuildContext context) {
    final displayColor = isOn ? color : Colors.grey.shade700;

    return CardShell(
      onTap: onTap,
      accentColor: AppColors.cobLedRgbAccent,
      online: isOn,
      content: Row(
        children: [
          // ── left content ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(
                  icon: Icons.lightbulb_outline_rounded,
                  name: device.name as String,
                ),
                AppSpacing.gapMd,
                const MetaLabel('Scene'),
                AppSpacing.gapXxs,
                Text(
                  sceneName.isNotEmpty ? sceneName : '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.cobLedRgbAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSizes.sectionTitle,
                  ),
                ),
                AppSpacing.gapMd,
                SpeedControl(onSpeedDown: onSpeedDown, onSpeedUp: onSpeedUp),
              ],
            ),
          ),

          AppSpacing.gapHXl,

          // ── right: brightness bar ──
          SizedBox(
            height: 90,
            child: BrightnessBar(
              value: brightness,
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

// SpeedControl is defined in card_shared.dart (accent-aware, speed icons).
// BrightnessBar is defined in brightness_bar.dart (shared with CobLedCctCard).
