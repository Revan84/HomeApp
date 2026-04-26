import 'package:flutter/material.dart';

import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/cct_scene.dart';

/// Card showing the currently active scene and a horizontal scene chip list.
class CobLedCctActiveSceneCard extends StatelessWidget {
  const CobLedCctActiveSceneCard({
    super.key,
    required this.activeSceneId,
    required this.scenes,
    required this.accentColor,
    required this.onApply,
  });

  final String activeSceneId;
  final List<CctScene> scenes;
  final Color accentColor;
  final void Function(CctScene) onApply;

  @override
  Widget build(BuildContext context) {
    final activeScene = activeSceneId.isNotEmpty
        ? scenes.where((s) => s.id == activeSceneId).firstOrNull
        : null;

    return AppCard(
      variant: AppCardVariant.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: activeScene != null
                      ? accentColor
                      : AppColors.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              AppSpacing.gapHSm,
              const Text(
                'ACTIVE SCENE',
                style: TextStyle(
                  fontFamily: 'ShareTech',
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSizes.sectionTitle,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          if (activeScene != null) ...[
            Text(
              activeScene.name,
              style: const TextStyle(
                fontFamily: 'ShareTech',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${activeScene.colorTempK} K · '
              '${(activeScene.brightness / 255.0 * 100).round()} %',
              style: const TextStyle(
                fontFamily: 'ShareTech',
                fontSize: AppFontSizes.body,
                color: AppColors.textSecondary,
              ),
            ),
          ] else
            const Text(
              'No active template',
              style: TextStyle(
                fontFamily: 'ShareTech',
                fontSize: AppFontSizes.body,
                color: AppColors.textSecondary,
              ),
            ),
          if (scenes.isNotEmpty) ...[
            AppSpacing.gapX2l,
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: scenes.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final scene = scenes[i];
                  final isActive = scene.id == activeSceneId;
                  return GestureDetector(
                    onTap: () => onApply(scene),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
                        scene.name,
                        style: TextStyle(
                          fontFamily: 'ShareTech',
                          fontSize: 12,
                          color: isActive
                              ? accentColor
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
