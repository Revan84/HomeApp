import 'package:flutter/material.dart';

/// Shadow presets used consistently across the app.
///
/// All shadows use a dark base colour expressed as a compile-time [Color]
/// constant so they can be declared `const`.
///
/// Usage:
///   boxShadow: AppShadows.subtle
///   boxShadow: AppShadows.moderate
///   boxShadow: AppShadows.glow(AppColors.primary)
abstract final class AppShadows {
  // 0x38 hex alpha ≈ 0.22 opacity (56 / 255)
  static const Color _dark22 = Color(0x38000000);

  /// Subtle lift — pill tiles (favorites list, rooms list).
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: _dark22,
      blurRadius: 3,
      spreadRadius: 1,
      offset: Offset(1, 5),
    ),
  ];

  /// Moderate drop — room pills, floating add buttons.
  static const List<BoxShadow> moderate = [
    BoxShadow(
      color: _dark22,
      blurRadius: 14,
      offset: Offset(0, 5),
    ),
  ];

  /// Coloured glow — bottom-nav active indicator, accent elements.
  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.55),
      blurRadius: 18,
      spreadRadius: 6,
      offset: const Offset(0, 6),
    ),
  ];

  // ── MiniToggle inner-shadow gradients ──────────────────────────────────────
  //
  // Flutter doesn't support CSS-style inner shadows via BoxShadow.
  // The correct approach is a gradient overlay rendered inside a ClipRRect
  // Stack so the dark layer is clipped to the pill shape.

  /// Gradient overlay on the green track when ON.
  /// Dark at top-left → transparent at bottom-right — gives depth/concavity.
  static const Gradient toggleOnTrack = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x44000000), Color(0x00000000)],
    stops: [0.0, 0.7],
  );

  /// Gradient overlay on the dark track when OFF.
  /// Strong dark at top → lighter at bottom — sunken/recessed slot look.
  static const Gradient toggleOffTrack = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x99000000), Color(0x33000000)],
  );

  /// Radial gradient for the dark thumb circle when ON.
  /// Slightly lighter rim → very dark center — concave pressed-button look.
  static const Gradient toggleOnThumb = RadialGradient(
    center: Alignment(-0.2, -0.3),
    radius: 1.1,
    colors: [Color(0xFF2A2A2A), Color(0xFF0C0C0C)],
  );
}
