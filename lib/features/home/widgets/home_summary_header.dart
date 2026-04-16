import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Home summary header shown at the top of the Home tab.
///
/// The active room group is displayed under the welcome title and can be tapped
/// to switch the current group context.
class HomeSummaryHeader extends StatelessWidget {
  final Key? areaGroupKey;
  final String areaGroupLabel;
  final int onlineCount;
  final int offlineCount;
  final VoidCallback? onTapAreaGroup;

  const HomeSummaryHeader({
    super.key,
    this.areaGroupKey,
    required this.areaGroupLabel,
    required this.onlineCount,
    required this.offlineCount,
    this.onTapAreaGroup,
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
            AppSpacing.gapHMd,
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        AppSpacing.gapSm,
        Row(
          children: [
            Material(
              key: areaGroupKey,
              color: Colors.transparent,
              child: InkWell(
                onTap: onTapAreaGroup,
                borderRadius: AppRadius.pillBR,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    children: [
                      Text(
                        areaGroupLabel,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AppSpacing.gapHXs,
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
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
        AppSpacing.gapXl,
        Divider(
          color: AppColors.border.withValues(alpha: 0.35),
          height: 1,
        ),
      ],
    );
  }
}