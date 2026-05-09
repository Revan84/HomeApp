import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/design_system/buttons/app_button.dart';
import '../../../core/i18n/loc.dart';
import '../../../core/utils/validators.dart';
import '../../../core/design_system/dialogs/app_dialog.dart';
import '../../../core/design_system/inputs/app_dropdown_field.dart';
import '../../../core/design_system/inputs/app_form_label.dart';
import '../../../core/design_system/inputs/app_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_font_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/cob_led_cct_device.dart';
import '../../../domain/entities/cob_led_rgb_device.dart';
import '../../../domain/entities/equipment.dart';
import '../../../domain/entities/tv_device.dart';
import '../../integrations/shelly/data/dto/shelly_device_info_dto.dart';
import '../controllers/equipments_controller.dart';
import 'device_info_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Device type enum — owns the full set of supported device kinds
// ─────────────────────────────────────────────────────────────────────────────

enum _DeviceKind {
  smartPlug,
  tv,
  cobLedRgb,
  cobLedCct,
  thermometer,
  hygrometer,
}

extension _DeviceKindX on _DeviceKind {
  String label(BuildContext context) => switch (this) {
        _DeviceKind.smartPlug => context.l10n.deviceTypePlug,
        _DeviceKind.tv => context.l10n.deviceTypeTv,
        _DeviceKind.cobLedRgb => context.l10n.cobLedRgbTypeLabel,
        _DeviceKind.cobLedCct => context.l10n.cobLedCctTypeLabel,
        _DeviceKind.thermometer => context.l10n.thermometerTypeLabel,
        _DeviceKind.hygrometer => context.l10n.hygrometerTypeLabel,
      };

  IconData get icon => switch (this) {
        _DeviceKind.smartPlug => Icons.power_rounded,
        _DeviceKind.tv => Icons.tv_rounded,
        _DeviceKind.cobLedRgb => Icons.lightbulb_outline_rounded,
        _DeviceKind.cobLedCct => Icons.wb_incandescent_outlined,
        _DeviceKind.thermometer => Icons.thermostat_rounded,
        _DeviceKind.hygrometer => Icons.water_drop_outlined,
      };

  /// Whether to show the "Test" connection button.
  bool get hasTest => this != _DeviceKind.tv;

  /// Default device name hint.
  String get nameHint => switch (this) {
        _DeviceKind.smartPlug => 'e.g. Desk plug',
        _DeviceKind.tv => 'e.g. Living Room TV',
        _DeviceKind.cobLedRgb => 'e.g. LED Strip',
        _DeviceKind.cobLedCct => 'e.g. Ceiling Light',
        _DeviceKind.thermometer => 'e.g. Bedroom sensor',
        _DeviceKind.hygrometer => 'e.g. Bathroom sensor',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
//  Dialog
// ─────────────────────────────────────────────────────────────────────────────

/// Unified "Add a device manually" dialog.
///
/// Step 1: user picks the device type from a dropdown.
/// Step 2: form fields for that type appear (name, IP, room, favourite).
///
/// Usage:
/// ```dart
/// final added = await AddDeviceDialog.show(context);
/// if (added == true) _refresh();
/// ```
class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog._();

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (_) => const AddDeviceDialog._(),
    );
  }

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ipCtrl = TextEditingController();

  _DeviceKind? _kind;
  String? _selectedRoomId;
  bool _isFavorite = false;

  bool _testing = false;
  bool _testOk = false;
  String? _testError;
  ShellyDeviceInfoDto? _deviceInfo;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ipCtrl.dispose();
    super.dispose();
  }

  bool get _hasFields => _kind != null;

  // ── Test connection ──────────────────────────────────────────────────────

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = context.read<EquipmentsController>();
    final ip = _ipCtrl.text.trim();
    setState(() {
      _testing = true;
      _testOk = false;
      _testError = null;
      _deviceInfo = null;
    });
    try {
      switch (_kind!) {
        case _DeviceKind.cobLedCct:
          final ok = await ctrl.testCobLedCctConnection(ip);
          if (!mounted) return;
          if (ok) {
            setState(() => _testOk = true);
          } else {
            setState(() =>
                _testError = context.l10n.connectionFailedDetail('unreachable'));
          }
        case _DeviceKind.cobLedRgb:
          final ok = await ctrl.testCobLedRgbConnection(ip);
          if (!mounted) return;
          if (ok) {
            setState(() => _testOk = true);
          } else {
            setState(() =>
                _testError = context.l10n.connectionFailedDetail('unreachable'));
          }
        default:
          // Shelly-based devices (smartPlug, thermometer, hygrometer)
          final info = await ctrl.testShellyConnection(ip);
          if (!mounted) return;
          setState(() {
            _testOk = true;
            if (_kind == _DeviceKind.smartPlug) _deviceInfo = info;
          });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _testError = context.l10n.connectionFailedDetail(e.toString()));
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_kind == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final ctrl = context.read<EquipmentsController>();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final name = _nameCtrl.text.trim().isEmpty
        ? _kind!.label(context)
        : _nameCtrl.text.trim();
    final ip = _ipCtrl.text.trim();

    try {
      switch (_kind!) {
        case _DeviceKind.smartPlug:
          await ctrl.addEquipment(Equipment(
            id: id,
            name: name,
            ip: ip,
            type: EquipmentType.shellyPlusPlugS,
            roomId: _selectedRoomId,
            isFavorite: _isFavorite,
            showToggle: true,
            showPower: true,
            showEnergy: false,
            showRssi: false,
            channel: 0,
          ));
        case _DeviceKind.thermometer:
          await ctrl.addEquipment(Equipment(
            id: id,
            name: name,
            ip: ip,
            type: EquipmentType.shellyHT,
            roomId: _selectedRoomId,
            isFavorite: _isFavorite,
            showToggle: false,
            showPower: false,
            showEnergy: false,
            showRssi: false,
            channel: 0,
          ));
        case _DeviceKind.hygrometer:
          await ctrl.addEquipment(Equipment(
            id: id,
            name: name,
            ip: ip,
            type: EquipmentType.hygrometer,
            roomId: _selectedRoomId,
            isFavorite: _isFavorite,
            showToggle: false,
            showPower: false,
            showEnergy: false,
            showRssi: false,
            channel: 0,
          ));
        case _DeviceKind.tv:
          await ctrl.addTvDevice(TvDevice(
            id: id,
            name: name,
            ipAddress: ip,
            roomId: _selectedRoomId,
            isFavorite: _isFavorite,
          ));
        case _DeviceKind.cobLedRgb:
          await ctrl.addCobLedRgbDevice(CobLedRgbDevice(
            id: id,
            name: name,
            ipAddress: ip,
            roomId: _selectedRoomId,
            isFavorite: _isFavorite,
          ));
        case _DeviceKind.cobLedCct:
          await ctrl.addCobLedCctDevice(CobLedCctDevice(
            id: id,
            name: name,
            ipAddress: ip,
            roomId: _selectedRoomId,
            isFavorite: _isFavorite,
          ));
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _testError = e.toString();
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<EquipmentsController>().rooms;

    final l10n = context.l10n;

    return AppDialog(
      title: l10n.addDeviceTitle,
      onSave: (_hasFields && !_saving) ? _save : null,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Device type dropdown ───────────────────────────────────
            AppFormLabel(l10n.addDeviceTypeLabel),
            AppSpacing.gapMd,
            AppDropdownField<_DeviceKind>(
              value: _kind,
              hint: l10n.addDeviceTypeHint,
              items: _DeviceKind.values.map((k) {
                return DropdownMenuItem(
                  value: k,
                  child: Row(
                    children: [
                      Icon(k.icon, size: 16, color: AppColors.textSecondary),
                      AppSpacing.gapHMd,
                      Text(k.label(context)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() {
                _kind = v;
                _testOk = false;
                _testError = null;
                _deviceInfo = null;
              }),
            ),

            // ── Fields (revealed after type selection) ─────────────────
            if (_hasFields) ...[
              AppSpacing.gapX3l,

              // Device Name
              AppFormLabel(l10n.addDeviceNameLabel),
              AppSpacing.gapMd,
              AppTextField(
                controller: _nameCtrl,
                hint: _kind!.nameHint,
              ),
              AppSpacing.gapX2l,

              // Local IP
              AppFormLabel(l10n.addDeviceIpLabel),
              AppSpacing.gapMd,
              AppTextField(
                controller: _ipCtrl,
                hint: l10n.ipLocalHint,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return l10n.validationIpRequired;
                  if (!Validators.isValidIpv4(s)) return l10n.validationIpInvalidFormat;
                  return null;
                },
              ),
              AppSpacing.gapX2l,

              // Room
              AppFormLabel(l10n.addDeviceRoomLabel),
              AppSpacing.gapMd,
              AppDropdownField<String?>(
                value: _selectedRoomId,
                hint: l10n.none,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.none),
                  ),
                  ...rooms.map((r) => DropdownMenuItem<String?>(
                        value: r.id,
                        child: Text(r.name),
                      )),
                ],
                onChanged: (v) => setState(() => _selectedRoomId = v),
              ),
              AppSpacing.gapX2l,

              // Favourite toggle
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.addDeviceFavoriteLabel,
                      style: const TextStyle(
                        fontSize: AppFontSizes.body,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Switch(
                    value: _isFavorite,
                    activeTrackColor: AppColors.primary,
                    activeThumbColor: Colors.white,
                    onChanged: (v) => setState(() => _isFavorite = v),
                  ),
                ],
              ),

              // Test button + result
              if (_kind!.hasTest) ...[
                AppSpacing.gapMd,
                AppButton(
                  label: _testOk ? l10n.addDeviceConnectedCheck : l10n.test,
                  leading: _testOk
                      ? Icons.check_rounded
                      : Icons.wifi_tethering_rounded,
                  variant: _testOk
                      ? AppButtonVariant.primary
                      : AppButtonVariant.secondary,
                  compact: true,
                  onPressed: _testing ? null : _testConnection,
                ),
              ],

              // Device info
              if (_deviceInfo != null) ...[
                AppSpacing.gapMd,
                DeviceInfoCard(data: _deviceInfo!),
              ],

              // Error
              if (_testError != null) ...[
                AppSpacing.gapMd,
                Text(
                  _testError!,
                  style: const TextStyle(
                    fontSize: AppFontSizes.xs,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

