import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';

/// Background color variants for [AppCard].
enum AppCardVariant {
  /// Elevated surface — modals, bottom sheets, settings panels, info cards.
  surface,

  /// Warm dark base — device cards, content cards inside the main scaffold.
  card,
}

/// Standard content card.
///
/// Provides the app's rounded container with border and background.
/// All internal layout is left to the caller — no opinionated columns/rows.
///
/// ```dart
/// // Basic info card
/// AppCard(child: EquipmentInfoGrid(...))
///
/// // Tappable card with warm-dark background
/// AppCard(
///   variant: AppCardVariant.card,
///   onTap: _openDetails,
///   child: DeviceRow(...),
/// )
///
/// // Card with drop shadow
/// AppCard(shadow: true, child: SummaryBlock(...))
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.variant = AppCardVariant.surface,
    this.onTap,
    this.shadow = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final AppCardVariant variant;

  /// Makes the entire card tappable with a ripple effect.
  final VoidCallback? onTap;

  /// Applies [AppShadows.subtle] beneath the card.
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final bg = switch (variant) {
      AppCardVariant.surface => AppColors.surface,
      AppCardVariant.card    => AppColors.card,
    };

    final decoration = BoxDecoration(
      borderRadius: AppRadius.x3lBR,
      border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),
      boxShadow: shadow ? AppShadows.subtle : null,
    );

    if (onTap != null) {
      return Material(
        color: bg,
        borderRadius: AppRadius.x3lBR,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            padding: padding,
            decoration: decoration,
            child: child,
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: decoration.copyWith(color: bg),
      child: Padding(padding: padding, child: child),
    );
  }
}
