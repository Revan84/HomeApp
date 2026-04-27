import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';

/// Pill-shaped list tile representing a device in the favorites browser.
///
/// Shows the device icon, name + online dot, subtitle (room · type · live
/// value), a chevron for navigation, and a heart button to toggle the favorite
/// status — filled when [isFavorite] is true, outlined otherwise.
class FavoritePillTile extends StatelessWidget {
  final IconData icon;
  final String title;

  /// Pre-formatted subtitle: "Salon · Smart Plug · 64 W"
  final String subtitle;

  final bool isOnline;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const FavoritePillTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isOnline,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dotColor = isOnline ? AppColors.success : AppColors.textSecondary;

    return Row(
      children: [
        // ── Main tappable pill ───────────────────────────────────────────────
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.x4lBR,
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
                    Icon(icon, color: AppColors.textSecondary, size: 20),
                    AppSpacing.gapHX2l,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Name + online dot
                          Row(
                            children: [
                              Flexible(
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
                              AppSpacing.gapHSm,
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.gapXxs,
                          // Subtitle: room · type · live value
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.gapHMd,
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // ── Heart toggle ─────────────────────────────────────────────────────
        IconButton(
          onPressed: onToggleFavorite,
          icon: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? AppColors.primary : AppColors.textSecondary,
            size: 22,
          ),
        ),
      ],
    );
  }
}
