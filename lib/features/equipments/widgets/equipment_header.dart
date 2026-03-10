import 'package:flutter/material.dart';

import '../../../core/i18n/loc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/trend_chip.dart';

/// Header block:
/// - Bolt icon
/// - Power + trend + "updated"
/// - Refresh icon on the far right (as prototype)
/// - Name + edit icon aligned next to the name (not far right)
class EquipmentHeader extends StatelessWidget {
  final double? powerW;
  final int trend;
  final String updatedLabel;

  final String name;
  final VoidCallback onEditName;
  final VoidCallback onRefresh;

  const EquipmentHeader({
    super.key,
    required this.powerW,
    required this.trend,
    required this.updatedLabel,
    required this.name,
    required this.onEditName,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final powerText = powerW == null
        ? context.l10n.valueUnknown
        : context.l10n.powerWatts(powerW!.toStringAsFixed(0));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Power row + trend + refresh (far right)
              Row(
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 22,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    powerText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TrendChip(trend: trend, label: updatedLabel),
                  const Spacer(),
                  IconButton(
                    tooltip: context.l10n.refresh,
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Name row with edit icon aligned next to name
              Row(
                children: [
                  SizedBox(width: 6),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 18
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ActionIcon(
                    icon: Icons.edit_rounded,
                    tooltip: context.l10n.detailsEditNameTooltip,
                    onPressed: onEditName,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small icon button with consistent hitbox (reusable).
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 18,
        child: const Padding(
          padding: EdgeInsets.all(4),
          child: Icon(Icons.edit, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
