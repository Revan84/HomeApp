import 'package:flutter/material.dart';

import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/device_accent_scope.dart';
import '../domain/tv_remote_command.dart';

/// Card showing the active source with Source and Home action buttons.
class TvSourceCard extends StatelessWidget {
  const TvSourceCard({
    super.key,
    required this.source,
    required this.onCommand,
  });

  final String source;
  final void Function(TvRemoteCommand) onCommand;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const accent = AppColors.tvAccent;

    return AppCard(
      variant: AppCardVariant.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source,
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontWeight: FontWeight.w700,
                    fontSize: AppFontSizes.kpi,
                    color: accent,
                  ),
                ),
                Text(
                  l10n.tvSourceActive,
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontSize: AppFontSizes.body,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TvSourceActionButton(
                icon: Icons.input_rounded,
                label: l10n.tvKeySource,
                onTap: () => onCommand(TvRemoteCommand.source),
              ),
              AppSpacing.gapSm,
              TvSourceActionButton(
                icon: Icons.home_rounded,
                label: l10n.tvKeyHome,
                onTap: () => onCommand(TvRemoteCommand.home),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small outlined button used inside [TvSourceCard].
class TvSourceActionButton extends StatelessWidget {
  const TvSourceActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = DeviceAccentScope.of(context);

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.mdBR,
        side: BorderSide(color: accent.withValues(alpha: 0.5), width: 1),
      ),
      child: InkWell(
        borderRadius: AppRadius.mdBR,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: accent),
              AppSpacing.gapHSm,
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'ShareTech',
                  fontSize: AppFontSizes.body,
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
