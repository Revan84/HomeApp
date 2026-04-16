import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Simple rounded container used by the prototype-like screens.
///
/// When [accentColor] is provided the same gradient formula as [CardShell] is
/// applied: top = lerp(card, accent, 0.3) → bottom = AppColors.card.
class PrototypeCard extends StatelessWidget {
  const PrototypeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.x2l),
    this.accentColor,
  });

  final Widget child;
  final EdgeInsets padding;

  /// When set, the card background becomes the same vertical gradient used by
  /// device cards — accent blended at 30% at the top, card base at the bottom.
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration decoration;

    if (accentColor != null) {
      final topColor = Color.lerp(AppColors.card, accentColor!, 0.3)!;
      decoration = BoxDecoration(
        borderRadius: AppRadius.x3lBR,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topColor, AppColors.card],
        ),
        border: Border.all(color: AppColors.border, width: 0.8),
      );
    } else {
      decoration = const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.x3lBR,
      );
    }

    return Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }
}
