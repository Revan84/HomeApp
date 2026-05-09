import 'package:flutter/material.dart';

import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';

// ─── Section card ─────────────────────────────────────────────────────────────

class DetailSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const DetailSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppFontSizes.sectionTitle,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
          child,
        ],
      ),
    );
  }
}
