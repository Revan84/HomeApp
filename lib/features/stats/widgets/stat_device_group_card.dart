import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';

/// Collapsible card that groups all stat widgets belonging to one device.
class StatDeviceGroupCard extends StatelessWidget {
  final String deviceName;
  final String deviceTypeLabel;
  final int widgetCount;
  final bool initiallyExpanded;
  final List<Widget> children;

  const StatDeviceGroupCard({
    super.key,
    required this.deviceName,
    required this.deviceTypeLabel,
    required this.widgetCount,
    required this.initiallyExpanded,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          collapsedBackgroundColor: AppColors.surface,
          backgroundColor: AppColors.surface,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 16),
          iconColor: AppColors.textSecondary,
          collapsedIconColor: AppColors.textSecondary,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deviceName,
                style: const TextStyle(
                  fontFamily: 'ShareTech',
                  fontSize: AppFontSizes.md,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (deviceTypeLabel.isNotEmpty)
                Text(
                  '$deviceTypeLabel · ${context.l10n.statsWidgetCount(widgetCount)}',
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontSize: AppFontSizes.sm,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.25),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}
