import 'package:flutter/material.dart';

import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../integrations/cob_led_rgb/data/cob_led_rgb_api_client.dart';

class CobLedRgbPresetsSection extends StatelessWidget {
  const CobLedRgbPresetsSection({
    super.key,
    required this.presets,
    required this.activePresetId,
    required this.accentColor,
    required this.onApply,
  });

  final List<CobLedRgbPreset> presets;
  final int activePresetId;
  final Color accentColor;
  final void Function(CobLedRgbPreset) onApply;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.cobLedSectionTemplates,
            style: const TextStyle(
              fontFamily: 'ShareTech',
              fontWeight: FontWeight.w600,
              fontSize: AppFontSizes.sectionTitle,
              color: AppColors.textPrimary,
            ),
          ),

          if (presets.isEmpty) ...[
            AppSpacing.gapX2l,
            Text(
              context.l10n.cobLedNoPresets,
              style: const TextStyle(
                  fontFamily: 'ShareTech',
                  fontSize: AppFontSizes.body,
                  color: AppColors.textSecondary),
            ),
          ] else ...[
            AppSpacing.gapX2l,
            ...presets.map((preset) {
              final isActive = preset.id == activePresetId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isActive
                            ? accentColor
                            : AppColors.textSecondary.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.gapHSm,
                    Expanded(
                      child: Text(
                        preset.name,
                        style: const TextStyle(
                          fontFamily: 'ShareTech',
                          fontSize: AppFontSizes.body,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: isActive ? null : () => onApply(preset),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
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
                          isActive ? context.l10n.cobLedPresetActive : context.l10n.cobLedPresetApply,
                          style: TextStyle(
                            fontFamily: 'ShareTech',
                            fontSize: 11,
                            color: isActive
                                ? accentColor
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
