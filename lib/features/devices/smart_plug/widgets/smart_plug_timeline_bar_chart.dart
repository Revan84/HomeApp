import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/device_accent_scope.dart';
import '../../../../domain/entities/history_window.dart';
import '../../../../domain/entities/live_point.dart';

// ─── Timeline bar chart ───────────────────────────────────────────────────────
//
// Vertical bar chart driven by real LivePoint history.
// Bars represent average power (W) per time bucket.

class SmartPlugTimelineBarChart extends StatelessWidget {
  final List<LivePoint> points;
  final HistoryWindow window;
  final double height;
  final String unitLabel;

  const SmartPlugTimelineBarChart({
    super.key,
    required this.points,
    required this.window,
    required this.height,
    required this.unitLabel,
  });

  @override
  Widget build(BuildContext context) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: AppRadius.lgBR,
      ),
      child: CustomPaint(
        painter: _BarChartPainter(
          points: points,
          window: window,
          unitLabel: unitLabel,
          localeTag: localeTag,
          barColor: DeviceAccentScope.of(context),
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<LivePoint> points;
  final HistoryWindow window;
  final String unitLabel;
  final String localeTag;
  final Color barColor;

  static const double _lPad = 8;
  static const double _rPad = 38;
  static const double _tPad = 10;
  static const double _bPad = 26;

  const _BarChartPainter({
    required this.points,
    required this.window,
    required this.unitLabel,
    required this.localeTag,
    required this.barColor,
  });

  // ── bucketing ────────────────────────────────────────────────────────────────

  int get _bucketCount => switch (window) {
    HistoryWindow.d1  => 24,
    HistoryWindow.w1  => 7,
    HistoryWindow.m1  => 30,
    HistoryWindow.y1  => 12,
    HistoryWindow.max => 20,
  };

  DateTime _windowStart(DateTime now) {
    final oldest = points.isEmpty ? null : points.first.at;
    return window.startDate(end: now, oldestPointAt: oldest);
  }

  List<double> _bucket(DateTime start, DateTime end) {
    final count  = _bucketCount;
    final sums   = List<double>.filled(count, 0);
    final counts = List<int>.filled(count, 0);
    final spanMs = max(1, end.millisecondsSinceEpoch - start.millisecondsSinceEpoch);

    for (final p in points) {
      if (p.at.isBefore(start) || p.at.isAfter(end)) continue;
      final ratio = (p.at.millisecondsSinceEpoch - start.millisecondsSinceEpoch) / spanMs;
      final idx   = (ratio * count).floor().clamp(0, count - 1);
      sums[idx]  += p.powerW;
      counts[idx]++;
    }

    return List.generate(count, (i) => counts[i] > 0 ? sums[i] / counts[i] : 0);
  }

  // ── label formatting ─────────────────────────────────────────────────────────

  String _xLabel(DateTime dt, DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    return switch (window) {
      HistoryWindow.d1 => DateFormat('HH:mm', localeTag).format(dt),
      HistoryWindow.w1 || HistoryWindow.m1 => DateFormat('dd/MM', localeTag).format(dt),
      HistoryWindow.y1 => DateFormat('MM/yy', localeTag).format(dt),
      HistoryWindow.max when days <= 2   => DateFormat('HH:mm', localeTag).format(dt),
      HistoryWindow.max when days <= 45  => DateFormat('dd/MM', localeTag).format(dt),
      HistoryWindow.max when days <= 550 => DateFormat('MM/yy', localeTag).format(dt),
      HistoryWindow.max                  => DateFormat('yyyy',  localeTag).format(dt),
    };
  }

  static TextStyle get _axisStyle => TextStyle(
    fontSize: 7,
    fontWeight: FontWeight.w700,
    color: Colors.white.withValues(alpha: 0.38),
  );

  // ── paint ────────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final chart = Rect.fromLTWH(
      _lPad, _tPad,
      max(1, size.width - _lPad - _rPad),
      max(1, size.height - _tPad - _bPad),
    );

    final now    = DateTime.now();
    final start  = _windowStart(now);
    final values = _bucket(start, now);
    final maxVal = values.fold(0.0, max) * 1.15;

    _drawBars(canvas, chart, values, maxVal > 0 ? maxVal : 100);
    _drawXLabels(canvas, chart, start, now);
    _drawYLabels(canvas, chart, maxVal > 0 ? maxVal : 100);
  }

  void _drawBars(Canvas canvas, Rect chart, List<double> values, double maxVal) {
    final count    = values.length;
    final slotW    = chart.width / count;
    const gapFrac  = 0.18; // gap as fraction of slot width
    final barW     = slotW * (1 - gapFrac);
    final halfGap  = slotW * gapFrac / 2;

    final bgPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    const radius = Radius.circular(3);

    for (int i = 0; i < count; i++) {
      final x = chart.left + i * slotW + halfGap;

      // Background slot
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, chart.top, barW, chart.height), radius),
        bgPaint,
      );

      // Filled portion
      final fillH = (values[i] / maxVal).clamp(0.0, 1.0) * chart.height;
      if (fillH > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, chart.bottom - fillH, barW, fillH),
            radius,
          ),
          fillPaint,
        );
      }
    }
  }

  void _drawXLabels(Canvas canvas, Rect chart, DateTime start, DateTime end) {
    const labelCount = 5;
    final spanMs = max(1, end.millisecondsSinceEpoch - start.millisecondsSinceEpoch);

    for (int i = 0; i < labelCount; i++) {
      final ratio = i / (labelCount - 1);
      final dt    = start.add(Duration(milliseconds: (spanMs * ratio).round()));
      final label = _xLabel(dt, start, end);

      final tp = TextPainter(
        text: TextSpan(text: label, style: _axisStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();

      final x = chart.left + ratio * chart.width;
      tp.paint(canvas, Offset(x - tp.width / 2, chart.bottom + 6));
    }
  }

  void _drawYLabels(Canvas canvas, Rect chart, double maxVal) {
    const ticks = 3;
    for (int i = 0; i < ticks; i++) {
      final ratio = i / (ticks - 1);
      final value = maxVal * (1 - ratio);
      final y     = chart.top + chart.height * ratio;
      final label = '${value.toStringAsFixed(0)} $unitLabel';

      final tp = TextPainter(
        text: TextSpan(text: label, style: _axisStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(chart.right + 4, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.points != points ||
      old.window != window ||
      old.localeTag != localeTag ||
      old.barColor != barColor;
}
