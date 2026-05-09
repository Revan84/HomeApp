import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/device_accent_scope.dart';

/// Pill-shaped outline button with a leading "+" icon and a text label.
///
/// The border and icon colour are driven by [DeviceAccentScope] so the button
/// automatically matches the current device-type accent colour.
/// Falls back to [AppColors.primary] outside a device detail screen.
///
/// ```dart
/// AppOutlineAddButton(
///   label: l10n.add,
///   onTap: _addAlert,
/// )
/// ```
class AppOutlineAddButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const AppOutlineAddButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = DeviceAccentScope.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x6l,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.pillBR,
          border: Border.all(color: accent, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.bg.withValues(alpha: 0.50),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 18, color: accent),
            AppSpacing.gapHMd,
            Text(
              label,
              style: TextStyle(
                fontSize: AppFontSizes.md,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
