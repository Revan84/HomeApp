import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/wled_device.dart';

/// Info grid displayed at the bottom of the WLED detail page.
class WledInfoGrid extends StatelessWidget {
  final WledDevice device;
  final bool isOnline;

  const WledInfoGrid({
    super.key,
    required this.device,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'IP', value: device.ipAddress),
          if (device.modelName.isNotEmpty) ...[
            const Divider(height: 20, color: Colors.white12),
            _InfoRow(
              label: context.l10n.tvModelLabel,
              value: device.modelName,
            ),
          ],
          const Divider(height: 20, color: Colors.white12),
          _InfoRow(
            label: 'Status',
            value: isOnline ? 'Online' : 'Offline',
            valueColor:
                isOnline ? AppColors.success : AppColors.danger,
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
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
