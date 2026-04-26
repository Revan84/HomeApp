import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/device_accent_scope.dart';
import '../../../../../../domain/entities/history_window.dart';
import '../../../../../../domain/entities/live_point.dart';

import 'chart_geometry.dart';
import 'chart_renderers.dart';

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
  State<InteractiveLineChart> createState() => _InteractiveLineChartState();
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

  DateTime _windowStart(DateTime now) => ChartGeometry.windowStart(
        window: widget.window,
        points: widget.points,
        now: now,
      );

  int _nearestPointIndex({
    required Offset localPosition,
    required Size size,
    required List<LivePoint> points,
  }) {
    if (points.isEmpty) return 0;
    if (points.length == 1) return 0;

    final chartRect = ChartLayout.chartRect(size);
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

    setState(() => _hoverIndex = index);
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
    final now = DateTime.now();
    return ChartAxisRenderer.formatXAxisLabel(
      dateTime: dateTime,
      start: _windowStart(now),
      end: now,
      window: widget.window,
      localeTag: Localizations.localeOf(context).toLanguageTag(),
    );
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
                    lineColor: DeviceAccentScope.of(context),
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

/// Orchestrates all chart drawing by delegating to [ChartGeometry],
/// [ChartGridRenderer], [ChartAxisRenderer], and [ChartHoverRenderer].
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
    required this.lineColor,
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
  final Color lineColor;
  final String Function(DateTime dateTime) formatTooltipTime;

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final start =
        ChartGeometry.windowStart(window: window, points: points, now: now);
    final chartRect = ChartLayout.chartRect(size);

    // ── Background + static chrome ─────────────────────────────────────────
    ChartGridRenderer.drawBackground(canvas, size);
    ChartGridRenderer.drawReferenceLine(canvas, chartRect);
    ChartAxisRenderer.drawRightYAxis(
      canvas, chartRect,
      minY: minY, maxY: maxY, powerUnitLabel: powerUnitLabel,
    );

    // ── Early exit: not enough data ────────────────────────────────────────
    if (points.length < 2) {
      ChartAxisRenderer.drawBottomXAxis(
        canvas, chartRect,
        start: start, now: now, window: window, localeTag: localeTag,
      );
      ChartGridRenderer.drawEmptyLine(canvas, chartRect, lineColor);
      return;
    }

    // ── Map domain points → canvas pixels ─────────────────────────────────
    final mappedPoints = ChartGeometry.mapPoints(
      chartRect: chartRect,
      points: points,
      windowStart: start,
      now: now,
      minY: minY,
      maxY: maxY,
    );
    ChartAxisRenderer.drawBottomXAxis(
      canvas, chartRect,
      start: start, now: now, window: window, localeTag: localeTag,
    );

    if (mappedPoints.length < 2) {
      ChartGridRenderer.drawEmptyLine(canvas, chartRect, lineColor);
      return;
    }

    // ── Line paint (shared) ────────────────────────────────────────────────
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final isHovering =
        hoverIndex != null &&
        hoverIndex! >= 0 &&
        hoverIndex! < mappedPoints.length;

    if (isHovering) {
      final idx = hoverIndex!;

      // After segment (grey) — drawn first so primary sits on top at the split.
      if (idx < mappedPoints.length - 1) {
        final afterPath = ChartGeometry.smoothPath(mappedPoints.sublist(idx));
        final greyPaint = Paint()
          ..color = AppColors.textSecondary.withValues(alpha: 0.30)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true;
        canvas.drawPath(afterPath, greyPaint);
      }

      // Before segment (primary).
      final beforePath =
          ChartGeometry.smoothPath(mappedPoints.sublist(0, idx + 1));
      canvas.drawPath(beforePath, linePaint);

      final hoveredPoint = mappedPoints[idx];
      ChartHoverRenderer.drawCrosshair(canvas, chartRect, hoveredPoint);
      ChartHoverRenderer.drawDot(canvas, hoveredPoint, lineColor);
      ChartHoverRenderer.drawTooltip(
        canvas, idx, points,
        powerUnitLabel: powerUnitLabel,
        formatTooltipTime: formatTooltipTime,
      );
    } else {
      // Normal state: animated reveal of the full line.
      final linePath = ChartGeometry.smoothPath(mappedPoints);
      final revealedPath =
          ChartGeometry.extractPathFraction(linePath, revealT.clamp(0.0, 1.0));
      canvas.drawPath(revealedPath, linePaint);
    }
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
        oldDelegate.powerUnitLabel != powerUnitLabel ||
        oldDelegate.lineColor != lineColor;
  }
}
