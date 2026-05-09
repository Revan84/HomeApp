import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';

// ─── Menu item row ────────────────────────────────────────────────────────────
// Icon + text row used in PopupMenu.

class DetailMenuItemRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const DetailMenuItemRow({
    super.key,
    required this.icon,
    required this.label,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 16, color: color),
      AppSpacing.gapHMd,
      Text(
        label,
        style: TextStyle(
          fontSize: AppFontSizes.body,
          color: color,
        ),
      ),
    ],
  );
}
