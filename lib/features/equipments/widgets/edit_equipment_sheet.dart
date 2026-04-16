import 'package:flutter/material.dart';
import 'package:front_end/core/i18n/loc.dart';
import 'package:provider/provider.dart';

import '../../../core/design_system/buttons/app_button.dart';
import '../../../core/design_system/inputs/app_text_field.dart';
import '../../../core/design_system/layout/app_sheet_header.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

import '../../../domain/entities/equipment.dart';
import '../controllers/equipments_controller.dart';

class EditEquipmentSheet extends StatefulWidget {
  final Equipment initial;
  const EditEquipmentSheet({super.key, required this.initial});

  @override
  State<EditEquipmentSheet> createState() => _EditEquipmentSheetState();
}

class _EditEquipmentSheetState extends State<EditEquipmentSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ipCtrl;

  late EquipmentType _type;
  late bool _showToggle;
  late bool _showPower;
  late bool _showEnergy;
  late bool _showRssi;
  late int _channel;

  String? _selectedRoomId;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;

    _nameCtrl = TextEditingController(text: e.name);
    _ipCtrl = TextEditingController(text: e.ip);

    _type = e.type;
    _showToggle = e.showToggle;
    _showPower = e.showPower;
    _showEnergy = e.showEnergy;
    _showRssi = e.showRssi;

    _selectedRoomId = e.roomId;
    _isFavorite = e.isFavorite;
    _channel = e.channel;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ipCtrl.dispose();
    super.dispose();
  }

  String? _validateIp(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return context.l10n.validationIpRequired;

    final reg = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!reg.hasMatch(s)) return context.l10n.validationIpInvalidFormat;

    final parts = s.split('.').map(int.parse).toList();
    if (parts.any((p) => p < 0 || p > 255)) return context.l10n.validationIpInvalid;

    return null;
  }

  String? _validateChannel(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null) return context.l10n.validationNumberInvalid;
    if (n < 0 || n > 3) return context.l10n.validationChannelInvalid;
    return null;
  }

  String _typeLabel(BuildContext context, EquipmentType t) {
    switch (t) {
      case EquipmentType.shellyPlusPlugS:
        return context.l10n.equipmentTypeShellyPlusPlugS;
      case EquipmentType.shellyPlugS:
        return context.l10n.equipmentTypeShellyPlugS;
      case EquipmentType.shellyHT:
        return 'Shelly HT';
      case EquipmentType.other:
        return context.l10n.equipmentTypeOther;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<EquipmentsController>();
    final updated = widget.initial.copyWith(
      name: _nameCtrl.text.trim().isEmpty
          ? context.l10n.defaultEquipmentName
          : _nameCtrl.text.trim(),
      ip: _ipCtrl.text.trim(),
      type: _type,
      roomId: _selectedRoomId,
      isFavorite: _isFavorite,
      showToggle: _showToggle,
      showPower: _showPower,
      showEnergy: _showEnergy,
      showRssi: _showRssi,
      channel: _channel,
    );

    await controller.updateEquipment(updated);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final rooms = context.watch<EquipmentsController>().rooms;
    final safeRoomId = rooms.any((r) => r.id == _selectedRoomId) ? _selectedRoomId : null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.sheetPadding,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSheetHeader(
                  title: l.editEquipmentTitle,
                  showDragHandle: true,
                  onClose: () => Navigator.of(context).pop(false),
                ),
                AppTextField(
                  controller: _nameCtrl,
                  label: l.nameLabel,
                ),
                AppSpacing.gapLg,
                AppTextField(
                  controller: _ipCtrl,
                  label: l.ipLocalLabel,
                  keyboardType: TextInputType.number,
                  validator: _validateIp,
                ),
                AppSpacing.gapLg,
                AppTextField(
                  initialValue: _channel.toString(),
                  label: l.channelLabel,
                  hint: l.channelHint,
                  keyboardType: TextInputType.number,
                  validator: _validateChannel,
                  onChanged: (v) => _channel = int.tryParse(v.trim()) ?? _channel,
                ),
                AppSpacing.gapLg,
                DropdownButtonFormField<EquipmentType>(
                  initialValue: _type,
                  dropdownColor: AppColors.surface,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                  borderRadius: AppRadius.xlBR,
                  decoration: InputDecoration(labelText: l.typeLabel),
                  items: EquipmentType.values
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(_typeLabel(context, t)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v ?? EquipmentType.other),
                ),
                AppSpacing.gapLg,
                DropdownButtonFormField<String?>(
                  initialValue: safeRoomId,
                  dropdownColor: AppColors.surface,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                  borderRadius: AppRadius.xlBR,
                  decoration: InputDecoration(labelText: l.roomLabel),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l.none),
                    ),
                    ...rooms.map(
                      (r) => DropdownMenuItem<String?>(
                        value: r.id,
                        child: Text(r.name),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedRoomId = v),
                ),
                SwitchListTile(
                  value: _isFavorite,
                  onChanged: (v) => setState(() => _isFavorite = v),
                  title: Text(l.favorite),
                ),
                AppSpacing.gapMd,
                SwitchListTile(
                  value: _showToggle,
                  onChanged: (v) => setState(() => _showToggle = v),
                  title: Text(l.showOnOff),
                ),
                SwitchListTile(
                  value: _showPower,
                  onChanged: (v) => setState(() => _showPower = v),
                  title: Text(l.showPower),
                ),
                SwitchListTile(
                  value: _showEnergy,
                  onChanged: (v) => setState(() => _showEnergy = v),
                  title: Text(l.showEnergy),
                ),
                SwitchListTile(
                  value: _showRssi,
                  onChanged: (v) => setState(() => _showRssi = v),
                  title: Text(l.showRssi),
                ),
                AppSpacing.gapXl,
                AppButton(
                  label: l.save,
                  leading: Icons.save,
                  onPressed: _save,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
