import 'package:flutter/material.dart';

import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Scrollable list for selecting a WLED effect by index.
class CobLedRgbEffectsList extends StatelessWidget {
  final List<String> effects;
  final int selectedId;
  final ValueChanged<int> onSelected;

  const CobLedRgbEffectsList({
    super.key,
    required this.effects,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: AppRadius.x3lBR,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          itemCount: effects.length,
          separatorBuilder: (_, _) => Divider(
            height: 1,
            color: AppColors.border.withValues(alpha: 0.25),
          ),
          itemBuilder: (_, i) {
            final selected = i == selectedId;
            return InkWell(
              onTap: () => onSelected(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x3l,
                  vertical: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? AppColors.primary
                            : Colors.transparent,
                      ),
                    ),
                    AppSpacing.gapHXl,
                    Expanded(
                      child: Text(
                        effects[i],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                        color: AppColors.primary,
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
