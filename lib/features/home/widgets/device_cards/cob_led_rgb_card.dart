import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import 'card_shared.dart';

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
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    color: AppColors.textPrimary,
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

// ============================================================
// SPEED CONTROL  (horizontal pill: timer- / timer+)
// ============================================================

class SpeedControl extends StatelessWidget {
  const SpeedControl({super.key, this.onSpeedDown, this.onSpeedUp});
  final VoidCallback? onSpeedDown;
  final VoidCallback? onSpeedUp;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: AppRadius.lgBR,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSpeedDown,
              child: SizedBox(
                width: 44,
                child: Center(
                  child: Icon(
                    Icons.timer_rounded,
                    size: AppFontSizes.heading,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            Container(width: 0.5, color: AppColors.border),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSpeedUp,
              child: SizedBox(
                width: 44,
                child: Center(
                  child: Icon(
                    Icons.timer_rounded,
                    size: AppFontSizes.heading,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BRIGHTNESS BAR  (vertical fill + sun icon)
// ============================================================

class BrightnessBar extends StatelessWidget {
  const BrightnessBar({
    super.key,
    required this.value,
    required this.color,
    this.onChanged,
  });

  final double value;
  final Color color;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      decoration: BoxDecoration(
        borderRadius: AppRadius.xsBR,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.xsBR,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final clamped = value.clamp(0.0, 1.0);
            final fillH = h * clamped;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (d) {
                if (onChanged == null) return;
                final v = 1.0 - (d.localPosition.dy / h);
                onChanged!(v.clamp(0.0, 1.0));
              },
              onTapDown: (d) {
                if (onChanged == null) return;
                final v = 1.0 - (d.localPosition.dy / h);
                onChanged!(v.clamp(0.0, 1.0));
              },
              child: Stack(
                children: [
                  // Dark background
                  Container(color: AppColors.card),
                  // White fill from bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: fillH,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  // Separator line at fill level
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: fillH - 0.5,
                    height: 1,
                    child: Container(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  // Sun icon at bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 6,
                    child: Icon(
                      Icons.wb_sunny_outlined,
                      size: AppFontSizes.heading,
                      color: const Color(0xFF2A2A2A),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
