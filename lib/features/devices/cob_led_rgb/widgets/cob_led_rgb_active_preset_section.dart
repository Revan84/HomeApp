import 'package:flutter/material.dart';

import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../integrations/cob_led_rgb/data/cob_led_rgb_api_client.dart';

class CobLedRgbActivePresetSection extends StatelessWidget {
  const CobLedRgbActivePresetSection({
    super.key,
    required this.activePresetId,
    required this.presets,
    required this.accentColor,
    required this.onApply,
  });

  final int activePresetId;
  final List<CobLedRgbPreset> presets;
  final Color accentColor;
  final void Function(CobLedRgbPreset) onApply;

  @override
  Widget build(BuildContext context) {
    final activePreset = activePresetId >= 0
        ? presets.where((p) => p.id == activePresetId).firstOrNull
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
                  color: activePreset != null
                      ? accentColor
                      : AppColors.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              AppSpacing.gapHSm,
              Text(
                context.l10n.cobLedSectionActiveScene,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSizes.sectionTitle,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          if (activePreset != null) ...[
            Text(
              activePreset.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ] else
            Text(
              context.l10n.cobLedNoActiveScene,
              style: const TextStyle(
                fontSize: AppFontSizes.body,
                color: AppColors.textSecondary,
              ),
            ),
          if (presets.isNotEmpty) ...[
            AppSpacing.gapX2l,
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: presets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final preset = presets[i];
                  final isActive = preset.id == activePresetId;
                  return GestureDetector(
                    onTap: () => onApply(preset),
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
                        preset.name,
                        style: TextStyle(
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
