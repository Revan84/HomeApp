import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

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
              borderRadius: BorderRadius.circular(25),
              onTap: onTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    width: 0.7,
                    color: AppColors.stroke.withValues(alpha: 0.90),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 3,
                      spreadRadius: 1,
                      offset: const Offset(1, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(icon, color: AppColors.textPrimary, size: 21),
                    const SizedBox(width: 14),
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
                    const SizedBox(width: 10),
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 24),
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
        const SizedBox(width: 8),
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
