import 'package:flutter/material.dart';

import '../../../../core/design_system/buttons/mini_toggle.dart';
import '../../../../core/design_system/feedback/status_dot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

// Re-export DS components so existing card files keep working without changes.
export '../../../../core/design_system/buttons/mini_toggle.dart';
export '../../../../core/design_system/feedback/status_dot.dart';

// ============================================================
// CARD SHELL  (shared two-section layout)
// ============================================================

/// Two-section card matching Figma spec:
/// - Top: accent color at 12% opacity → #1F1A1A (vertical gradient)
/// - Divider: horizontal gradient (transparent → F8F2F2 → transparent), 0.6px
/// - Bottom: #1F1A1A solid
/// - Border: #535353 at 100%, weight 0.5, inside
class CardShell extends StatelessWidget {
  const CardShell({
    super.key,
    required this.content,
    required this.footer,
    required this.onTap,
    required this.accentColor,
    this.online = false,
  });

  final Widget content;
  final Widget footer;
  final VoidCallback onTap;
  final Color accentColor;
  final bool online;

  @override
  Widget build(BuildContext context) {
    // Figma: accent at 12% blended over cardBase
    final topColor = Color.lerp(AppColors.card, accentColor, 0.3)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.x4lBR,
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top: accent gradient
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [topColor, AppColors.card],
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                        child: content,
                      ),
                    ),
                    // Divider: Figma gradient stroke (0% → F8F2F2 → 0%)
                    Container(
                      height: 0.6,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0x00F8F2F2),
                            Color(0xFFF8F2F2),
                            Color(0x00F8F2F2),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    // Bottom: dark footer
                    Container(
                      color: AppColors.card,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: footer,
                    ),
                  ],
                ),
                // Online dot — top-right corner
                Positioned(
                  top: 14,
                  right: 14,
                  child: StatusDot(online: online),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CARD HEADER  (icon + name + online dot)
// ============================================================

class CardHeader extends StatelessWidget {
  const CardHeader({
    super.key,
    required this.icon,
    required this.name,
  });

  final IconData icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22.0, color: AppColors.textPrimary),
        AppSpacing.gapHSm,
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'ShareTech',
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: AppFontSizes.heading,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// META LABEL  ("Live", "Source", "Scene" …)
// ============================================================

class MetaLabel extends StatelessWidget {
  const MetaLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'ShareTech',
        color: AppColors.textSecondary,
        fontSize: 12.0,
      ),
    );
  }
}

// ============================================================
// CARD FOOTER  (updated label + mini toggle)
// ============================================================

class CardFooter extends StatelessWidget {
  const CardFooter({
    super.key,
    required this.updatedLabel,
    required this.isOn,
    required this.toggling,
    required this.canToggle,
    required this.onToggle,
  });

  final String updatedLabel;
  final bool isOn;
  final bool toggling;
  final bool canToggle;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            updatedLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'ShareTech',
              color: AppColors.textSecondary,
              fontSize: 12.0,
            ),
          ),
        ),
        AppSpacing.gapHSm,
        MiniToggle(
          isOn: isOn,
          loading: toggling,
          onTap: canToggle ? onToggle : null,
        ),
      ],
    );
  }
}

// MiniToggle is provided by core/design_system/buttons/mini_toggle.dart 
// (re-exported above — no local definition needed).
