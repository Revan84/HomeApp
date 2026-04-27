import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Standard list tile for a device entry.
///
/// Used in the Equipments tab and Favorites list.
///
/// The secondary line is split into two colour zones:
/// - [subtitle] → [AppColors.textSecondary]  ("Salon · Smart Plug")
/// - [liveValue] → [AppColors.textPrimary]   ("64 W", "Scene Warm")
///
/// ```dart
/// DeviceListTile(
///   icon: Icons.power,
///   iconColor: AppColors.plugAccent,
///   title: 'Desk Plug',
///   subtitle: 'Salon · Smart Plug',
///   liveValue: '64 W',
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
    this.liveValue,
  });

  /// Icon displayed in the leading area.
  final IconData icon;

  /// Colour used for the icon tint.
  final Color iconColor;

  /// Device display name.
  final String title;

  /// Base secondary line shown in [AppColors.textSecondary],
  /// e.g. "Salon · Smart Plug".
  final String subtitle;

  /// Online indicator dot colour.
  final Color dotColor;

  final VoidCallback onTap;

  /// Optional live reading appended after [subtitle] in [AppColors.textPrimary],
  /// e.g. "64 W", "22.5 °C", "Scene Warm". Separated from [subtitle] by " · ".
  final String? liveValue;

  @override
  Widget build(BuildContext context) {
    final bool hasSecondLine = subtitle.isNotEmpty || liveValue != null;

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
              vertical: AppSpacing.lg,
            ),
            child: Row(
              children: [
                // ── Icon ─────────────────────────────────────────────────
                Icon(icon, size: 24, color: AppColors.textPrimary),

                AppSpacing.gapHX2l,

                // ── Text column ──────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + online dot
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

                      // Subtitle + live value
                      if (hasSecondLine) ...[
                        const SizedBox(height: 2),
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              fontFamily: 'ShareTech',
                              fontSize: AppFontSizes.body,
                            ),
                            children: [
                              if (subtitle.isNotEmpty)
                                TextSpan(
                                  text: subtitle,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              if (subtitle.isNotEmpty && liveValue != null)
                                const TextSpan(
                                  text: ' · ',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              if (liveValue != null)
                                TextSpan(
                                  text: liveValue!,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
