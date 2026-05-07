import 'package:flutter/material.dart';

/// A slider whose track is painted as a warm-to-cool gradient.
///
/// Uses a custom [SliderTrackShape] so Flutter's built-in gesture handling
/// (hit-test area, thumb rendering, accessibility) is fully preserved.
///
/// Note: track colors must NOT be [Colors.transparent] — Flutter 3.x's
/// [BaseSliderTrackShape.getPreferredRect] sets trackHeight = 0 when both
/// active and inactive track colors are transparent, making the track
/// invisible and breaking layout.  The gradient overrides the colors anyway.
// Why: must match cct_helpers.dart's _kCctWarmAmber / _kCctCoolWhite — these
// are the 2700 K / 6500 K poles of the same CCT gradient. Mirrored names so a
// future grep links the two files.
const _kCctWarmAmber = Color(0xFFFF9F00);   // 2700 K
const _kCctCoolWhite = Color(0xFFE8F4FF);   // 6500 K

class CobLedCctGradientSlider extends StatelessWidget {
  const CobLedCctGradientSlider({
    super.key,
    required this.value,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final double value;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8,
        trackShape: const _GradientTrackShape(),
        // Non-transparent so BaseSliderTrackShape.getPreferredRect keeps the
        // track height at 8 dp.  The custom paint overrides these with gradient.
        activeTrackColor: _kCctWarmAmber,
        inactiveTrackColor: _kCctCoolWhite,
        thumbColor: Colors.white,
        thumbShape: const _BorderedThumbShape(radius: 11),
        overlayColor: const Color(0xFFDBA528),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
      ),
      child: Slider(
        value: value,
        onChangeStart: onChangeStart,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
}

// ── Bordered thumb shape ──────────────────────────────────────────────────────

class _BorderedThumbShape extends SliderComponentShape {
  const _BorderedThumbShape({
    this.radius = 11,
    this.borderColor = const Color(0xFFDBA528),
  });

  final double radius;
  final Color borderColor;

  static const double _borderWidth = 2.5;
  static const double _elevation = 3;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Shadow
    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.drawShadow(shadowPath, Colors.black, _elevation, true);

    // White fill
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = sliderTheme.thumbColor ?? Colors.white,
    );

    // Border
    canvas.drawCircle(
      center,
      radius - _borderWidth / 2,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _borderWidth,
    );
  }
}

// ── Accent slider (luminosity / speed) ───────────────────────────────────────

/// A plain slider using the accent colour for the active track, a drop shadow
/// on the track, and the shared bordered thumb.
///
/// Used for luminosity and speed controls.
class CobLedCctAccentSlider extends StatelessWidget {
  const CobLedCctAccentSlider({
    super.key,
    required this.value,
    required this.accentColor,
    required this.activeTrackColor,
    required this.inactiveTrackColor,
    required this.onChangeStart,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final double value;
  final Color accentColor;
  final Color activeTrackColor;
  final Color inactiveTrackColor;
  final ValueChanged<double> onChangeStart;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8,
        trackShape: _ShadowedTrackShape(
          activeColor: activeTrackColor,
          inactiveColor: inactiveTrackColor,
        ),
        activeTrackColor: activeTrackColor,
        inactiveTrackColor: inactiveTrackColor,
        thumbColor: Colors.white,
        thumbShape: _BorderedThumbShape(
          radius: 11,
          borderColor: accentColor,
        ),
        overlayColor: accentColor.withValues(alpha: 0.12),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),
      child: Slider(
        value: value,
        onChangeStart: onChangeStart,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
}

// ── Shadowed track shape ──────────────────────────────────────────────────────

/// Track shape with a soft drop shadow, active colour on the left of the thumb,
/// inactive colour on the right.
class _ShadowedTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  const _ShadowedTrackShape({
    required this.activeColor,
    required this.inactiveColor,
  });

  final Color activeColor;
  final Color inactiveColor;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final radius = Radius.circular(trackRect.height / 2);
    final fullRRect = RRect.fromRectAndRadius(trackRect, radius);

    // Drop shadow on the full track
    final shadowPath = Path()..addRRect(fullRRect);
    context.canvas.drawShadow(
      shadowPath,
      Colors.black.withValues(alpha: 0.45),
      3,
      false,
    );

    // Inactive track (full background)
    context.canvas.drawRRect(
      fullRRect,
      Paint()..color = inactiveColor,
    );

    // Active track — clipped to the rounded rect so edges stay rounded
    if (thumbCenter.dx > trackRect.left) {
      final activeRect = Rect.fromLTRB(
        trackRect.left,
        trackRect.top,
        thumbCenter.dx.clamp(trackRect.left, trackRect.right),
        trackRect.bottom,
      );
      context.canvas
        ..save()
        ..clipRRect(fullRRect)
        ..drawRect(activeRect, Paint()..color = activeColor)
        ..restore();
    }
  }
}

// ── Gradient track shape ──────────────────────────────────────────────────────

class _GradientTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  const _GradientTrackShape();

  static const _colors = [
    _kCctWarmAmber,     // 2700 K — warm amber
    Color(0xFFFFD080),  // ~3800 K
    Color(0xFFFFFFE0),  // ~5500 K — neutral
    _kCctCoolWhite,     // 6500 K — cool white
  ];

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final radius = Radius.circular(trackRect.height / 2);
    final paint = Paint()
      ..shader = LinearGradient(colors: _colors).createShader(trackRect);

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, radius),
      paint,
    );
  }
}
