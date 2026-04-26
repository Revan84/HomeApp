import 'package:flutter/material.dart';

import '../../../../core/design_system/buttons/app_outline_add_button.dart';
import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/plug_alert.dart';
import '../../shared/widgets/detail_section_card.dart';
import 'smart_plug_alert_row.dart';

/// Section card listing plug alerts with add / toggle / delete actions.
class SmartPlugAlertsSection extends StatelessWidget {
  const SmartPlugAlertsSection({
    super.key,
    required this.alerts,
    required this.onAdd,
    required this.onToggle,
    required this.onDelete,
  });

  final List<PlugAlert> alerts;
  final VoidCallback onAdd;
  final void Function(String id) onToggle;
  final void Function(String id) onDelete;

  String _conditionLabel(BuildContext context, PlugAlertCondition condition) {
    final l10n = context.l10n;
    return switch (condition) {
      PlugAlertCondition.wattsExceeded => l10n.smartPlugAlertConditionWatts,
      PlugAlertCondition.dailyCostExceeded =>
        l10n.smartPlugAlertConditionDailyCost,
    };
  }

  String _thresholdText(PlugAlert alert) {
    final threshold = alert.threshold.toStringAsFixed(
      alert.condition == PlugAlertCondition.dailyCostExceeded ? 2 : 0,
    );
    return alert.condition == PlugAlertCondition.wattsExceeded
        ? '> $threshold W'
        : '> $threshold €/day';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DetailSectionCard(
      title: l10n.smartPlugSectionAlerts,
      child: Column(
        children: [
          if (alerts.isEmpty)
            Row(
              children: [
                Text(
                  l10n.smartPlugNoAlerts,
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontSize: AppFontSizes.body,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                AppOutlineAddButton(label: l10n.add, onTap: onAdd),
              ],
            )
          else ...[
            ...alerts.map(
              (alert) => SmartPlugAlertRow(
                conditionLabel: _conditionLabel(context, alert.condition),
                thresholdText: _thresholdText(alert),
                isEnabled: alert.isEnabled,
                onToggle: () => onToggle(alert.id),
                onDelete: () => onDelete(alert.id),
              ),
            ),
            AppSpacing.gapMd,
            Align(
              alignment: Alignment.centerRight,
              child: AppOutlineAddButton(label: l10n.add, onTap: onAdd),
            ),
          ],
        ],
      ),
    );
  }
}
