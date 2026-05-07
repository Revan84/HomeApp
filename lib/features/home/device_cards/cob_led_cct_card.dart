import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/cob_led_cct_device.dart';
import 'brightness_bar.dart';
import 'card_shared.dart';

/// Home-grid card for a COB LED CCT device.
///
/// Shows device name, active scene name, speed +/− buttons,
/// and a brightness bar on the right.
class CobLedCctCard extends StatelessWidget {
  const CobLedCctCard({
    super.key,
    required this.device,
    required this.isOn,
    required this.brightness, // 0–255
    required this.onTap,
    this.onToggle,
    this.onBrightnessDrag,
    this.onSpeedDown,
    this.onSpeedUp,
    this.updatedLabel = '',
  });

  final CobLedCctDevice device;
  final bool isOn;
  final int brightness;
  final VoidCallback onTap;
  final VoidCallback? onToggle;
  final ValueChanged<double>? onBrightnessDrag;
  final VoidCallback? onSpeedDown;
  final VoidCallback? onSpeedUp;
  final String updatedLabel;

  @override
  Widget build(BuildContext context) {
    // Resolve active scene name from device metadata.
    final activeScene = device.activeSceneId.isNotEmpty
        ? device.scenes
            .where((s) => s.id == device.activeSceneId)
            .firstOrNull
        : null;
    final sceneName = activeScene?.name ?? '';

    final accent = AppColors.cobLedCctAccent;
    final barColor = isOn ? accent : Colors.grey.shade700;
    final briNorm = (brightness / 255.0).clamp(0.0, 1.0);

    return CardShell(
      onTap: onTap,
      accentColor: accent,
      online: isOn,
      content: Row(
        children: [
          // ── Left content ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CardHeader(
                  icon: Icons.wb_incandescent_outlined,
                  name: device.name,
                ),
                AppSpacing.gapMd,
                const MetaLabel('Scene'),
                AppSpacing.gapXxs,
                Text(
                  sceneName.isNotEmpty ? sceneName : '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'ShareTech',
                    color: AppColors.cobLedCctAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSizes.sectionTitle,
                  ),
                ),
                AppSpacing.gapMd,
                SpeedControl(
                  onSpeedDown: onSpeedDown,
                  onSpeedUp: onSpeedUp,
                ),
                AppSpacing.gapXxs,
              ],
            ),
          ),

          AppSpacing.gapHXl,

          // ── Right: brightness bar ────────────────────────────────────────
          SizedBox(
            height: 90,
            child: BrightnessBar(
              value: briNorm,
              color: AppColors.cobLedCctAccent,
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
