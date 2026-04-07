import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Scrollable list for selecting a WLED effect by index.
class WledEffectsList extends StatelessWidget {
  final List<String> effects;
  final int selectedId;
  final ValueChanged<int> onSelected;

  const WledEffectsList({
    super.key,
    required this.effects,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          itemCount: effects.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
          itemBuilder: (_, i) {
            final selected = i == selectedId;
            return InkWell(
              onTap: () => onSelected(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? AppColors.success
                            : Colors.transparent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        effects[i],
                        style: TextStyle(
                          fontSize: 13,
                          color: selected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (selected)
                      const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppColors.success,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
