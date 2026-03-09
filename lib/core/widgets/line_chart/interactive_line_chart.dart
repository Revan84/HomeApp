import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/history_window.dart';
import '../../../../domain/models/live_point.dart';

/// Interactive power history chart with a finance-like minimalist style.
///
/// Design is intentionally preserved.
/// Only the date logic and localization were cleaned up.
class InteractiveLineChart extends StatefulWidget {
  final List<LivePoint> points;
  final HistoryWindow window;
  final double minY;
  final double maxY;
  final double height;

  /// Localized short unit label, for example "W".
  final String powerUnitLabel;

  /// Called when user hovers a point. Null when interaction ends.
  final ValueChanged<LivePoint?>? onHoverPoint;

  const InteractiveLineChart({
    super.key,
    required this.points,
    required this.window,
    required this.minY,
    required this.maxY,
    required this.height,
    required this.powerUnitLabel,
    this.onHoverPoint,
  });

  @override
  State<InteractiveLineChart> createState() =>
      _InteractiveLineChartState();
}

class _InteractiveLineChartState extends State<InteractiveLineChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealController;

  int? _hoverIndex;
  int? _lastHapticIndex;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant InteractiveLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    final windowChanged = oldWidget.window != widget.window;

    if (windowChanged) {
      _hoverIndex = null;
      _lastHapticIndex = null;

      _revealController
        ..reset()
        ..forward();

      _emitHoverPoint(null);
      return;
    }

    if (_hoverIndex != null && _hoverIndex! >= widget.points.length) {
      _hoverIndex = null;
      _lastHapticIndex = null;
      _emitHoverPoint(null);
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  void _emitHoverPoint(LivePoint? point) {
    final callback = widget.onHoverPoint;
    if (callback == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      callback(point);
    });
  }

  DateTime _windowStart(DateTime now) {
    final oldestPointAt = widget.points.isEmpty ? null : widget.points.first.at;

    return widget.window.startDate(
      end: now,
      oldestPointAt: oldestPointAt,
    );
  }

  int _nearestPointIndex({
    required Offset localPosition,
    required Size size,
    required List<LivePoint> points,
  }) {
    if (points.isEmpty) return 0;
    if (points.length == 1) return 0;

    final chartRect = _ChartLayout.chartRect(size);
    final safeWidth = max(1.0, chartRect.width);
    final clampedDx = localPosition.dx.clamp(chartRect.left, chartRect.right);

    final now = DateTime.now();
    final start = _windowStart(now);

    final minX = start.millisecondsSinceEpoch.toDouble();
    final maxX = now.millisecondsSinceEpoch.toDouble();
    final spanX = max(1.0, maxX - minX);

    final ratio = ((clampedDx - chartRect.left) / safeWidth).clamp(0.0, 1.0);
    final targetTime = minX + (ratio * spanX);

    int lo = 0;
    int hi = points.length - 1;

    while (lo < hi) {
      final mid = (lo + hi) >> 1;
      final midTime = points[mid].at.millisecondsSinceEpoch.toDouble();

      if (midTime < targetTime) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }

    final i1 = lo;
    final i0 = max(0, lo - 1);

    final dt0 =
        (points[i0].at.millisecondsSinceEpoch.toDouble() - targetTime).abs();
    final dt1 =
        (points[i1].at.millisecondsSinceEpoch.toDouble() - targetTime).abs();

    return dt1 < dt0 ? i1 : i0;
  }

  Future<void> _triggerHapticForIndex(int index) async {
    if (_lastHapticIndex == index) return;
    _lastHapticIndex = index;

    try {
      await HapticFeedback.lightImpact();
    } catch (_) {
      // Ignore platform-specific haptic failures.
    }
  }

  void _handleTouch(Offset localPosition, Size size) {
    final points = widget.points;
    if (points.isEmpty) return;

    final index = _nearestPointIndex(
      localPosition: localPosition,
      size: size,
      points: points,
    );

    if (_hoverIndex != index) {
      unawaited(_triggerHapticForIndex(index));
      _emitHoverPoint(points[index]);
    }

    setState(() {
      _hoverIndex = index;
    });
  }

  void _endTouch() {
    if (_hoverIndex == null) return;

    setState(() {
      _hoverIndex = null;
      _lastHapticIndex = null;
    });

    _emitHoverPoint(null);
  }

  String _formatTooltipTime(BuildContext context, DateTime dateTime) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final start = _windowStart(DateTime.now());
    final totalDays = DateTime.now().difference(start).inDays;

    switch (widget.window) {
      case HistoryWindow.d1:
        return DateFormat('HH:mm', locale).format(dateTime);

      case HistoryWindow.w1:
      case HistoryWindow.m1:
        return DateFormat('dd/MM', locale).format(dateTime);

      case HistoryWindow.y1:
        return DateFormat('MM/yyyy', locale).format(dateTime);

      case HistoryWindow.max:
        if (totalDays <= 2) {
          return DateFormat('HH:mm', locale).format(dateTime);
        }

        if (totalDays <= 45) {
          return DateFormat('dd/MM', locale).format(dateTime);
        }

        if (totalDays <= 550) {
          return DateFormat('MM/yyyy', locale).format(dateTime);
        }

        return DateFormat('yyyy', locale).format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    final localeTag = Localizations.localeOf(context).toLanguageTag();

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, widget.height);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _handleTouch(details.localPosition, size),
            onPanStart: (details) => _handleTouch(details.localPosition, size),
            onPanUpdate: (details) => _handleTouch(details.localPosition, size),
            onPanEnd: (_) => _endTouch(),
            onPanCancel: _endTouch,
            child: AnimatedBuilder(
              animation: _revealController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _InteractiveChartPainter(
                    localeTag: localeTag,
                    points: points,
                    minY: widget.minY,
                    maxY: widget.maxY,
                    revealT: _revealController.value,
                    hoverIndex: _hoverIndex,
                    window: widget.window,
                    powerUnitLabel: widget.powerUnitLabel,
                    formatTooltipTime: (dateTime) =>
                        _formatTooltipTime(context, dateTime),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

/// Shared chart spacing tuned for the current chart design.
final class _ChartLayout {
  static const double leftPadding = 8;
  static const double topPadding = 8;
  static const double rightPadding = 40;
  static const double bottomPadding = 34;

  static Rect chartRect(Size size) {
    return Rect.fromLTWH(
      leftPadding,
      topPadding,
      max(1, size.width - leftPadding - rightPadding),
      max(1, size.height - topPadding - bottomPadding),
    );
  }
}

class _InteractiveChartPainter extends CustomPainter {
  const _InteractiveChartPainter({
    required this.localeTag,
    required this.points,
    required this.minY,
    required this.maxY,
    required this.revealT,
    required this.hoverIndex,
    required this.window,
    required this.powerUnitLabel,
    required this.formatTooltipTime,
  });

  final String localeTag;
  final List<LivePoint> points;
  final double minY;
  final double maxY;
  final double revealT;
  final int? hoverIndex;
  final HistoryWindow window;
  final String powerUnitLabel;
  final String Function(DateTime dateTime) formatTooltipTime;

  static const int _yTickCount = 4;
  static const int _xTickCount = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final chartRect = _ChartLayout.chartRect(size);

    _drawReferenceLine(canvas, size);
    _drawRightYAxis(canvas, size);

    if (points.length < 2) {
      _drawBottomXAxis(canvas, size);
      _drawEmptyLine(canvas, chartRect);
      return;
    }

    final mappedPoints = _mapPoints(size);
    _drawBottomXAxis(canvas, size);

    if (mappedPoints.length < 2) {
      _drawEmptyLine(canvas, chartRect);
      return;
    }

    final linePath = _smoothPath(mappedPoints);
    final revealedPath =
        _extractPathFraction(linePath, revealT.clamp(0.0, 1.0));

    final linePaint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.drawPath(revealedPath, linePaint);

    if (hoverIndex != null &&
        hoverIndex! >= 0 &&
        hoverIndex! < mappedPoints.length) {
      final hoveredPoint = mappedPoints[hoverIndex!];
      _drawCrosshair(canvas, chartRect, hoveredPoint);
      _drawDot(canvas, hoveredPoint);
      _drawTooltip(canvas, hoverIndex!);
    }
  }

  DateTime _windowStart(DateTime now) {
    final oldestPointAt = points.isEmpty ? null : points.first.at;

    return window.startDate(
      end: now,
      oldestPointAt: oldestPointAt,
    );
  }

  List<Offset> _mapPoints(Size size) {
    final chartRect = _ChartLayout.chartRect(size);
    final now = DateTime.now();
    final start = _windowStart(now);

    final minX = start.millisecondsSinceEpoch.toDouble();
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

  Path _smoothPath(List<Offset> mappedPoints) {
    final path = Path()..moveTo(mappedPoints.first.dx, mappedPoints.first.dy);

    for (int i = 0; i < mappedPoints.length - 1; i++) {
      final current = mappedPoints[i];
      final next = mappedPoints[i + 1];
      final midpoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );

      path.quadraticBezierTo(
        current.dx,
        current.dy,
        midpoint.dx,
        midpoint.dy,
      );
    }

    path.lineTo(mappedPoints.last.dx, mappedPoints.last.dy);
    return path;
  }

  Path _extractPathFraction(Path path, double t) {
    if (t >= 0.999) return path;

    final metrics = path.computeMetrics().toList(growable: false);
    if (metrics.isEmpty) return path;

    final totalLength = metrics.fold<double>(
      0,
      (sum, metric) => sum + metric.length,
    );

    final targetLength = totalLength * t;
    var accumulatedLength = 0.0;
    final output = Path();

    for (final metric in metrics) {
      final remaining = targetLength - accumulatedLength;
      if (remaining <= 0) break;

      final visibleLength = min(metric.length, remaining);
      output.addPath(metric.extractPath(0, visibleLength), Offset.zero);

      accumulatedLength += metric.length;
      if (accumulatedLength >= targetLength) break;
    }

    return output;
  }

  void _drawReferenceLine(Canvas canvas, Size size) {
    final chartRect = _ChartLayout.chartRect(size);
    final y = chartRect.center.dy;

    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    const spacing = 3.0;
    const radius = 1.1;

    double x = chartRect.left;
    while (x <= chartRect.right) {
      canvas.drawCircle(Offset(x, y), radius, dotPaint);
      x += spacing;
    }
  }

  void _drawRightYAxis(Canvas canvas, Size size) {
    final chartRect = _ChartLayout.chartRect(size);

    final textStyle = TextStyle(
      fontSize: 7,
      fontWeight: FontWeight.w700,
      color: Colors.white.withValues(alpha: 0.38),
    );

    for (int i = 0; i < _yTickCount; i++) {
      final ratio = i / (_yTickCount - 1);
      final value = maxY - ((maxY - minY) * ratio);
      final y = chartRect.top + (chartRect.height * ratio);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${value.toStringAsFixed(0)} $powerUnitLabel',
          style: textStyle,
        ),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.left,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          chartRect.right + 10,
          y - (textPainter.height / 2),
        ),
      );
    }
  }

  void _drawBottomXAxis(Canvas canvas, Size size) {
    final chartRect = _ChartLayout.chartRect(size);
    final now = DateTime.now();
    final start = _windowStart(now);

    final textStyle = TextStyle(
      fontSize: 7,
      fontWeight: FontWeight.w700,
      color: Colors.white.withValues(alpha: 0.38),
    );

    final totalMillis = now.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    final safeTotalMillis = totalMillis <= 0 ? 1 : totalMillis;

    for (int i = 0; i < _xTickCount; i++) {
      final ratio = i / (_xTickCount - 1);
      final dateTime = start.add(
        Duration(milliseconds: (safeTotalMillis * ratio).round()),
      );

      final label = _formatXAxisLabel(
        dateTime: dateTime,
        start: start,
        end: now,
      );

      final textPainter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      final x = chartRect.left + (chartRect.width * ratio);
      textPainter.paint(
        canvas,
        Offset(
          x - (textPainter.width / 2),
          chartRect.bottom + 10,
        ),
      );
    }
  }

  String _formatXAxisLabel({
    required DateTime dateTime,
    required DateTime start,
    required DateTime end,
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
        if (totalDays <= 2) {
          return DateFormat('HH:mm', localeTag).format(dateTime);
        }

        if (totalDays <= 45) {
          return DateFormat('dd/MM', localeTag).format(dateTime);
        }

        if (totalDays <= 550) {
          return DateFormat('MM/yyyy', localeTag).format(dateTime);
        }

        return DateFormat('yyyy', localeTag).format(dateTime);
    }
  }

  void _drawEmptyLine(Canvas canvas, Rect chartRect) {
    final emptyLinePaint = Paint()
      ..color = AppColors.success.withValues(alpha: 0.85)
      ..strokeWidth = 3.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final y = chartRect.center.dy;
    canvas.drawLine(
      Offset(chartRect.left, y),
      Offset(chartRect.right, y),
      emptyLinePaint,
    );
  }

  void _drawCrosshair(Canvas canvas, Rect chartRect, Offset point) {
    final crosshairPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(point.dx, chartRect.top),
      Offset(point.dx, chartRect.bottom),
      crosshairPaint,
    );
  }

  void _drawDot(Canvas canvas, Offset point) {
    final outerPaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final innerPaint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(point, 6.5, outerPaint);
    canvas.drawCircle(point, 4.0, innerPaint);
  }

  void _drawTooltip(Canvas canvas, int index) {
    final point = points[index];
    final powerLabel = '${point.powerW.toStringAsFixed(0)} $powerUnitLabel';
    final timeLabel = formatTooltipTime(point.at);

    const valueStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: Colors.white,
    );

    final subStyle = TextStyle(
      fontSize: 10,
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
      const Radius.circular(12),
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

  @override
  bool shouldRepaint(covariant _InteractiveChartPainter oldDelegate) {
    return oldDelegate.localeTag != localeTag ||
        oldDelegate.points != points ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY ||
        oldDelegate.revealT != revealT ||
        oldDelegate.hoverIndex != hoverIndex ||
        oldDelegate.window != window ||
        oldDelegate.powerUnitLabel != powerUnitLabel;
  }
}