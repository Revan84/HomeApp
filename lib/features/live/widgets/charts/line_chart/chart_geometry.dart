import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../../../domain/entities/history_window.dart';
import '../../../../../../domain/entities/live_point.dart';

/// Shared chart spacing constants.
final class ChartLayout {
  static const double leftPadding = 8;
  static const double topPadding = 8;
  static const double rightPadding = 40;
  static const double bottomPadding = 34;

  static Rect chartRect(Size size) => Rect.fromLTWH(
        leftPadding,
        topPadding,
        max(1, size.width - leftPadding - rightPadding),
        max(1, size.height - topPadding - bottomPadding),
      );
}

/// Pure geometry helpers: point mapping and path building.
/// No canvas operations — all methods return values or paths.
abstract final class ChartGeometry {
  /// Maps domain [points] to canvas pixels inside [chartRect].
  static List<Offset> mapPoints({
    required Rect chartRect,
    required List<LivePoint> points,
    required DateTime windowStart,
    required DateTime now,
    required double minY,
    required double maxY,
  }) {
    final minX = windowStart.millisecondsSinceEpoch.toDouble();
    final maxX = now.millisecondsSinceEpoch.toDouble();
    final spanX = max(1.0, maxX - minX);
    final spanY = max(0.001, (maxY - minY).abs());

    return points.map((point) {
      final pointX = point.at.millisecondsSinceEpoch.toDouble();
      final xRatio = ((pointX - minX) / spanX).clamp(0.0, 1.0);
      final x = chartRect.left + (xRatio * chartRect.width);

      final yRatio = ((point.powerW - minY) / spanY).clamp(0.0, 1.0);
      final y = chartRect.bottom - (yRatio * chartRect.height);

      return Offset(x, y);
    }).toList(growable: false);
  }

  /// Computes the window start date for a given [window] and [points].
  static DateTime windowStart({
    required HistoryWindow window,
    required List<LivePoint> points,
    required DateTime now,
  }) {
    final oldestPointAt = points.isEmpty ? null : points.first.at;
    return window.startDate(end: now, oldestPointAt: oldestPointAt);
  }

  /// Builds a smooth Bezier path through [mappedPoints].
  static Path smoothPath(List<Offset> mappedPoints) {
    final path = Path()
      ..moveTo(mappedPoints.first.dx, mappedPoints.first.dy);

    for (int i = 0; i < mappedPoints.length - 1; i++) {
      final current = mappedPoints[i];
      final next = mappedPoints[i + 1];
      final midpoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      path.quadraticBezierTo(
          current.dx, current.dy, midpoint.dx, midpoint.dy);
    }
    path.lineTo(mappedPoints.last.dx, mappedPoints.last.dy);
    return path;
  }

  /// Returns a sub-path of [path] up to the fraction [t] of total length.
  static Path extractPathFraction(Path path, double t) {
    if (t >= 0.999) return path;
    final metrics = path.computeMetrics().toList(growable: false);
    if (metrics.isEmpty) return path;

    final totalLength =
        metrics.fold<double>(0, (sum, m) => sum + m.length);
    final targetLength = totalLength * t;
    var accumulated = 0.0;
    final output = Path();

    for (final metric in metrics) {
      final remaining = targetLength - accumulated;
      if (remaining <= 0) break;
      final visible = min(metric.length, remaining);
      output.addPath(metric.extractPath(0, visible), Offset.zero);
      accumulated += metric.length;
      if (accumulated >= targetLength) break;
    }
    return output;
  }
}
