import 'package:flutter/material.dart';

import '../../../../core/design_system/buttons/mini_toggle.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/device_accent_scope.dart';

// Re-export MiniToggle so existing card files keep working without changes.
export '../../../../core/design_system/buttons/mini_toggle.dart';

// ============================================================
// CARD SHELL  (shared two-section layout)
// ============================================================

/// Two-section card:
/// - Background: #292929 solid
/// - Border: accent color, 0.5 px
/// - Top-right decorative circle: accent color with glow when online
/// - Divider: accent color gradient (fades at edges)
/// - Exposes accent via [DeviceAccentScope] so children auto-style themselves
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

  static const _bg = Color(0xFF292929);

  @override
  Widget build(BuildContext context) {
    return DeviceAccentScope(
      accentColor: accentColor,
      child: Container(
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: AppRadius.x4lBR,
          border: Border.all(color: accentColor, width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashColor: accentColor.withValues(alpha: 0.08),
              highlightColor: accentColor.withValues(alpha: 0.04),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Content section ────────────────────────────────────
                      Expanded(
                        child: Container(
                          color: _bg,
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                          child: content,
                        ),
                      ),
                      // ── Divider: accent gradient (fades to transparent) ───
                      Container(
                        height: 0.8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withValues(alpha: 0),
                              accentColor.withValues(alpha: 0.7),
                              accentColor,
                              accentColor.withValues(alpha: 0.7),
                              accentColor.withValues(alpha: 0),
                            ],
                            stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                          ),
                        ),
                      ),
                      // ── Footer ─────────────────────────────────────────────
                      Container(
                        color: _bg,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: footer,
                      ),
                    ],
                  ),
                  // ── Decorative circle — top-right corner ───────────────────
                  Positioned(
                    top: 10,
                    right: 12,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: online
                            ? accentColor
                            : AppColors.border,
                        border: Border.all(
                          color: online
                              ? accentColor
                              : AppColors.border.withValues(alpha: 0),
                          width: 1.0,
                        ),
                        boxShadow: online
                            ? [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.2),
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CARD HEADER  (icon + name)
// ============================================================

class CardHeader extends StatelessWidget {
  const CardHeader({super.key, required this.icon, required this.name});

  final IconData icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    final accent = DeviceAccentScope.of(context);
    return Row(
      children: [
        Icon(icon, size: 22.0, color: accent),
        AppSpacing.gapHSm,
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'ShareTech',
              color: accent,
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

// ============================================================
// SPEED CONTROL  (− / + buttons, accent-styled)
// ============================================================

class SpeedControl extends StatelessWidget {
  const SpeedControl({super.key, this.onSpeedDown, this.onSpeedUp});
  final VoidCallback? onSpeedDown;
  final VoidCallback? onSpeedUp;

  @override
  Widget build(BuildContext context) {
    final accent = DeviceAccentScope.of(context);
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: AppRadius.lgBR,
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 0.5),
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
                width: 40,
                height: 34,
                child: Center(
                  child: _SpeedIcon(accent: accent, plus: false),
                ),
              ),
            ),
            Container(
              width: 0.5,
              height: 18,
              color: accent.withValues(alpha: 0.3),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSpeedUp,
              child: SizedBox(
                width: 40,
                height: 34,
                child: Center(
                  child: _SpeedIcon(accent: accent, plus: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Speed icon: speedometer + superscript badge (− or +) ─────────────────────

class _SpeedIcon extends StatelessWidget {
  const _SpeedIcon({required this.accent, required this.plus});

  final Color accent;
  final bool plus;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.speed, size: 18, color: accent),
        Positioned(
          top: -5,
          right: -6,
          child: Text(
            plus ? '+' : '−',
            style: TextStyle(
              fontSize: 10,
              height: 1,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}

// MiniToggle is provided by core/design_system/buttons/mini_toggle.dart
// (re-exported above — no local definition needed).
