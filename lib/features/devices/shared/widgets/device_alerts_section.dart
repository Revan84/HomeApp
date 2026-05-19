import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/design_system/buttons/app_outline_add_button.dart';
import '../../../../core/design_system/buttons/mini_toggle.dart';
import '../../../../core/design_system/cards/app_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/sensor_alert.dart';

/// Shared alert section used by all sensor detail screens (thermometer,
/// hygrometer, etc.).
///
/// [alertTitleBuilder] returns the human-readable condition title for each
/// alert (e.g. "Too hot if", "Freeze if", "Too wet if").
///
/// [onToggle] is optional — screens whose controller does not yet expose
/// toggleAlert can omit it, which hides the toggle switch.
class DeviceAlertsSection extends StatelessWidget {
  final List<SensorAlert> alerts;
  final String unit;
  final VoidCallback onAdd;
  final void Function(String id) onRemove;
  final void Function(String id)? onToggle;
  final String Function(SensorAlert) alertTitleBuilder;

  const DeviceAlertsSection({
    super.key,
    required this.alerts,
    required this.unit,
    required this.onAdd,
    required this.onRemove,
    required this.alertTitleBuilder,
    this.onToggle,
  });

  String _thresholdLabel(SensorAlert a) {
    final cond = a.condition == SensorAlertCondition.above ? '>' : '<';
    final val = a.threshold.toStringAsFixed(
        a.threshold.truncateToDouble() == a.threshold ? 0 : 1);
    return '$cond $val $unit';
  }

  Color _alertIconColor(SensorAlert a) =>
      a.condition == SensorAlertCondition.above ? Colors.orange : Colors.amber;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.detailSectionAlerts,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppFontSizes.sectionTitle,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              AppOutlineAddButton(label: context.l10n.add, onTap: onAdd),
            ],
          ),

          if (alerts.isEmpty) ...[
            AppSpacing.gapX2l,
            Text(
              context.l10n.alertNoneConfigured,
              style: TextStyle(
                fontSize: AppFontSizes.body,
                color: AppColors.textSecondary,
              ),
            ),
          ] else ...[
            AppSpacing.gapX2l,
            ...alerts.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: _alertIconColor(a),
                    ),
                    AppSpacing.gapHSm,
                    Expanded(
                      child: Text(
                        alertTitleBuilder(a),
                        style: const TextStyle(
                          fontSize: AppFontSizes.body,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _alertIconColor(a).withValues(alpha: 0.15),
                        borderRadius: AppRadius.lgBR,
                        border: Border.all(
                          color: _alertIconColor(a).withValues(alpha: 0.35),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        _thresholdLabel(a),
                        style: TextStyle(
                          fontSize: AppFontSizes.sm,
                          fontWeight: FontWeight.w600,
                          color: _alertIconColor(a),
                        ),
                      ),
                    ),
                    if (onToggle != null) ...[
                      AppSpacing.gapHMd,
                      MiniToggle(
                        isOn: a.isEnabled,
                        loading: false,
                        onTap: () => onToggle!(a.id),
                      ),
                    ],
                    AppSpacing.gapHMd,
                    GestureDetector(
                      onTap: () => onRemove(a.id),
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
