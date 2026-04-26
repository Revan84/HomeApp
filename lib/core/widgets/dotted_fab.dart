import 'dart:math' show cos, sin;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Circular FAB with a dotted border drawn via [CustomPainter].
///
/// ```dart
/// DottedFab(key: _fabKey, onPressed: _onFabPressed)
/// ```
class DottedFab extends StatelessWidget {
  const DottedFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const double size = 64;
    return GestureDetector(
      onTap: onPressed,
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.bg.withValues(alpha: 0.98),
            shape: BoxShape.circle,
          ),
          child: CustomPaint(
            painter: _DottedCirclePainter(
              color: AppColors.primary,
              dotRadius: 1.0,
              dotCount: 52,
            ),
            child: const Center(
              child: Icon(Icons.add, color: AppColors.primary, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}

class _DottedCirclePainter extends CustomPainter {
  const _DottedCirclePainter({
    required this.color,
    this.dotRadius = 2.0,
    this.dotCount = 36,
  });

  final Color color;
  final double dotRadius;
  final int dotCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - dotRadius;
    const twoPi = 2 * 3.141592653589793;

    for (int i = 0; i < dotCount; i++) {
      final angle = twoPi * i / dotCount;
      final dx = center.dx + radius * cos(angle);
      final dy = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(dx, dy), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(_DottedCirclePainter old) =>
      old.color != color ||
      old.dotRadius != dotRadius ||
      old.dotCount != dotCount;
}
