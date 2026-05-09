import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_font_sizes.dart';
import '../../../../../../core/theme/app_radius.dart';
import '../../../../../../domain/entities/history_window.dart';
import '../../../../../../domain/entities/live_point.dart';

/// Background fill and grid overlay drawing helpers.
/// No state — all methods are pure canvas operations.
abstract final class ChartGridRenderer {
  /// Draws the rounded-rect background behind the chart area.
  static void drawBackground(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = AppColors.bg
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromLTRBR(
        0, 0, size.width, size.height,
        const Radius.circular(AppRadius.lg),
      ),
      bgPaint,
    );
  }

  /// Draws the horizontal dotted reference line through the vertical centre
  /// of [chartRect].
  static void drawReferenceLine(Canvas canvas, Rect chartRect) {
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    const spacing = 3.0;
    const radius = 1.1;

    double x = chartRect.left;
    while (x <= chartRect.right) {
      canvas.drawCircle(Offset(x, chartRect.center.dy), radius, dotPaint);
      x += spacing;
    }
  }

  /// Draws a flat line through the vertical centre of [chartRect] when there
  /// are not enough points to build a real path.
  static void drawEmptyLine(Canvas canvas, Rect chartRect, Color lineColor) {
    final paint = Paint()
      ..color = lineColor.withValues(alpha: 0.85)
      ..strokeWidth = 3.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final y = chartRect.center.dy;
    canvas.drawLine(Offset(chartRect.left, y), Offset(chartRect.right, y), paint);
  }
}

/// Y-axis and X-axis label drawing helpers.
abstract final class ChartAxisRenderer {
  static const int _yTickCount = 4;
  static const int _xTickCount = 5;

  /// Draws value labels on the right edge of [chartRect].
  static void drawRightYAxis(
    Canvas canvas,
    Rect chartRect, {
    required double minY,
    required double maxY,
    required String powerUnitLabel,
  }) {
    final textStyle = TextStyle(
      fontSize: 7.0,
      fontWeight: FontWeight.w700,
      color: Colors.white.withValues(alpha: 0.38),
    );

    for (int i = 0; i < _yTickCount; i++) {
      final ratio = i / (_yTickCount - 1);
      final value = maxY - ((maxY - minY) * ratio);
      final y = chartRect.top + (chartRect.height * ratio);

      final tp = TextPainter(
        text: TextSpan(
          text: '${value.toStringAsFixed(0)} $powerUnitLabel',
          style: textStyle,
        ),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.left,
      )..layout();

      tp.paint(canvas, Offset(chartRect.right + 10, y - (tp.height / 2)));
    }
  }

  /// Draws time labels along the bottom edge of [chartRect].
  static void drawBottomXAxis(
    Canvas canvas,
    Rect chartRect, {
    required DateTime start,
    required DateTime now,
    required HistoryWindow window,
    required String localeTag,
  }) {
    final textStyle = TextStyle(
      fontSize: 7.0,
      fontWeight: FontWeight.w700,
      color: Colors.white.withValues(alpha: 0.38),
    );

    final totalMillis = now.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    final safeTotalMillis = totalMillis <= 0 ? 1 : totalMillis;

    for (int i = 0; i < _xTickCount; i++) {
      final ratio = i / (_xTickCount - 1);
      final dateTime =
          start.add(Duration(milliseconds: (safeTotalMillis * ratio).round()));

      final label = formatXAxisLabel(
        dateTime: dateTime,
        start: start,
        end: now,
        window: window,
        localeTag: localeTag,
      );

      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      final x = chartRect.left + (chartRect.width * ratio);
      tp.paint(canvas, Offset(x - (tp.width / 2), chartRect.bottom + 10));
    }
  }

  /// Returns a formatted string for a single X-axis tick.
  ///
  /// Also used for tooltip time formatting.
  static String formatXAxisLabel({
    required DateTime dateTime,
    required DateTime start,
    required DateTime end,
    required HistoryWindow window,
    required String localeTag,
  }) {
    final totalDays = end.difference(start).inDays;

    switch (window) {
      case HistoryWindow.d1:
        return DateFormat('HH:mm', localeTag).format(dateTime);

      case HistoryWindow.w1:
      case HistoryWindow.m1:
        return DateFormat('dd/MM', localeTag).format(dateTime);

      case HistoryWindow.y1:
        return DateFormat('MM/yyyy', localeTag).format(dateTime);

      case HistoryWindow.max:
        if (totalDays <= 2) return DateFormat('HH:mm', localeTag).format(dateTime);
        if (totalDays <= 45) return DateFormat('dd/MM', localeTag).format(dateTime);
        if (totalDays <= 550) return DateFormat('MM/yyyy', localeTag).format(dateTime);
        return DateFormat('yyyy', localeTag).format(dateTime);
    }
  }
}

/// Crosshair, dot, and tooltip drawing helpers shown during hover interaction.
abstract final class ChartHoverRenderer {
  /// Draws a vertical line through [point.dx] spanning the full chart height.
  static void drawCrosshair(Canvas canvas, Rect chartRect, Offset point) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(point.dx, chartRect.top),
      Offset(point.dx, chartRect.bottom),
      paint,
    );
  }

  /// Draws the filled dot indicator at [point].
  static void drawDot(Canvas canvas, Offset point, Color lineColor) {
    final outerPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final innerPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(point, 6.5, outerPaint);
    canvas.drawCircle(point, 4.0, innerPaint);
  }

  /// Draws the floating tooltip showing power value and time at [index].
  static void drawTooltip(
    Canvas canvas,
    int index,
    List<LivePoint> points, {
    required String powerUnitLabel,
    required String Function(DateTime dateTime) formatTooltipTime,
  }) {
    final point = points[index];
    final powerLabel = '${point.powerW.toStringAsFixed(0)} $powerUnitLabel';
    final timeLabel = formatTooltipTime(point.at);

    const valueStyle = TextStyle(
      fontSize: AppFontSizes.sm,
      fontWeight: FontWeight.w800,
      color: Colors.white,
    );

    final subStyle = TextStyle(
      fontSize: AppFontSizes.xs,
      fontWeight: FontWeight.w600,
      color: Colors.white.withValues(alpha: 0.70),
    );

    final valuePainter = TextPainter(
      text: TextSpan(text: powerLabel, style: valueStyle),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    final timePainter = TextPainter(
      text: TextSpan(text: timeLabel, style: subStyle),
      textDirection: ui.TextDirection.ltr,
    )..layout();

    const padding = EdgeInsets.symmetric(horizontal: 10, vertical: 8);
    final tooltipWidth =
        max(valuePainter.width, timePainter.width) + padding.horizontal;
    final tooltipHeight =
        valuePainter.height + timePainter.height + padding.vertical;

    final tooltipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 8, tooltipWidth, tooltipHeight),
      const Radius.circular(AppRadius.xl),
    );

    final tooltipPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.42)
      ..style = PaintingStyle.fill
      ..imageFilter = ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0);

    canvas.drawRRect(tooltipRect, tooltipPaint);

    valuePainter.paint(
      canvas,
      const Offset(10, 8) + Offset(padding.left, padding.top),
    );
    timePainter.paint(
      canvas,
      const Offset(10, 8) +
          Offset(padding.left, padding.top + valuePainter.height + 2),
    );
  }
}
