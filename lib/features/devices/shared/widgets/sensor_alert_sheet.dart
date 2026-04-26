import 'package:flutter/material.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/design_system/dialogs/app_dialog.dart';
import '../../../../core/design_system/dialogs/app_dialog_chip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/sensor_alert.dart';

/// Dialog for creating a [SensorAlert].
///
/// Pass [isHumidity] = true for hygrometers (unit = %, label = "Humidity"),
/// false for thermometers (unit = °C, label = "Temperature").
///
/// Usage:
/// ```dart
/// final alert = await SensorAlertSheet.show(context,
///     equipmentId: e.id, isHumidity: false);
/// if (alert != null) ctrl.addAlert(alert);
/// ```
class SensorAlertSheet extends StatefulWidget {
  final String equipmentId;
  final bool isHumidity;

  const SensorAlertSheet._({
    required this.equipmentId,
    required this.isHumidity,
  });

  static Future<SensorAlert?> show(
    BuildContext context, {
    required String equipmentId,
    required bool isHumidity,
  }) {
    return showDialog<SensorAlert>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => SensorAlertSheet._(
        equipmentId: equipmentId,
        isHumidity: isHumidity,
      ),
    );
  }

  @override
  State<SensorAlertSheet> createState() => _SensorAlertSheetState();
}

class _SensorAlertSheetState extends State<SensorAlertSheet> {
  SensorAlertCondition _condition = SensorAlertCondition.above;
  final _thresholdCtrl = TextEditingController();
  final Set<SensorAlertNotification> _notifications = {
    SensorAlertNotification.banner,
  };
  String? _error;

  @override
  void dispose() {
    _thresholdCtrl.dispose();
    super.dispose();
  }

  String get _unit => widget.isHumidity ? '%' : '°C';
  String get _metricLabel =>
      widget.isHumidity ? 'Humidity (%)' : 'Temperature (°C)';
  Color get _accentColor => widget.isHumidity
      ? AppColors.hygrometerAccent
      : AppColors.thermometerAccent;

  void _save() {
    final raw = _thresholdCtrl.text.trim().replaceAll(',', '.');
    final threshold = double.tryParse(raw);
    if (threshold == null) {
      setState(() => _error = 'Enter a valid number');
      return;
    }
    if (_notifications.isEmpty) {
      setState(() => _error = 'Select at least one notification type');
      return;
    }
    Navigator.of(context).pop(
      SensorAlert(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        equipmentId: widget.equipmentId,
        condition: _condition,
        threshold: threshold,
        notifications: Set.unmodifiable(_notifications),
        isHumidity: widget.isHumidity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;

    return AppDialog(
      title: context.l10n.smartPlugAlertSheetTitle,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Metric label (read-only) ───────────────────────────────────
          _SectionLabel(_metricLabel),
          AppSpacing.gapX3l,

          // ── Alert type ─────────────────────────────────────────────────
          _SectionLabel(context.l10n.smartPlugAlertConditionLabel),
          AppSpacing.gapMd,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              AppDialogChip(
                label: context.l10n.sensorAlertConditionAbove,
                selected: _condition == SensorAlertCondition.above,
                accentColor: accent,
                onTap: () => setState(() {
                  _condition = SensorAlertCondition.above;
                  _error = null;
                }),
              ),
              AppDialogChip(
                label: context.l10n.sensorAlertConditionBelow,
                selected: _condition == SensorAlertCondition.below,
                accentColor: accent,
                onTap: () => setState(() {
                  _condition = SensorAlertCondition.below;
                  _error = null;
                }),
              ),
            ],
          ),
          AppSpacing.gapX3l,

          // ── Threshold ──────────────────────────────────────────────────
          _SectionLabel(context.l10n.smartPlugAlertThresholdLabel),
          AppSpacing.gapMd,
          TextField(
            controller: _thresholdCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontFamily: 'ShareTech',
              fontSize: AppFontSizes.body,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.isHumidity ? 'e.g. 70' : 'e.g. 28',
              suffixText: _unit,
              suffixStyle: const TextStyle(
                fontFamily: 'ShareTech',
                fontSize: AppFontSizes.sm,
                color: AppColors.textSecondary,
              ),
            ),
            onChanged: (_) => setState(() => _error = null),
          ),
          AppSpacing.gapX3l,

          // ── Notifications ──────────────────────────────────────────────
          _SectionLabel(context.l10n.smartPlugAlertNotificationsLabel),
          AppSpacing.gapMd,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              AppDialogChip(
                label: context.l10n.smartPlugAlertNotifPush,
                icon: Icons.notifications_rounded,
                selected: _notifications
                    .contains(SensorAlertNotification.push),
                onTap: () => setState(() {
                  _toggleNotif(SensorAlertNotification.push);
                  _error = null;
                }),
              ),
              AppDialogChip(
                label: context.l10n.smartPlugAlertNotifBanner,
                icon: Icons.announcement_outlined,
                selected: _notifications
                    .contains(SensorAlertNotification.banner),
                onTap: () => setState(() {
                  _toggleNotif(SensorAlertNotification.banner);
                  _error = null;
                }),
              ),
            ],
          ),

          // ── Validation error ───────────────────────────────────────────
          if (_error != null) ...[
            AppSpacing.gapMd,
            Text(
              _error!,
              style: const TextStyle(
                fontFamily: 'ShareTech',
                fontSize: AppFontSizes.sm,
                color: AppColors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _toggleNotif(SensorAlertNotification notif) {
    if (_notifications.contains(notif)) {
      _notifications.remove(notif);
    } else {
      _notifications.add(notif);
    }
  }
}

// ── Private helper ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'ShareTech',
          fontSize: AppFontSizes.sm,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      );
}
