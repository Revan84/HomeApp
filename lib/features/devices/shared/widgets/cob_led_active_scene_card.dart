import 'package:flutter/material.dart';

import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/design_system/chips/app_chip.dart';
import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';

/// Generic active-scene card used by both COB LED CCT and RGB detail screens.
///
/// Shows the currently active scene name at the top, then a horizontal chip
/// list so the user can switch scenes with one tap.
class CobLedActiveSceneCard<T> extends StatelessWidget {
  const CobLedActiveSceneCard({
    super.key,
    required this.activeSceneId,
    required this.scenes,
    required this.accentColor,
    required this.idOf,
    required this.nameOf,
    required this.onApply,
    this.noActiveLabel,
    this.activeLabel,
  });

  final String activeSceneId;
  final List<T> scenes;
  final Color accentColor;

  /// Extracts the unique id from a scene object.
  final String Function(T) idOf;

  /// Extracts the display name from a scene object.
  final String Function(T) nameOf;

  final void Function(T) onApply;

  /// Override for "No active template" text. Defaults to [cobLedCctNoActiveTemplate].
  final String? noActiveLabel;

  /// Override for "Scene active" suffix. Defaults to [cobLedCctSceneActive].
  final String? activeLabel;

  @override
  Widget build(BuildContext context) {
    final activeScene = activeSceneId.isNotEmpty
        ? scenes.where((s) => idOf(s) == activeSceneId).firstOrNull
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
                    text: activeScene != null
                        ? nameOf(activeScene)
                        : (noActiveLabel ?? context.l10n.cobLedCctNoActiveTemplate),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: accentColor,
                    ),
                  ),
                  if (activeScene != null)
                    TextSpan(
                      text:
                          '  ${activeLabel ?? context.l10n.cobLedCctSceneActive}',
                      style: const TextStyle(
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
                    label: nameOf(scene),
                    selected: idOf(scene) == activeSceneId,
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
