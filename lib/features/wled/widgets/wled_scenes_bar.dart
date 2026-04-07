import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final p = presets[i];
          final selected = p.id == selectedId;

          return GestureDetector(
            onTap: () => onSelected(p.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.success
                      : Colors.white.withValues(alpha: 0.1),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                p.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? AppColors.success
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
