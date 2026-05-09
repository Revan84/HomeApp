import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/device_accent_scope.dart';

/// Single alert row: icon · labels · delete button · enable switch.
class SmartPlugAlertRow extends StatelessWidget {
  const SmartPlugAlertRow({
    super.key,
    required this.conditionLabel,
    required this.thresholdText,
    required this.isEnabled,
    required this.onToggle,
    required this.onDelete,
  });

  final String conditionLabel;
  final String thresholdText;
  final bool isEnabled;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final accent = DeviceAccentScope.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: AppRadius.mdBR,
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              size: 16,
              color: isEnabled ? accent : AppColors.textSecondary,
            ),
          ),
          AppSpacing.gapHX3l,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conditionLabel,
                  style: TextStyle(
                    fontSize: AppFontSizes.body,
                    color: isEnabled
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  thresholdText,
                  style: TextStyle(
                    fontSize: AppFontSizes.body,
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? accent : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          AppSpacing.gapHXs,
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: isEnabled,
              onChanged: (_) => onToggle(),
              activeThumbColor: accent,
              activeTrackColor: accent.withValues(alpha: 0.25),
              inactiveThumbColor: AppColors.textSecondary,
              inactiveTrackColor: AppColors.border,
            ),
          ),
        ],
      ),
    );
  }
}
