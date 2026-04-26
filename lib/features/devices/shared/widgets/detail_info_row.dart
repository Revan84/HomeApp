import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';

// ─── Info row ─────────────────────────────────────────────────────────────────
// Simple read-only label + value row (NOT the clickable InfoRow).

class DetailInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'ShareTech',
            fontSize: AppFontSizes.body,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      Expanded(
        flex: 2,
        child: Text(
          value,
          style: const TextStyle(
            fontFamily: 'ShareTech',
            fontSize: AppFontSizes.body,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    ],
  );
}
