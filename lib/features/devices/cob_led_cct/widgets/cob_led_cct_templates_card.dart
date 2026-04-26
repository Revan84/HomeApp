import 'package:flutter/material.dart';

import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/cct_scene.dart';
import 'cct_helpers.dart';

/// Card listing saved scene templates with apply/delete actions.
class CobLedCctTemplatesCard extends StatelessWidget {
  const CobLedCctTemplatesCard({
    super.key,
    required this.scenes,
    required this.activeSceneId,
    required this.accentColor,
    required this.onAdd,
    required this.onApply,
    required this.onDelete,
  });

  final List<CctScene> scenes;
  final String activeSceneId;
  final Color accentColor;
  final VoidCallback onAdd;
  final void Function(CctScene) onApply;
  final void Function(CctScene) onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'TEMPLATES',
                style: TextStyle(
                  fontFamily: 'ShareTech',
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSizes.sectionTitle,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.lgBR,
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: accentColor),
                      const SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          fontFamily: 'ShareTech',
                          fontSize: 12,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (scenes.isEmpty) ...[
            AppSpacing.gapX2l,
            const Text(
              'No templates yet. Save a scene to reuse it later.',
              style: TextStyle(
                fontFamily: 'ShareTech',
                fontSize: AppFontSizes.body,
                color: AppColors.textSecondary,
              ),
            ),
          ] else ...[
            AppSpacing.gapX2l,
            ...scenes.map((scene) => _SceneRow(
                  scene: scene,
                  isActive: scene.id == activeSceneId,
                  accentColor: accentColor,
                  onApply: onApply,
                  onDelete: onDelete,
                )),
          ],
        ],
      ),
    );
  }
}

class _SceneRow extends StatelessWidget {
  const _SceneRow({
    required this.scene,
    required this.isActive,
    required this.accentColor,
    required this.onApply,
    required this.onDelete,
  });

  final CctScene scene;
  final bool isActive;
  final Color accentColor;
  final void Function(CctScene) onApply;
  final void Function(CctScene) onDelete;

  @override
  Widget build(BuildContext context) {
    final dot = cctTempToColor(scene.colorTempK);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          AppSpacing.gapHSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scene.name,
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontSize: AppFontSizes.body,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${scene.colorTempK} K · '
                  '${(scene.brightness / 255.0 * 100).round()} %',
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontSize: AppFontSizes.xs,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isActive ? null : () => onApply(scene),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? accentColor.withValues(alpha: 0.15)
                    : AppColors.surface,
                borderRadius: AppRadius.lgBR,
                border: Border.all(
                  color: isActive ? accentColor : AppColors.border,
                  width: isActive ? 1.2 : 0.5,
                ),
              ),
              child: Text(
                isActive ? 'Active' : 'Apply',
                style: TextStyle(
                  fontFamily: 'ShareTech',
                  fontSize: 11,
                  color:
                      isActive ? accentColor : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onDelete(scene),
            child: const Icon(Icons.close,
                size: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
