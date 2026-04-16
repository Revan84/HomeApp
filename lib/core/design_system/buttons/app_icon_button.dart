import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';

/// Visual style variants for [AppIconButton].
enum AppIconButtonVariant {
  /// No background — plain icon with tap ripple.
  flat,

  /// Circular surface background — for secondary actions in cards or headers.
  tinted,
}

/// Icon-only button with consistent sizing, ripple, and optional tooltip.
///
/// ```dart
/// AppIconButton(icon: Icons.refresh, onTap: _reload, tooltip: l10n.refresh)
/// AppIconButton(
///   icon: Icons.delete_outline,
///   onTap: _delete,
///   color: AppColors.danger,
///   variant: AppIconButtonVariant.tinted,
/// )
/// ```
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.size = 20,
    this.variant = AppIconButtonVariant.flat,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;

  /// Defaults to [AppColors.textPrimary].
  final Color? color;
  final double size;
  final AppIconButtonVariant variant;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.textPrimary;

    Widget inner = Icon(icon, size: size, color: iconColor);

    if (variant == AppIconButtonVariant.tinted) {
      inner = Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: inner,
      );
    }

    Widget button = InkWell(
      borderRadius: AppRadius.pillBR,
      onTap: onTap,
      child: Padding(
        padding: variant == AppIconButtonVariant.flat
            ? const EdgeInsets.all(8)
            : EdgeInsets.zero,
        child: inner,
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
