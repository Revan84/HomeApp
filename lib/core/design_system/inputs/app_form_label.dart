import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_font_sizes.dart';

/// Small uppercase-style label placed above a form field.
///
/// ```dart
/// AppFormLabel('Device type'),
/// AppSpacing.gapMd,
/// AppDropdownField(...)
/// ```
class AppFormLabel extends StatelessWidget {
  final String text;
  const AppFormLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: AppFontSizes.sm,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
        ),
      );
}
