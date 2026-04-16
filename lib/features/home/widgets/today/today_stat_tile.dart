import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';

/// Compact stat tile for the "Today" horizontal scroll.
///
/// Layout matches the screenshot:  [icon  value (sub)] on top row,
/// [label] below — all inside a small rounded card.
class TodayStatTile extends StatelessWidget {
  const TodayStatTile({
    super.key,
    required this.icon,
    required this.value,
    this.subValue,
    required this.label,
    this.accentColor,
  });

  final IconData icon;
  final String value;

  /// Optional parenthesised secondary value (e.g. "13.4€").
  final String? subValue;

  final String label;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.subtle,
        borderRadius: AppRadius.smBR,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row: icon + value + (sub)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                String.fromCharCode(icon.codePoint),
                style: TextStyle(
                  inherit: false,
                  fontFamily: icon.fontFamily,
                  package: icon.fontPackage,
                  fontSize: AppFontSizes.heading,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1.2
                    ..color = accent,
                ),
              ),
              AppSpacing.gapHSm,
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'ShareTech',
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: AppFontSizes.body,
                ),
              ),
              if (subValue != null) ...[
                AppSpacing.gapHXs,
                Text(
                  '($subValue)',
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    color: AppColors.textSecondary,
                    fontSize: AppFontSizes.sm,
                  ),
                ),
              ],
            ],
          ),
          AppSpacing.gapXs,
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'ShareTech',
              color: AppColors.textSecondary,
              fontSize: AppFontSizes.sm,
            ),
          ),
        ],
      ),
    );
  }
}
