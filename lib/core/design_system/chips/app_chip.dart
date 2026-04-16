import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Visual style variants for [AppChip].
enum AppChipVariant {
  /// Toggleable chip — selected → green fill + dark text.
  /// Used for range selectors, on/off toggles, scene pickers.
  filter,

  /// Selector chip — fond [AppColors.surface] fixe, bordure qui change
  /// de couleur selon la sélection (primary si sélectionné, sinon neutre).
  /// Used for room/area filters, category pickers, dropdown triggers.
  outlined,

  /// Static display chip — no selection state, used for read-only tags.
  tag,
}

/// Small chip for filters, category selectors, and read-only tags.
///
/// ```dart
/// // Selector chip (room filter — home page style)
/// AppChip(
///   label: 'Salon (3)',
///   selected: _roomId == salon.id,
///   variant: AppChipVariant.outlined,
///   onTap: () => setState(() => _roomId = salon.id),
/// )
///
/// // Dropdown trigger (equipment tab filter)
/// AppChip(
///   label: roomLabel,
///   variant: AppChipVariant.outlined,
///   trailing: Icons.keyboard_arrow_down_rounded,
///   onTap: _showRoomMenu,
/// )
///
/// // Fill chip (scene selector / range picker)
/// AppChip(label: '1D', selected: _window == d1, onTap: () => _set(d1))
///
/// // Read-only tag
/// AppChip(label: 'Online', leading: Icons.wifi, variant: AppChipVariant.tag)
/// ```
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leading,
    this.trailing,
    this.variant = AppChipVariant.filter,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Leading icon — shown before the label.
  final IconData? leading;

  /// Trailing icon — shown after the label (e.g. chevron for dropdowns).
  final IconData? trailing;

  final AppChipVariant variant;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Border border;

    switch (variant) {
      case AppChipVariant.filter:
        bg = selected ? AppColors.primary : AppColors.surface;
        fg = selected ? AppColors.bg : AppColors.textSecondary;
        border = selected
            ? Border.all(color: Colors.transparent)
            : Border.all(color: AppColors.border.withValues(alpha: 0.4));

      case AppChipVariant.outlined:
        // Fond toujours surface, bordure colorée selon la sélection.
        bg = AppColors.surface;
        fg = selected ? AppColors.primary : AppColors.textPrimary;
        border = Border.all(
          color: selected ? AppColors.primary : AppColors.border.withValues(alpha: 0.5),
        );

      case AppChipVariant.tag:
        bg = AppColors.surface;
        fg = AppColors.textSecondary;
        border = Border.all(color: AppColors.border.withValues(alpha: 0.4));
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.chipBR,
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Icon(leading, size: 14, color: fg),
              AppSpacing.gapHXs,
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
            if (trailing != null) ...[
              AppSpacing.gapHXs,
              Icon(trailing, size: 14, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}
