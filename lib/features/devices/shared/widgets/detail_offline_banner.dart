import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

// ─── Offline banner ──────────────────────────────────────────────────────────

class DetailOfflineBanner extends StatelessWidget {
  final String label;

  const DetailOfflineBanner({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: AppColors.danger.withValues(alpha: 0.12),
      borderRadius: AppRadius.lgBR,
    ),
    child: Row(
      children: [
        const Icon(Icons.signal_wifi_off_outlined, size: 14, color: AppColors.danger),
        AppSpacing.gapHSm,
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'ShareTech',
            fontSize: AppFontSizes.sm,
            color: AppColors.danger,
          ),
        ),
      ],
    ),
  );
}
