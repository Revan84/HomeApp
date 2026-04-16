import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';

/// Pill-shaped list item representing a favorite device.
class FavoritePillTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color statusColor;
  final String removeTooltip;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoritePillTile({
    super.key,
    required this.icon,
    required this.title,
    required this.statusColor,
    required this.removeTooltip,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.x4lBR,
              onTap: onTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: AppRadius.pillBR,
                  border: Border.all(
                    width: 0.7,
                    color: AppColors.border.withValues(alpha: 0.90),
                  ),
                  boxShadow: AppShadows.subtle,
                ),
                child: Row(
                  children: [
                    Icon(icon, color: AppColors.textPrimary, size: 21),
                    AppSpacing.gapHX2l,
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    AppSpacing.gapHLg,
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.gapHX6l,
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AppSpacing.gapHMd,
        IconButton(
          tooltip: removeTooltip,
          onPressed: onRemove,
          icon: Icon(
            Icons.remove,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ],
    );
  }
}
