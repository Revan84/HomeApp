import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';

class DeviceStatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const DeviceStatBox({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: AppFontSizes.xs,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          value,
          style: TextStyle(
            fontSize: AppFontSizes.body,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
