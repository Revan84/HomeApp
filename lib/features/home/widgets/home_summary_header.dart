import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';

/// Home summary header shown at the top of the Home tab.
///
/// This widget keeps the design logic isolated from the Home page.
class HomeSummaryHeader extends StatelessWidget {
  final String areaGroupLabel;
  final int onlineCount;
  final int offlineCount;

  const HomeSummaryHeader({
    super.key,
    required this.areaGroupLabel,
    required this.onlineCount,
    required this.offlineCount,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.homeWelcomeTitle,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              context.l10n.netStatusOnline,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Row(
              children: [
                Text(
                  areaGroupLabel,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
            const Spacer(),
            Text(
              context.l10n.homeConnectionSummary(
                onlineCount,
                offlineCount,
              ),
              textAlign: TextAlign.right,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(
          color: AppColors.stroke.withValues(alpha: 0.35),
          height: 1,
        ),
      ],
    );
  }
}