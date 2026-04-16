import 'package:flutter/material.dart';

import '../i18n/loc.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Small inline indicator showing trend direction + last update age.
class TrendChip extends StatelessWidget {
  final int trend;
  final String label;

  const TrendChip({super.key, required this.trend, required this.label});

  @override
  Widget build(BuildContext context) {
    final icon = trend > 0
        ? Icons.arrow_upward_rounded
        : trend < 0
            ? Icons.arrow_downward_rounded
            : Icons.remove_rounded;

    final color = trend > 0
        ? AppColors.success
        : trend < 0
            ? Colors.orange
            : AppColors.textSecondary.withValues(alpha: 0.7);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        AppSpacing.gapHSm,
        Text(
          label.isEmpty ? context.l10n.valueUnknown : label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
