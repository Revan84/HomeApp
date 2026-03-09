import 'dart:math';

import '../../../domain/models/live_point.dart';

/// Computes readable Y-axis bounds for power charts.
///
/// Goal: keep the graph scale close to the real consumption range (e.g. 0-50W)
/// while keeping labels "nice" (1/2/5 * 10^n).
({double minY, double maxY}) computeNicePowerBounds(List<LivePoint> pts) {
  if (pts.isEmpty) return (minY: 0, maxY: 1);

  var minP = pts.first.powerW;
  var maxP = pts.first.powerW;
  for (final p in pts) {
    if (p.powerW < minP) minP = p.powerW;
    if (p.powerW > maxP) maxP = p.powerW;
  }

  final span = (maxP - minP).abs();
  final pad = span < 1 ? 1.0 : span * 0.15;
  minP = (minP - pad).clamp(0, double.infinity);
  maxP = maxP + pad;

  double niceStep(double raw) {
    if (raw <= 0) return 1;
    final exp = (log(raw) / ln10).floor();
    final base = raw / pow(10, exp);

    final niceBase = (base <= 1)
        ? 1
        : (base <= 2)
            ? 2
            : (base <= 5)
                ? 5
                : 10;

    return niceBase * pow(10, exp).toDouble();
  }

  final step = niceStep((maxP - minP) / 3);
  final niceMin = (minP / step).floorToDouble() * step;
  final niceMax = (maxP / step).ceilToDouble() * step;

  final outMin = niceMin;
  final outMax = (niceMax == niceMin) ? niceMin + 1 : niceMax;
  return (minY: outMin, maxY: outMax);
}
