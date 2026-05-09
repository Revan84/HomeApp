import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_font_sizes.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// App-styled dropdown form field matching [AppTextField] visually.
///
/// ```dart
/// AppDropdownField<String?>(
///   value: _selectedRoomId,
///   hint: 'None',
///   items: rooms.map((r) => DropdownMenuItem(value: r.id, child: Text(r.name))).toList(),
///   onChanged: (v) => setState(() => _selectedRoomId = v),
/// )
/// ```
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
  });

  final T? value;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final borderSide =
        BorderSide(color: AppColors.border.withValues(alpha: 0.55));
    final border =
        OutlineInputBorder(borderRadius: AppRadius.xlBR, borderSide: borderSide);

    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      dropdownColor: AppColors.surface,
      borderRadius: AppRadius.xlBR,
      style: const TextStyle(
        fontSize: AppFontSizes.body,
        color: AppColors.textPrimary,
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textSecondary,
        size: 20,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: AppFontSizes.body,
          color: AppColors.textSecondary.withValues(alpha: 0.55),
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3l,
          vertical: AppSpacing.xl,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.xlBR,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
