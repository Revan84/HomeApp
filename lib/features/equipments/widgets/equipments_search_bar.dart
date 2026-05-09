import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Search field + filter-toggle button row for the Equipments tab.
///
/// ```dart
/// EquipmentsSearchBar(
///   controller: _searchCtrl,
///   isFiltered: _selectedKind != _DeviceKind.all,
///   onFilterTap: _showTypeMenu,
/// )
/// ```
class EquipmentsSearchBar extends StatelessWidget {
  const EquipmentsSearchBar({
    super.key,
    required this.controller,
    required this.isFiltered,
    required this.onFilterTap,
    this.hintText,
  });

  final TextEditingController controller;

  /// Whether any type filter (other than "All") is active.
  /// Drives the border/icon colour of the filter button.
  final bool isFiltered;

  final VoidCallback onFilterTap;

  /// Override the default hint text. Falls back to [AppLocalizations.equipmentsSearchHint].
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3l),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                fontSize: AppFontSizes.body,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hintText ?? context.l10n.equipmentsSearchHint,
                hintStyle: TextStyle(
                  fontSize: AppFontSizes.body,
                  color: AppColors.textSecondary.withValues(alpha: 0.55),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.bg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x2l,
                  vertical: AppSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.x4lBR,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.x4lBR,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: AppRadius.x4lBR,
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          AppSpacing.gapHMd,
          GestureDetector(
            onTap: onFilterTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: AppRadius.x4lBR,
                border: Border.all(
                  color: isFiltered
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 20,
                color:
                    isFiltered ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
