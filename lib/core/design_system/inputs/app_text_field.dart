import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// App-styled text input that fits the dark UI.
///
/// Provide either [controller] or [initialValue], never both.
///
/// ```dart
/// AppTextField(controller: _nameCtrl, label: l10n.namePlaceholder)
/// AppTextField(initialValue: _channel.toString(), keyboardType: TextInputType.number, onChanged: _onChannelChanged)
/// AppTextField(controller: _ipCtrl, label: '192.168.x.x', validator: _validateIp)
/// ```
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
    this.prefixIcon,
    this.suffix,
  }) : assert(
          controller == null || initialValue == null,
          'Provide either controller or initialValue, not both.',
        );

  final TextEditingController? controller;

  /// Used when no persistent controller is needed (e.g. inline form fields).
  final String? initialValue;

  final String? label;
  final String? hint;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final bool enabled;

  /// Leading icon inside the field.
  final IconData? prefixIcon;

  /// Trailing widget inside the field (e.g. clear button).
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final borderSide = BorderSide(
      color: AppColors.border.withValues(alpha: 0.55),
    );
    final border = OutlineInputBorder(
      borderRadius: AppRadius.xlBR,
      borderSide: borderSide,
    );
    const focusedBorder = OutlineInputBorder(
      borderRadius: AppRadius.xlBR,
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    );
    const errorBorder = OutlineInputBorder(
      borderRadius: AppRadius.xlBR,
      borderSide: BorderSide(color: AppColors.danger),
    );

    final labelStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: AppColors.textSecondary);

    final hintStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.55));

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3l,
          vertical: AppSpacing.xl,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        labelStyle: labelStyle,
        hintStyle: hintStyle,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
            : null,
        suffix: suffix,
      ),
    );
  }
}
