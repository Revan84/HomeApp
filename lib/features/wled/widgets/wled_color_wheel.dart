import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Circular HSV color-picker wheel with a vertical brightness bar.
/// Mirrors the SmartThings / WLED app color-picker style.
class WledColorWheel extends StatefulWidget {
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const WledColorWheel({
    super.key,
    required this.color,
    required this.onColorChanged,
  });

  @override
  State<WledColorWheel> createState() => _WledColorWheelState();
}

class _WledColorWheelState extends State<WledColorWheel> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.color);
  }

  @override
  void didUpdateWidget(WledColorWheel old) {
    super.didUpdateWidget(old);
    if (widget.color != old.color) {
      _hsv = HSVColor.fromColor(widget.color);
    }
  }

  void _updateFromWheel(Offset local, Size size) {
    final radius = size.shortestSide / 2;
    final center = Offset(radius, radius);
    final dx = local.dx - center.dx;
    final dy = local.dy - center.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist > radius) return;

    final hue = (math.atan2(dy, dx) * 180 / math.pi + 360) % 360;
    final sat = (dist / radius).clamp(0.0, 1.0);
    _hsv = _hsv.withHue(hue).withSaturation(sat);
    widget.onColorChanged(_hsv.toColor());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final wheelSize = constraints.maxWidth - 44; // leave room for bar
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Color wheel
            GestureDetector(
              onPanStart: (d) =>
                  _updateFromWheel(d.localPosition, Size(wheelSize, wheelSize)),
              onPanUpdate: (d) =>
                  _updateFromWheel(d.localPosition, Size(wheelSize, wheelSize)),
              onTapDown: (d) =>
                  _updateFromWheel(d.localPosition, Size(wheelSize, wheelSize)),
              child: SizedBox(
                width: wheelSize,
                height: wheelSize,
                child: CustomPaint(
                  painter: _ColorWheelPainter(_hsv),
                ),
              ),
            ),
            AppSpacing.gapHXl,
            // Vertical brightness bar
            Expanded(
              child: _BrightnessBar(
                hsv: _hsv,
                onChanged: (val) {
                  setState(() => _hsv = _hsv.withValue(val));
                  widget.onColorChanged(_hsv.toColor());
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Color wheel painter
// ---------------------------------------------------------------------------

class _ColorWheelPainter extends CustomPainter {
  final HSVColor hsv;

  _ColorWheelPainter(this.hsv);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // --- Layer 1: Sweep gradient (hue ring) ---
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: const [
          Color(0xFFFF0000),
          Color(0xFFFFFF00),
          Color(0xFF00FF00),
          Color(0xFF00FFFF),
          Color(0xFF0000FF),
          Color(0xFFFF00FF),
          Color(0xFFFF0000),
        ],
      ).createShader(rect);
    canvas.drawCircle(center, radius, sweepPaint);

    // --- Layer 2: Radial saturation (white fade from center) ---
    final radialPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.white.withValues(alpha: 0)],
      ).createShader(rect);
    canvas.drawCircle(center, radius, radialPaint);

    // --- Layer 3: Brightness (darken toward black) ---
    final darkPaint = Paint()
      ..color = Colors.black.withValues(alpha: 1.0 - hsv.value);
    canvas.drawCircle(center, radius, darkPaint);

    // --- Selector indicator ---
    final angle = hsv.hue * math.pi / 180;
    final dist = hsv.saturation * radius;
    final pos = Offset(
      center.dx + math.cos(angle) * dist,
      center.dy + math.sin(angle) * dist,
    );
    canvas.drawCircle(
      pos,
      10,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      pos,
      7,
      Paint()..color = hsv.withValue(1).withSaturation(hsv.saturation).toColor(),
    );
  }

  @override
  bool shouldRepaint(_ColorWheelPainter old) => old.hsv != hsv;
}

// ---------------------------------------------------------------------------
// Vertical brightness bar
// ---------------------------------------------------------------------------

class _BrightnessBar extends StatelessWidget {
  final HSVColor hsv;
  final ValueChanged<double> onChanged;

  const _BrightnessBar({required this.hsv, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final fullColor = hsv.withValue(1).withSaturation(hsv.saturation).toColor();

    return LayoutBuilder(
      builder: (_, constraints) {
        final height = constraints.maxHeight > 0
            ? constraints.maxHeight
            : 160.0;
        final indicatorY = (1.0 - hsv.value) * height;

        return GestureDetector(
          onVerticalDragUpdate: (d) =>
              onChanged((1.0 - (d.localPosition.dy / height)).clamp(0.0, 1.0)),
          onTapDown: (d) =>
              onChanged((1.0 - (d.localPosition.dy / height)).clamp(0.0, 1.0)),
          child: SizedBox(
            width: 24,
            height: height,
            child: Stack(
              children: [
                // Gradient track
                Container(
                  width: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.mdBR,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [fullColor, Colors.black],
                    ),
                  ),
                ),
                // Indicator circle
                Positioned(
                  top: indicatorY - 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hsv.toColor(),
                        border: Border.all(
                          color: AppColors.textPrimary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Horizontal brightness & speed sliders
// ---------------------------------------------------------------------------

class WledSlider extends StatelessWidget {
  final double value;  // 0.0–1.0
  final ValueChanged<double> onChanged;
  final Color trackColor;
  final Color thumbColor;

  const WledSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.trackColor = AppColors.border,
    this.thumbColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: thumbColor.withValues(alpha: 0.9),
        inactiveTrackColor: AppColors.border,
        thumbColor: thumbColor,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
        trackHeight: 4,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        overlayColor: thumbColor.withValues(alpha: 0.15),
      ),
      child: Slider(
        value: value.clamp(0.0, 1.0),
        onChanged: onChanged,
      ),
    );
  }
}
