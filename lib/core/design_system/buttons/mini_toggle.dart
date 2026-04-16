import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';

/// Pill-style power toggle — the app's custom on/off switch.
///
/// ON  — green track · white border · dark concave thumb (right)
/// OFF — dark track  · grey border  · hollow thumb (left) + dash indicator
///
/// Inner-shadow effect is achieved via a gradient overlay inside a
/// [ClipRRect]+[Stack], since Flutter doesn't support CSS-style inner shadows.
///
/// [onTap] = null OR [loading] = true disables interaction at 45% opacity.
class MiniToggle extends StatelessWidget {
  const MiniToggle({
    super.key,
    required this.isOn,
    required this.loading,
    required this.onTap,
  });

  final bool isOn;
  final bool loading;
  final VoidCallback? onTap;

  static const _duration = Duration(milliseconds: 280);
  static const _curve    = Curves.easeInOutCubic;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;

    return GestureDetector(
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onTap!();
            }
          : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: enabled ? 1.0 : 0.45,
        child: AnimatedContainer(
          duration: _duration,
          curve: _curve,
          width: 48,
          height: 26,
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillBR,
            border: Border.all(
              color: isOn ? Colors.white : AppColors.border,
              width: 0.5,
            ),
          ),
          // ClipRRect keeps the gradient overlay clipped to the pill shape.
          child: ClipRRect(
            borderRadius: AppRadius.pillBR,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Layer 1: animated background color ───────────────────────
                AnimatedContainer(
                  duration: _duration,
                  curve: _curve,
                  color: isOn ? AppColors.success : AppColors.surface,
                ),

                // ── Layer 2: inner-shadow gradient — animated via lerp ────────
                TweenAnimationBuilder<double>(
                  tween: Tween(end: isOn ? 1.0 : 0.0),
                  duration: _duration,
                  curve: _curve,
                  builder: (_, t, _) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: Gradient.lerp(
                          AppShadows.toggleOffTrack,
                          AppShadows.toggleOnTrack,
                          t,
                        ),
                      ),
                    );
                  },
                ),

                // ── Layer 3: content (thumb + optional dash / loader) ─────────
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: loading ? _buildLoader() : _buildContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
    );
  }

  Widget _buildContent() {
    return Stack(
      children: [
        // Dash indicator — visible when OFF, aligned right
        if (!isOn)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Container(
                width: 8,
                height: 0.5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.xsBR,
                ),
              ),
            ),
          ),

        // Thumb
        AnimatedAlign(
          duration: _duration,
          curve: _curve,
          alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: _duration,
            curve: _curve,
            width: 18,
            height: 18,
            decoration: isOn
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppShadows.toggleOnThumb,
                  )
                : BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bg.withValues(alpha: 0.2),
                    border: Border.all(
                      color: AppColors.border,
                      width: 0.5,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
