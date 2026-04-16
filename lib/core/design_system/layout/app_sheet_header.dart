import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Standard bottom-sheet header: optional drag handle, title row, close button.
///
/// Appears in every add/edit sheet in the app. Centralised here to eliminate
/// the repeated `Row(title Text + IconButton(close))` boilerplate.
///
/// ```dart
/// // Simple (room group sheet)
/// AppSheetHeader(title: l10n.roomsAddGroupTitle, onClose: () => Navigator.pop(context, false))
///
/// // With leading icon (WLED / TV add sheet)
/// AppSheetHeader(
///   title: l10n.wledAddTitle,
///   leadingIcon: Icons.lightbulb_outline_rounded,
///   onClose: () => Navigator.pop(context, false),
/// )
///
/// // With drag handle (equipment / WLED / TV add sheet)
/// AppSheetHeader(title: l10n.addEquipmentTitle, showDragHandle: true, onClose: ...)
/// ```
class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({
    super.key,
    required this.title,
    required this.onClose,
    this.leadingIcon,
    this.showDragHandle = false,
    this.closeTooltip,
  });

  final String title;
  final VoidCallback onClose;

  /// Optional icon shown left of the title.
  final IconData? leadingIcon;

  /// When true, renders the pill drag handle above the title row.
  final bool showDragHandle;

  /// Tooltip for the close icon button. Falls back to the Material default.
  final String? closeTooltip;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDragHandle) ...[
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          AppSpacing.gapXl,
        ],
        Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 22, color: AppColors.textPrimary),
              AppSpacing.gapHLg,
            ],
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              tooltip: closeTooltip,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ],
    );
  }
}
