import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../buttons/app_button.dart';

/// Generic modal dialog shell used for every "Add / Edit" dialog in the app.
///
/// Provides the standard title bar, divider, scrollable content area, and a
/// Cancel / Save footer. Pass your form content as [child].
///
/// The [onSave] callback is called when the user taps Save; pass `null` to
/// keep the button rendered but disabled. [onCancel] defaults to
/// `Navigator.pop` when omitted.
///
/// ```dart
/// return AppDialog(
///   title: 'Add Alert',
///   onSave: _save,        // your validation + pop logic
///   child: Column(...),
/// );
/// ```
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.child,
    this.onSave,
    this.onCancel,
    this.saveLabel = 'Save',
    this.cancelLabel = 'Cancel',
  });

  final String title;
  final Widget child;

  /// Called when Save is tapped. `null` = disabled.
  final VoidCallback? onSave;

  /// Called when Cancel is tapped. Defaults to `Navigator.pop`.
  final VoidCallback? onCancel;

  final String saveLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.x2lBR),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x3l,
          AppSpacing.x3l,
          AppSpacing.x3l,
          AppSpacing.x2l,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Title ──────────────────────────────────────────────────────
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppFontSizes.sectionTitle,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpacing.gapX2l,
            const Divider(height: 1, color: AppColors.border),
            AppSpacing.gapX3l,

            // ── Content ────────────────────────────────────────────────────
            child,

            AppSpacing.gapX3l,

            // ── Footer ─────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: cancelLabel,
                  variant: AppButtonVariant.ghost,
                  compact: true,
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                ),
                AppSpacing.gapHMd,
                AppButton(
                  label: saveLabel,
                  variant: AppButtonVariant.secondary,
                  compact: true,
                  onPressed: onSave,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
