import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../integrations/wled/data/wled_api_client.dart';

/// Horizontally scrollable chip bar for selecting a WLED preset/scene.
class WledScenesBar extends StatelessWidget {
  final List<WledPreset> presets;
  final int selectedId;
  final ValueChanged<int> onSelected;

  const WledScenesBar({
    super.key,
    required this.presets,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: presets.length,
        separatorBuilder: (_, _) => AppSpacing.gapHMd,
        itemBuilder: (_, i) {
          final p = presets[i];
          final selected = p.id == selectedId;

          return GestureDetector(
            onTap: () => onSelected(p.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3l,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surface,
                borderRadius: AppRadius.x4lBR,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.border.withValues(alpha: 0.4),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                p.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
