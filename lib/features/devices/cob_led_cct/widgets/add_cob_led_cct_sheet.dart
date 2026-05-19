import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/buttons/app_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../../../../core/design_system/layout/app_sheet_header.dart';
import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/utils/validators.dart';
import '../../../../domain/entities/cob_led_cct_device.dart';
import '../../../equipments/controllers/equipments_controller.dart';

/// Bottom sheet for adding a new COB LED CCT controller device.
///
/// Mirrors the design-system patterns of `add_cob_led_rgb_sheet.dart`.
class AddCobLedCctSheet extends StatefulWidget {
  const AddCobLedCctSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTopBR),
        builder: (_) => const AddCobLedCctSheet(),
      );

  @override
  State<AddCobLedCctSheet> createState() => _AddCobLedCctSheetState();
}

class _AddCobLedCctSheetState extends State<AddCobLedCctSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ipCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();

  String? _selectedRoomId;
  bool _isFavorite = false;
  bool _testing = false;
  bool _testOk = false;
  String? _testError;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ipCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  String? _validateIp(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return context.l10n.validationIpRequired;
    if (!Validators.isValidIpv4(s)) return context.l10n.validationIpInvalidFormat;
    return null;
  }

  String? _validateName(String? v) =>
      (v == null || v.trim().isEmpty) ? context.l10n.validationNameRequired : null;

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<EquipmentsController>();
    setState(() { _testing = true; _testOk = false; _testError = null; });
    try {
      final ok = await controller.testCobLedCctConnection(_ipCtrl.text.trim());
      if (!mounted) return;
      setState(() {
        _testOk = ok;
        if (!ok) _testError = context.l10n.deviceTestFailed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _testError = context.l10n.deviceTestFailed);
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final device = CobLedCctDevice(
      id: const TimestampIdGenerator().generate(),
      name: _nameCtrl.text.trim(),
      ipAddress: _ipCtrl.text.trim(),
      roomId: _selectedRoomId,
      isFavorite: _isFavorite,
      modelName: _modelCtrl.text.trim(),
    );
    try {
      await context.read<EquipmentsController>().addCobLedCctDevice(device);
      if (mounted) Navigator.of(context).pop(true);
    } catch (err, st) {
      // Why: user sees a localised generic message; raw exception is logged.
      dev.log('CCT add failed', error: err, stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.cobLedCctAddDeviceError)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final rooms = context.watch<EquipmentsController>().rooms;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.sheetPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSheetHeader(
                title: l.cobLedCctAddTitle,
                leadingIcon: Icons.lightbulb_outline_rounded,
                showDragHandle: true,
                onClose: () => Navigator.of(context).pop(false),
              ),
              AppSpacing.gapXs,
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(controller: _nameCtrl, label: l.nameLabel,
                        hint: l.nameHintExample, validator: _validateName),
                    AppSpacing.gapLg,
                    AppTextField(controller: _ipCtrl, keyboardType: TextInputType.number,
                        label: l.deviceInfoLocalIp, hint: l.ipLocalHint, validator: _validateIp),
                    AppSpacing.gapLg,
                    AppTextField(controller: _modelCtrl,
                        label: l.addDeviceModelOptionalLabel, hint: l.cobLedCctDeviceHint),
                    AppSpacing.gapLg,
                    DropdownButtonFormField<String?>(
                      initialValue: _selectedRoomId,
                      dropdownColor: AppColors.surface,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textPrimary),
                      borderRadius: AppRadius.xlBR,
                      decoration: InputDecoration(labelText: l.roomLabel),
                      items: [
                        DropdownMenuItem<String?>(value: null, child: Text(l.none)),
                        ...rooms.map((r) => DropdownMenuItem<String?>(
                          value: r.id, child: Text(r.name))),
                      ],
                      onChanged: (v) => setState(() => _selectedRoomId = v),
                    ),
                    SwitchListTile(
                      value: _isFavorite,
                      onChanged: (v) => setState(() => _isFavorite = v),
                      title: Text(l.favorite),
                    ),
                    AppSpacing.gapMd,
                    if (_testError != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(_testError!, style: Theme.of(context).textTheme
                            .bodySmall?.copyWith(color: AppColors.danger)),
                      ),
                    AppSpacing.gapXl,
                    Row(
                      children: [
                        Expanded(child: AppButton(
                          label: _testOk ? l.testOk : l.test,
                          leading: _testOk ? Icons.check : Icons.wifi_tethering,
                          variant: AppButtonVariant.secondary,
                          onPressed: _testing ? null : _testConnection,
                        )),
                        AppSpacing.gapHXl,
                        Expanded(child: AppButton(
                          label: l.save,
                          leading: Icons.save,
                          onPressed: _saving ? null : _save,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
