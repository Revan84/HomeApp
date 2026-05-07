import 'package:flutter/material.dart';

import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/design_system/chips/app_chip.dart';
import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/cct_scene.dart';

/// Card showing the currently active scene name and a horizontal scene chip list.
///
/// Layout matches the screen mockup:
///   [accent dot]  Cozy          ← large scene name
///                 Scene active  ← secondary label
///   [Cozy] [Night]              ← tappable scene chips
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
          // ── Scene name + label ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: activeScene?.name ?? context.l10n.cobLedCctNoActiveTemplate,
                    style: TextStyle(
                      fontFamily: 'ShareTech',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: accentColor,
                    ),
                  ),
                  if (activeScene != null)
                  
                    TextSpan(
                      text: '  ${context.l10n.cobLedCctSceneActive}',
                      style: TextStyle(
                        fontFamily: 'ShareTech',
                        fontSize: AppFontSizes.md,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ── Scene chips ──────────────────────────────────────────────────
          if (scenes.isNotEmpty) ...[
            AppSpacing.gapX2l,
            const Divider(height: 1, color: AppColors.border, thickness: 0.5),
            AppSpacing.gapX2l,
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: scenes.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final scene = scenes[i];
                  return AppChip(
                    label: scene.name,
                    selected: scene.id == activeSceneId,
                    variant: AppChipVariant.outlined,
                    accentColor: accentColor,
                    onTap: () => onApply(scene),
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
