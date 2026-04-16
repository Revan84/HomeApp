import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Centered circular progress indicator with optional message.
///
/// Drop-in replacement for the `Center(child: CircularProgressIndicator())`
/// boilerplate — consistent stroke width and brand color throughout the app.
///
/// ```dart
/// if (_loading) return const AppLoader();
/// AppLoader(message: l10n.loadingDevices)
/// ```
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.message});

  /// Optional text shown below the spinner.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
          if (message != null) ...[
            AppSpacing.gapX3l,
            Text(
              message!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
