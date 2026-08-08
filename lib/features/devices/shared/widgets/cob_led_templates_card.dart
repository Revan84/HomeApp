import 'package:flutter/material.dart';

import '../../../../core/design_system/buttons/app_button.dart';
import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';

/// Generic scene-template card shared by COB LED CCT and RGB.
///
/// Callers supply callbacks that extract the id, display name, colour dot,
/// and formatted parameters from whatever scene type [T] is.
class CobLedTemplatesCard<T> extends StatelessWidget {
  const CobLedTemplatesCard({
    super.key,
    required this.scenes,
    required this.activeSceneId,
    required this.accentColor,
    required this.title,
    required this.emptyLabel,
    required this.deleteTitle,
    required this.deleteBody,
    required this.idOf,
    required this.nameOf,
    required this.colorDotOf,
    required this.paramsOf,
    required this.onAdd,
    required this.onApply,
    required this.onEdit,
    required this.onDelete,
  });

  final List<T> scenes;
  final String activeSceneId;
  final Color accentColor;

  /// Header title (e.g. "Templates" or "TEMPLATES").
  final String title;

  /// Text shown when [scenes] is empty.
  final String emptyLabel;

  /// Title for the delete-confirmation dialog.
  final String deleteTitle;

  /// Body for the delete-confirmation dialog, given the scene name.
  final String Function(String sceneName) deleteBody;

  final String Function(T) idOf;
  final String Function(T) nameOf;

  /// Colour shown as a small dot beside the scene name.
  final Color Function(T) colorDotOf;

  /// Short human-readable summary of the scene's parameters.
  final String Function(BuildContext ctx, T scene) paramsOf;

  final VoidCallback onAdd;
  final void Function(T) onApply;
  final void Function(T) onEdit;
  final void Function(T) onDelete;

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
                title,
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
              emptyLabel,
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
                      color: AppColors.border,
                    ),
                  _SceneRow(
                    isActive: idOf(scene) == activeSceneId,
                    accentColor: accentColor,
                    colorDot: colorDotOf(scene),
                    name: nameOf(scene),
                    params: paramsOf(context, scene),
                    deleteTitle: deleteTitle,
                    deleteBody: deleteBody(nameOf(scene)),
                    onApply: () => onApply(scene),
                    onEdit: () => onEdit(scene),
                    onDelete: () => onDelete(scene),
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
    required this.isActive,
    required this.accentColor,
    required this.colorDot,
    required this.name,
    required this.params,
    required this.deleteTitle,
    required this.deleteBody,
    required this.onApply,
    required this.onEdit,
    required this.onDelete,
  });

  final bool isActive;
  final Color accentColor;
  final Color colorDot;
  final String name;
  final String params;
  final String deleteTitle;
  final String deleteBody;
  final VoidCallback onApply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Colour dot ───────────────────────────────────────────────────
          Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: colorDot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),

          // ── Name + params ────────────────────────────────────────────────
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: name,
                    style: const TextStyle(
                      fontSize: AppFontSizes.md,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (params.isNotEmpty)
                    TextSpan(
                      text: '  $params',
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

          // ── Action button (Active ✎ / Apply) ─────────────────────────────
          GestureDetector(
            onTap: isActive ? onEdit : onApply,
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
                      color:
                          isActive ? accentColor : AppColors.textSecondary,
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
              final ok = await _confirmDelete(context);
              if (ok) onDelete();
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

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(deleteTitle),
        content: Text(deleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    return result == true;
  }
}
