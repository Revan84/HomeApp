import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SecondaryText extends StatelessWidget {
  const SecondaryText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
    );
  }
}
