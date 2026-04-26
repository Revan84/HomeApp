import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Standard list tile for a device entry.
///
/// Used in the Equipments tab and Favorites list.
///
/// ```dart
/// DeviceListTile(
///   icon: Icons.power,
///   iconColor: AppColors.plugAccent,
///   title: 'Desk Plug',
///   subtitle: 'Salon · Smart Plug · 64 W',
///   dotColor: Colors.green,
///   onTap: () => _open(equipment),
/// )
/// ```
class DeviceListTile extends StatelessWidget {
  const DeviceListTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.dotColor,
    required this.onTap,
  });

  /// Icon displayed in the leading rounded square.
  final IconData icon;

  /// Colour used for the icon and its background tint.
  final Color iconColor;

  /// Device display name.
  final String title;

  /// Pre-formatted secondary line, e.g. "Salon · Smart Plug · 64 W".
  final String subtitle;

  /// Online indicator dot colour.
  final Color dotColor;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.x3lBR,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.x2lBR,
            border: Border.all(color: AppColors.border, width: 0.6),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x2l,
              vertical: AppSpacing.x2l,
            ),
            child: Row(
              children: [
                // ── Icon box ─────────────────────────────────────────────
                Icon(icon, size: 24, color: AppColors.textPrimary),

                AppSpacing.gapHX2l,

                // ── Text column ──────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row + online dot
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'ShareTech',
                                fontWeight: FontWeight.w500,
                                fontSize: AppFontSizes.heading,
                                color: AppColors.textPrimary,
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
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'ShareTech',
                            fontSize: AppFontSizes.body,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Chevron ──────────────────────────────────────────────
                AppSpacing.gapHMd,
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
