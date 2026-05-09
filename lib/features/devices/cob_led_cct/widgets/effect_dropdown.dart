import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';

/// Dropdown for selecting a WLED effect by index.
class CobLedCctEffectDropdown extends StatelessWidget {
  const CobLedCctEffectDropdown({
    super.key,
    required this.selectedIndex,
    required this.effectNames,
    required this.accentColor,
    required this.onChanged,
  });

  final int selectedIndex;
  final List<String> effectNames;
  final Color accentColor;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    if (effectNames.isEmpty) {
      return const Text(
        'Loading effects…',
        style: TextStyle(
          fontSize: AppFontSizes.body,
          color: AppColors.textSecondary,
        ),
      );
    }

    final safeIndex = selectedIndex.clamp(0, effectNames.length - 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBR,
        border: Border.all(color: AppColors.border, width: 0.7),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: safeIndex,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          iconEnabledColor: AppColors.textSecondary,
          style: const TextStyle(
            fontSize: AppFontSizes.body,
            color: AppColors.textPrimary,
          ),
          items: [
            for (int i = 0; i < effectNames.length; i++)
              DropdownMenuItem(value: i, child: Text(effectNames[i])),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
