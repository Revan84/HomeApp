import 'package:flutter/material.dart';

import '../../../../core/design_system/dialogs/app_dialog.dart';
import '../../../../core/design_system/dialogs/app_dialog_chip.dart';
import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/plug_alert.dart';

/// Dialog for creating a new [PlugAlert].
///
/// Usage:
/// ```dart
/// final alert = await SmartPlugAlertSheet.show(context, equipmentId: e.id);
/// if (alert != null) ctrl.addAlert(alert);
/// ```
class SmartPlugAlertSheet extends StatefulWidget {
  final String equipmentId;

  const SmartPlugAlertSheet._({required this.equipmentId});

  /// Opens the dialog and returns a configured [PlugAlert] on save,
  /// or `null` if the user cancels.
  static Future<PlugAlert?> show(
    BuildContext context, {
    required String equipmentId,
  }) {
    return showDialog<PlugAlert>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => SmartPlugAlertSheet._(equipmentId: equipmentId),
    );
  }

  @override
  State<SmartPlugAlertSheet> createState() => _SmartPlugAlertSheetState();
}

class _SmartPlugAlertSheetState extends State<SmartPlugAlertSheet> {
  PlugAlertCondition _condition = PlugAlertCondition.wattsExceeded;
  final _thresholdCtrl = TextEditingController();
  final Set<PlugAlertNotification> _notifications = {
    PlugAlertNotification.banner,
  };
  String? _error;

  @override
  void dispose() {
    _thresholdCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = context.l10n;
    final raw = _thresholdCtrl.text.trim().replaceAll(',', '.');
    final threshold = double.tryParse(raw);
    if (threshold == null || threshold <= 0) {
      setState(() => _error = _invalidThresholdMessage());
      return;
    }
    if (_notifications.isEmpty) {
      setState(() => _error = l10n.smartPlugAlertNotifRequired);
      return;
    }
    Navigator.of(context).pop(
      PlugAlert(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        equipmentId: widget.equipmentId,
        condition: _condition,
        threshold: threshold,
        notifications: Set.unmodifiable(_notifications),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppDialog(
      title: l10n.smartPlugAlertSheetTitle,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Alert type ─────────────────────────────────────────────────
          _SectionLabel(l10n.smartPlugAlertConditionLabel),
          AppSpacing.gapMd,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              AppDialogChip(
                label: l10n.smartPlugAlertConditionWatts,
                selected: _condition == PlugAlertCondition.wattsExceeded,
                accentColor: AppColors.plugAccent,
                onTap: () => setState(() {
                  _condition = PlugAlertCondition.wattsExceeded;
                  _error = null;
                }),
              ),
              AppDialogChip(
                label: l10n.smartPlugAlertConditionDailyCost,
                selected:
                    _condition == PlugAlertCondition.dailyCostExceeded,
                accentColor: AppColors.plugAccent,
                onTap: () => setState(() {
                  _condition = PlugAlertCondition.dailyCostExceeded;
                  _error = null;
                }),
              ),
            ],
          ),
          AppSpacing.gapX3l,

          // ── Threshold ──────────────────────────────────────────────────
          _SectionLabel(l10n.smartPlugAlertThresholdLabel),
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
              hintText:
                  _condition == PlugAlertCondition.wattsExceeded
                      ? l10n.smartPlugAlertThresholdHintWatts
                      : l10n.smartPlugAlertThresholdHintCost,
              suffixText:
                  _condition == PlugAlertCondition.wattsExceeded
                      ? 'W'
                      : '€/day',
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
          _SectionLabel(l10n.smartPlugAlertNotificationsLabel),
          AppSpacing.gapMd,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              AppDialogChip(
                label: l10n.smartPlugAlertNotifPush,
                icon: Icons.notifications_rounded,
                selected: _notifications
                    .contains(PlugAlertNotification.push),
                onTap: () => setState(() {
                  _toggleNotif(PlugAlertNotification.push);
                  _error = null;
                }),
              ),
              AppDialogChip(
                label: l10n.smartPlugAlertNotifBanner,
                icon: Icons.announcement_outlined,
                selected: _notifications
                    .contains(PlugAlertNotification.banner),
                onTap: () => setState(() {
                  _toggleNotif(PlugAlertNotification.banner);
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

  String _invalidThresholdMessage() {
    final l10n = context.l10n;
    final hint = _condition == PlugAlertCondition.wattsExceeded
        ? l10n.smartPlugAlertThresholdHintWatts
        : l10n.smartPlugAlertThresholdHintCost;
    return '${l10n.smartPlugAlertThresholdLabel}: $hint';
  }

  void _toggleNotif(PlugAlertNotification notif) {
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
