import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Selectable pill chip for use inside [AppDialog] content areas.
///
/// Used for condition rows ("Power (W)" / "Daily Cost") and notification rows
/// ("Push" / "In-App banner"). Pass [icon] for notification-style chips.
/// [accentColor] drives the selected border and tint — use the device accent
/// colour for condition chips and [AppColors.primary] for notification chips.
///
/// ```dart
/// AppDialogChip(
///   label: 'Power (W)',
///   selected: _condition == PlugAlertCondition.wattsExceeded,
///   accentColor: AppColors.plugAccent,
///   onTap: () => setState(() => _condition = PlugAlertCondition.wattsExceeded),
/// )
/// ```
class AppDialogChip extends StatelessWidget {
  const AppDialogChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.accentColor = AppColors.primary,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Optional leading icon (for notification chips).
  final IconData? icon;

  /// Accent colour for selected state — border, tint, text and icon.
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3l,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.12)
              : AppColors.bg,
          borderRadius: AppRadius.pillBR,
          border: Border.all(
            color: selected ? accentColor : AppColors.border,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? accentColor : AppColors.textSecondary,
              ),
              AppSpacing.gapHSm,
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'ShareTech',
                fontSize: AppFontSizes.sm,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? accentColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
