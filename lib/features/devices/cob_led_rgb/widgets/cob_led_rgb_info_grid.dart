import 'package:flutter/material.dart';

import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/cob_led_rgb_device.dart';

/// Info grid displayed at the bottom of the WLED detail page.
class CobLedRgbInfoGrid extends StatelessWidget {
  final CobLedRgbDevice device;
  final bool isOnline;

  const CobLedRgbInfoGrid({
    super.key,
    required this.device,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          _InfoRow(label: 'IP', value: device.ipAddress),
          if (device.modelName.isNotEmpty) ...[
            Divider(height: AppSpacing.x5l, color: AppColors.border.withValues(alpha: 0.35)),
            _InfoRow(
              label: context.l10n.deviceInfoModelLabel,
              value: device.modelName,
            ),
          ],
          Divider(height: AppSpacing.x5l, color: AppColors.border.withValues(alpha: 0.35)),
          _InfoRow(
            label: context.l10n.detailInfoStatus,
            value: isOnline ? context.l10n.netStatusOnline : context.l10n.netStatusOffline,
            valueColor: isOnline ? AppColors.success : AppColors.danger,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}
