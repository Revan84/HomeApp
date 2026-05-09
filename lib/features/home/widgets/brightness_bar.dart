import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

// ============================================================
// BRIGHTNESS BAR  (shared by CobLedRgb + CobLedCct cards)
//
//  ┌──────────────────────┐  ← outer SizedBox width = _thumbW
//  │  ┌────────────────┐  │  ← track pill, width = _trackW, border = accent
//  │  │   dark bg      │  │
//  │  │                │  │
//  ├──┼── thumb ────────┼──┤  ← accent pill, wider than track
//  │  │  accent fill   │  │  ← fill top flush with thumb bottom
//  │  │   ☀ icon       │  │  ← follows thumb, in OUTER stack (no clipping)
//  │  └────────────────┘  │
//  └──────────────────────┘
// ============================================================

class BrightnessBar extends StatelessWidget {
  const BrightnessBar({
    super.key,
    required this.value, // 0.0 – 1.0
    required this.color, // accent color (greyed when off)
    this.onChanged,
  });

  final double value;
  final Color color;
  final ValueChanged<double>? onChanged;

  // ── Dimensions ───────────────────────────────────────────────────────────
  static const _trackW   = 24.0; // inner track pill width
  static const _thumbW   = 30.0; // thumb wider than track
  static const _thumbH   = 5.0;  // thumb height
  static const _iconSize = 18.0; // sun icon size
  static const _iconGap  = 4.0;  // gap between thumb bottom and icon top

  // ── Colors ───────────────────────────────────────────────────────────────
  static const _trackBg  = AppColors.bg;
  static const _iconDark = AppColors.bg; // when icon is inside fill

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _thumbW,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final clamped = value.clamp(0.0, 1.0);
          final fillH = h * clamped;

          // Thumb bottom = fill top: thumb sits above the fill, never inside it.
          // Minimum is -0.5 so the thumb visually touches the very bottom of the
          // pill track (the 0.5px border would otherwise leave a hairline gap).
          final thumbBottom = fillH.clamp(0.0, h - _thumbH);

          // Icon normally sits just below the thumb (inside the fill).
          // When thumb is too low and there's not enough space below it,
          // the icon flips above the thumb instead — never hidden, never clipped.
          final canFitBelow = thumbBottom >= _iconSize + _iconGap;
          final iconBottom = canFitBelow
              ? thumbBottom - _iconSize - _iconGap          // below thumb (normal)
              : thumbBottom + _thumbH + _iconGap;           // above thumb (low brightness)

          // Below thumb = inside fill → dark. Above thumb = dark bg → accent.
          final iconColor = canFitBelow ? _iconDark : color;

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
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [

                // ── Track pill (fill only, no icon inside) ─────────────────
                Center(
                  child: SizedBox(
                    width: _trackW,
                    height: h,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _trackBg,
                        borderRadius: AppRadius.smBR,
                        border: Border.all(color: color, width: 0.5),
                      ),
                      child: ClipRRect(
                        borderRadius: AppRadius.smBR,
                        child: Stack(
                          children: [
                            Container(color: _trackBg),
                            if (fillH > 0)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: fillH,
                                child: Container(color: color),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Sun icon — outer stack, never clipped ──────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: iconBottom,
                  child: Icon(
                    Icons.wb_sunny_outlined,
                    size: _iconSize,
                    color: iconColor,
                  ),
                ),

                // ── Thumb pill (wider than track) ──────────────────────────
                Positioned(
                  bottom: thumbBottom,
                  child: Container(
                    width: _thumbW,
                    height: _thumbH,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: AppRadius.xsBR,
                      border: Border.all(color: _trackBg, width: 1)
                    ),
                  ),
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}
