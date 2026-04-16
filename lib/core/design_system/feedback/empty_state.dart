import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../buttons/app_button.dart';

/// Centered empty-state with icon, title, optional subtitle, and optional CTA.
///
/// ```dart
/// // Minimal
/// AppEmptyState(icon: Icons.devices_other, title: l10n.noEquipments)
///
/// // With subtitle and retry action
/// AppEmptyState(
///   icon: Icons.wifi_off,
///   title: 'No connection',
///   subtitle: 'Check your network settings',
///   action: AppEmptyStateAction(label: 'Retry', onPressed: _reload),
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final AppEmptyStateAction? action;

  /// Overrides the default muted icon color.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 52,
              color: iconColor ??
                  AppColors.textSecondary.withValues(alpha: 0.55),
            ),
            AppSpacing.gapX3l,
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
            if (subtitle != null) ...[
              AppSpacing.gapMd,
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
            if (action != null) ...[
              AppSpacing.gapX6l,
              AppButton(
                label: action!.label,
                onPressed: action!.onPressed,
                variant: AppButtonVariant.secondary,
                compact: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Action configuration for [AppEmptyState].
class AppEmptyStateAction {
  const AppEmptyStateAction({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;
}
