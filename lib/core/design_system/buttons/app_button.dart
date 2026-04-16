import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Visual style variants for [AppButton].
enum AppButtonVariant {
  /// Filled green — primary CTAs, confirmations, save actions.
  primary,

  /// Bordered surface — secondary/neutral actions.
  secondary,

  /// Filled red — destructive actions (delete, remove).
  danger,

  /// Transparent, no border — inline text actions, dismiss links.
  ghost,
}

/// The app's standard action button.
///
/// [onPressed] = null renders at 45% opacity (disabled) without tap events.
///
/// ```dart
/// AppButton(label: l10n.save, onPressed: _submit)
/// AppButton(label: l10n.delete, variant: AppButtonVariant.danger, onPressed: _delete)
/// AppButton(label: l10n.addRoom, leading: Icons.add, fullWidth: true, onPressed: _add)
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leading,
    this.fullWidth = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  /// Optional icon shown left of the label.
  final IconData? leading;

  /// Stretches button to fill all available horizontal space.
  final bool fullWidth;

  /// Reduces vertical padding — useful inside dense sheets or cards.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    final bg = switch (variant) {
      AppButtonVariant.primary   => AppColors.primary,
      AppButtonVariant.secondary => AppColors.surface,
      AppButtonVariant.danger    => AppColors.danger,
      AppButtonVariant.ghost     => Colors.transparent,
    };

    final fg = switch (variant) {
      AppButtonVariant.primary   => AppColors.bg,
      AppButtonVariant.secondary => AppColors.primary,
      AppButtonVariant.danger    => AppColors.textPrimary,
      AppButtonVariant.ghost     => AppColors.textSecondary,
    };

    final borderColor = variant == AppButtonVariant.secondary
        ? AppColors.primary.withValues(alpha: 0.55)
        : null;

    final vPad = compact ? AppSpacing.sm : AppSpacing.md + 4.0;
    final hPad = compact ? AppSpacing.x3l : AppSpacing.x6l;

    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(color: fg);

    final content = leading != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(leading, size: 18, color: fg),
              AppSpacing.gapHSm,
              Text(label, style: textStyle),
            ],
          )
        : Text(label, style: textStyle);

    final button = AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: disabled ? 0.45 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.buttonBR,
          onTap: disabled ? null : onPressed,
          child: Ink(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.buttonBR,
              border: borderColor != null
                  ? Border.all(color: borderColor)
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              child: Center(child: content),
            ),
          ),
        ),
      ),
    );

    if (fullWidth) return SizedBox(width: double.infinity, child: button);
    return IntrinsicWidth(child: button);
  }
}
