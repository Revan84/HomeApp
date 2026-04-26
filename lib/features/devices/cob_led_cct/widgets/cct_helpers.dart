import 'package:flutter/material.dart';

/// Converts a Kelvin colour temperature to a representative [Color].
Color cctTempToColor(int kelvin) {
  const warm = Color(0xFFFF9F00);
  const cool = Color(0xFFE8F4FF);
  final t = ((kelvin - 2700) / (6500 - 2700)).clamp(0.0, 1.0);
  return Color.lerp(warm, cool, t)!;
}

/// Returns a human-readable label for a Kelvin value.
String cctTempLabel(int kelvin) {
  if (kelvin <= 3000) return 'Warm white';
  if (kelvin <= 4500) return 'Neutral white';
  return 'Cool white';
}
