import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

/// Custom two-layer bottom navigation bar:
/// - an "icons" bar (background = AppColors.surface) with an animated indicator
/// - a "label" bar (background = AppColors.bg) with an OUTSIDE shadow above the label
class CurvedBottomBar extends StatelessWidget {
  const CurvedBottomBar({
    super.key,
    required this.index,
    required this.onTap,
    required this.labels,
    required this.icons,
  }) : assert(labels.length == 5 && icons.length == 5);

  final int index;
  final ValueChanged<int> onTap;
  final List<String> labels;
  final List<IconData> icons;

  // Layout
  static const int _count = 5;
  static const double _radius = 0.0;
  static const double _iconBarHeight = 60.0;
  static const double _labelBarHeight = 28.0;

  // Icon row layout
  static const double _sidePadding = 18.0;
  static const double _iconsBottomPadding = 35.0;

  // Indicator (bar under selected icon)
  static const double _indicatorW = 44.0;
  static const double _indicatorH = 5.0;
  static const Duration _animDuration = Duration(milliseconds: 280);
  static const Curve _animCurve = Curves.easeOutCubic;

  // Outside shadow above label bar
  static const double _outsideShadowTop = 10;
  static const double _outsideShadowHeight = 20;
  static const double _outsideShadowAlpha = 0.65;
  static const double _outsideShadowBlur = 8;
  static const double _outsideShadowCurveBoost = 1.0;

  // Adjust each icon vertically to visually follow the curve.
  double _iconOffsetY(int i) {
    switch (i) {
      case 0:
      case 4:
        return 7.6;
      case 1:
      case 3:
        return -1.7;
      case 2:
        return -4.8;
      default:
        return 0;
    }
  }

  // Tilt for the indicator under the selected icon to match the visual curve.
  double _indicatorTilt(int i) {
    switch (i) {
      case 0:
        return -0.17;
      case 1:
        return -0.09;
      case 2:
        return 0.0;
      case 3:
        return 0.07;
      case 4:
        return 0.15;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // =========================
        // 1) ICON BAR (AppColors.surface)
        // =========================
        SizedBox(
          height: _iconBarHeight,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;

              // Each icon occupies an equal-width "slot" across the bar (padding excluded)
              final slotW = (w - _sidePadding * 2) / _count;

              // X center of the selected slot
              final centerX = _sidePadding + slotW * (index + 0.5);

              // Left position of the indicator so it’s centered under the icon
              final indicatorLeft = centerX - _indicatorW / 2;

              // Vertical offset + tilt adjustment (to follow the curve)
              final yOffset = _iconOffsetY(index);
              final angle = _indicatorTilt(index);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Icon background
                  const Positioned.fill(
                    child: CustomPaint(
                      painter: _CurvedBarPainter(
                        radius: _radius,
                        backgroundColor: AppColors.surface,
                      ),
                    ),
                  ),

                  // Animated Indicator
                  AnimatedPositioned(
                    duration: _animDuration,
                    curve: _animCurve,
                    left: indicatorLeft,
                    top: 32 + yOffset,
                    child: AnimatedRotation(
                      duration: _animDuration,
                      curve: _animCurve,
                      turns: angle / (2 * 3.141592653589793),
                      child: Container(
                        width: _indicatorW,
                        height: _indicatorH,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withValues(alpha: 0.9),
                          borderRadius: AppRadius.pillBR,
                          boxShadow: AppShadows.glow(AppColors.primary),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                      left: _sidePadding,
                      right: _sidePadding,
                      bottom: _iconsBottomPadding,
                    ),
                    child: Row(
                      children: List.generate(_count, (i) {
                        return Expanded(
                          child: Center(
                            child: Transform.translate(
                              offset: Offset(0, _iconOffsetY(i)),
                              child: _NavIcon(
                                icon: icons[i],
                                selected: i == index,
                                onTap: () => onTap(i),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // =========================
        // 2) LABEL BAR (AppColors.bg) + outside shadow
        // =========================
        SizedBox(
          height: _labelBarHeight,
          width: double.infinity,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                left: 0,
                right: 0,
                top: _outsideShadowTop,
                height: _outsideShadowHeight,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _TopOutsideShadowPainter(
                      radius: _radius,
                      alpha: _outsideShadowAlpha,
                      blurSigma: _outsideShadowBlur,
                      curveBoost: _outsideShadowCurveBoost,
                    ),
                  ),
                ),
              ),
              const Positioned.fill(
                child: CustomPaint(
                  painter: _CurvedBarPainter(
                    radius: _radius,
                    backgroundColor: AppColors.bg,
                  ),
                ),
              ),
              Center(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Text(
                    labels[index],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  static const double _iconBox = 56;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _iconBox,
      height: _iconBox,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: SizedBox(width: 84, height: 84),
          ),

          IgnorePointer(
            child: Icon(
              icon,
              size: 24,
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurvedBarPainter extends CustomPainter {
  const _CurvedBarPainter({
    required this.radius,
    required this.backgroundColor,
  });

  final double radius;
  final Color backgroundColor;

  static const double _topCurve = -60.0;
  static const double _curveHalfWidth = 250.0;

  Path _buildPath(Size size) {
    final mid = size.width / 2;
    final left = mid - _curveHalfWidth;
    final right = mid + _curveHalfWidth;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(left, 0)
      ..quadraticBezierTo(mid, _topCurve, right, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, size.height)
      ..close();

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildPath(size);

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = AppColors.border.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, bgPaint);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _CurvedBarPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _TopOutsideShadowPainter extends CustomPainter {
  const _TopOutsideShadowPainter({
    required this.radius,
    required this.alpha,
    required this.blurSigma,
    this.curveBoost = 1.0,
  });

  final double radius;
  final double alpha;
  final double blurSigma;
  final double curveBoost;

  static const double _baseTopCurve = -60.0;
  static const double _curveHalfWidth = 250.0;

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.width / 2;
    final left = mid - _curveHalfWidth;
    final right = mid + _curveHalfWidth;
    final topCurve = _baseTopCurve * curveBoost;

    final topEdge = Path()
      ..moveTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(left, 0)
      ..quadraticBezierTo(mid, topCurve, right, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withValues(alpha: alpha)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);

    canvas.save();
    canvas.translate(0, -6);
    canvas.drawPath(topEdge, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TopOutsideShadowPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.alpha != alpha ||
        oldDelegate.blurSigma != blurSigma ||
        oldDelegate.curveBoost != curveBoost;
  }
}
