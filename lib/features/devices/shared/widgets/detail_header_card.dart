import 'package:flutter/material.dart';

import '../../../../core/design_system/buttons/mini_toggle.dart';
import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/time_label.dart';

// ─── Header card ─────────────────────────────────────────────────────────────
//
// Two side-by-side cards:
//  • Main card  — device icon · type label · timestamp · online dot · toggle
//  • Fav card   — heart icon (small square card)
//
// [typeLabel] and [icon] are passed by the parent screen so this widget is
// reusable across equipment types (Smart Plug → bolt, TV → tv, …).

class DetailHeaderCard extends StatelessWidget {
  /// Whether this device is currently marked as a favourite.
  final bool isFavorite;

  /// Generic device-type label shown inside the card, e.g. "Smart Plug", "Remote Control".
  final String typeLabel;

  /// Icon that represents the device type.
  final IconData icon;

  /// Accent colour for the device icon circle (border + icon).
  /// Defaults to [AppColors.primary]. Pass a device-specific colour
  /// (e.g. [AppColors.plugAccent]) to distinguish device types visually.
  final Color accentColor;

  final bool isOnline;
  final bool isOn;
  final bool toggling;
  final DateTime? lastUpdatedAt;
  final VoidCallback onToggle;
  final VoidCallback onFavorite;

  const DetailHeaderCard({
    super.key,
    required this.isFavorite,
    required this.typeLabel,
    required this.icon,
    this.accentColor = AppColors.primary,
    required this.isOnline,
    required this.isOn,
    required this.toggling,
    required this.onToggle,
    required this.onFavorite,
    this.lastUpdatedAt,
  });

  @override
  Widget build(BuildContext context) {
    final updatedLabel = ageLabel(context, lastUpdatedAt);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Main card ────────────────────────────────────────────────────
        Expanded(
          child: AppCard(
            variant: AppCardVariant.card,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Device icon circle
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 1.5, color: accentColor),
                  ),
                  child: Icon(icon, color: accentColor),
                ),
                AppSpacing.gapHX2l,
                // Type label + timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        typeLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: AppFontSizes.sectionTitle,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (updatedLabel.isNotEmpty) ...[
                        AppSpacing.gapXxs,
                        Text(
                          updatedLabel,
                          style: const TextStyle(
                            fontSize: AppFontSizes.sm,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AppSpacing.gapHMd,
                // Online indicator (top) + toggle (bottom)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isOnline ? context.l10n.netStatusOnline : context.l10n.netStatusOffline,
                          style: TextStyle(
                            fontSize: AppFontSizes.sm,
                            color: isOnline ? accentColor : AppColors.textSecondary,
                          ),
                        ),
                        AppSpacing.gapHSm,
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isOnline ? accentColor : AppColors.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gapMd,
                    MiniToggle(
                      isOn: isOn,
                      loading: toggling,
                      onTap: isOnline ? onToggle : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        AppSpacing.gapHMd,
        // ── Favourite card ───────────────────────────────────────────────
        AppCard(
          variant: AppCardVariant.card,
          onTap: onFavorite,
          padding: const EdgeInsets.all(AppSpacing.x2l),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isFavorite ? accentColor : AppColors.textSecondary,
            size: 22,
          ),
        ),
      ],
    );
  }
}
