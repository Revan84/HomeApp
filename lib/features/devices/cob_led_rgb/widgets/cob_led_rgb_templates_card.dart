import 'package:flutter/material.dart';

import '../../../../core/design_system/buttons/app_button.dart';
import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/rgb_scene.dart';

/// Card listing saved RGB scene templates with apply / edit / delete actions.
class CobLedRgbTemplatesCard extends StatelessWidget {
  const CobLedRgbTemplatesCard({
    super.key,
    required this.scenes,
    required this.activeSceneId,
    required this.accentColor,
    required this.onAdd,
    required this.onApply,
    required this.onEdit,
    required this.onDelete,
  });

  final List<RgbScene> scenes;
  final String activeSceneId;
  final Color accentColor;
  final VoidCallback onAdd;
  final void Function(RgbScene) onApply;
  final void Function(RgbScene) onEdit;
  final void Function(RgbScene) onDelete;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            children: [
              Text(
                context.l10n.cobLedSectionTemplates,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: AppFontSizes.heading,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              AppButton(
                label: '+ ${context.l10n.add}',
                variant: AppButtonVariant.secondary,
                compact: true,
                onPressed: onAdd,
              ),
            ],
          ),

          if (scenes.isEmpty) ...[
            AppSpacing.gapX2l,
            Text(
              context.l10n.cobLedRgbNoScenes,
              style: const TextStyle(
                fontSize: AppFontSizes.body,
                color: AppColors.textSecondary,
              ),
            ),
          ] else ...[
            AppSpacing.gapMd,
            ...scenes.asMap().entries.map((entry) {
              final i = entry.key;
              final scene = entry.value;
              return Column(
                children: [
                  if (i > 0)
                    const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppColors.border),
                  _SceneRow(
                    scene: scene,
                    isActive: scene.id == activeSceneId,
                    accentColor: accentColor,
                    onApply: onApply,
                    onEdit: onEdit,
                    onDelete: onDelete,
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ── Scene row ─────────────────────────────────────────────────────────────────

class _SceneRow extends StatelessWidget {
  const _SceneRow({
    required this.scene,
    required this.isActive,
    required this.accentColor,
    required this.onApply,
    required this.onEdit,
    required this.onDelete,
  });

  final RgbScene scene;
  final bool isActive;
  final Color accentColor;
  final void Function(RgbScene) onApply;
  final void Function(RgbScene) onEdit;
  final void Function(RgbScene) onDelete;

  String _params() {
    final parts = <String>[
      '${(scene.brightness / 255.0 * 100).round()} %',
      if (scene.effectId != 0) 'FX ${scene.effectId}',
      if (scene.effectId != 0)
        '${(scene.effectSpeed / 255.0 * 100).round()} spd',
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final dot =
        Color.fromARGB(255, scene.colorRed, scene.colorGreen, scene.colorBlue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Colour dot ───────────────────────────────────────────────────
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),

          // ── Name + inline params ─────────────────────────────────────────
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: scene.name,
                    style: const TextStyle(
                      fontSize: AppFontSizes.md,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: '  ${_params()}',
                    style: const TextStyle(
                      fontSize: AppFontSizes.sm,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),

          // ── Action button ────────────────────────────────────────────────
          GestureDetector(
            onTap: isActive ? () => onEdit(scene) : () => onApply(scene),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isActive
                    ? accentColor.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: AppRadius.lgBR,
                border: Border.all(
                  color: isActive ? accentColor : AppColors.border,
                  width: isActive ? 1.2 : 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isActive) ...[
                    Icon(Icons.edit_outlined, size: 11, color: accentColor),
                    const SizedBox(width: 3),
                  ],
                  Text(
                    isActive
                        ? context.l10n.cobLedCctTemplateActiveBadge
                        : context.l10n.cobLedPresetApply,
                    style: TextStyle(
                      fontSize: AppFontSizes.sm,
                      color: isActive
                          ? accentColor
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ── Delete ────────────────────────────────────────────────────────
          GestureDetector(
            onTap: () async {
              final ok = await _confirmDelete(context, scene.name);
              if (ok) onDelete(scene);
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 2),
              child: Icon(Icons.close, size: 16, color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> _confirmDelete(BuildContext context, String name) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(l10n.cobLedRgbDeleteSceneTitle),
      content: Text(l10n.cobLedRgbDeleteSceneBody(name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  return result == true;
}
