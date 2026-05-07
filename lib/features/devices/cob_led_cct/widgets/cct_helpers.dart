import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';

// Why: warm/cool poles of the CCT gradient — also referenced by
// gradient_slider.dart's track colours. Keep names readable.
const _kCctWarmAmber = Color(0xFFFF9F00);   // 2700 K
const _kCctCoolWhite = Color(0xFFE8F4FF);   // 6500 K

/// Converts a Kelvin colour temperature to a representative [Color].
Color cctTempToColor(int kelvin) {
  final t = ((kelvin - 2700) / (6500 - 2700)).clamp(0.0, 1.0);
  return Color.lerp(_kCctWarmAmber, _kCctCoolWhite, t)!;
}

/// Returns a localised, human-readable label for a Kelvin value.
String cctTempLabel(BuildContext context, int kelvin) {
  final l10n = context.l10n;
  if (kelvin <= 3000) return l10n.cctLabelWarmWhite;
  if (kelvin <= 4500) return l10n.cctLabelNeutralWhite;
  return l10n.cctLabelCoolWhite;
}
