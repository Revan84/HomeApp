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
import '../../integrations/shelly/data/dto/shelly_device_info_dto.dart';
import '../controllers/equipments_controller.dart';

class AddEquipmentSheet extends StatefulWidget {
  final ValueNotifier<int> roomsRefreshNotifier;

  const AddEquipmentSheet({super.key, required this.roomsRefreshNotifier});

  @override
  State<AddEquipmentSheet> createState() => _AddEquipmentSheetState();
}

class _AddEquipmentSheetState extends State<AddEquipmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ipCtrl = TextEditingController();

  EquipmentType _type = EquipmentType.shellyPlusPlugS;
  int _channel = 0;

  bool _showToggle = true;
  bool _showPower = true;
  bool _showEnergy = false;
  bool _showRssi = false;

  String? _selectedRoomId;
  bool _isFavorite = false;

  bool _testing = false;
  bool _testOk = false;
  String? _testError;
  ShellyDeviceInfoDto? _deviceInfo;

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

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<EquipmentsController>();
    setState(() {
      _testing = true;
      _testOk = false;
      _testError = null;
      _deviceInfo = null;
    });

    try {
      final data = await controller.testShellyConnection(_ipCtrl.text.trim());
      if (!mounted) return;
      setState(() {
        _testOk = true;
        _deviceInfo = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _testError = context.l10n.testFailed(e.toString()));
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<EquipmentsController>();
    final eq = Equipment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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

    await controller.addEquipment(eq);

    if (!mounted) return;
    Navigator.of(context).pop(true);
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
                title: l.addEquipmentTitle,
                showDragHandle: true,
                onClose: () => Navigator.of(context).pop(false),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _nameCtrl,
                      label: l.nameLabel,
                      hint: l.nameHintExample,
                    ),
                    AppSpacing.gapLg,
                    AppTextField(
                      controller: _ipCtrl,
                      label: l.ipLocalLabel,
                      hint: l.ipLocalHint,
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
                      onChanged: (v) => _channel = int.tryParse(v.trim()) ?? 0,
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
                      onChanged: (v) =>
                          setState(() => _type = v ?? EquipmentType.other),
                    ),
                    AppSpacing.gapLg,
                    DropdownButtonFormField<String?>(
                      initialValue: _selectedRoomId,
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
                        ...rooms.map((r) => DropdownMenuItem<String?>(
                              value: r.id,
                              child: Text(r.name),
                            )),
                      ],
                      onChanged: (v) => setState(() => _selectedRoomId = v),
                    ),
                    SwitchListTile(
                      value: _isFavorite,
                      onChanged: (v) => setState(() => _isFavorite = v),
                      title: Text(l.favorite),
                    ),
                    AppSpacing.gapX2l,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l.showDataTitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
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
                    AppSpacing.gapLg,
                    if (_testError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _testError!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.danger),
                          ),
                        ),
                      ),
                    if (_deviceInfo != null) _DeviceInfoPreview(data: _deviceInfo!),
                    AppSpacing.gapXl,
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: _testOk ? l.testOk : l.test,
                            leading: _testOk ? Icons.check : Icons.wifi_tethering,
                            variant: AppButtonVariant.secondary,
                            onPressed: _testing ? null : _testConnection,
                          ),
                        ),
                        AppSpacing.gapHXl,
                        Expanded(
                          child: AppButton(
                            label: l.save,
                            leading: Icons.save,
                            onPressed: _save,
                          ),
                        ),
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

class _DeviceInfoPreview extends StatelessWidget {
  final ShellyDeviceInfoDto data;
  const _DeviceInfoPreview({required this.data});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPaddingCompact,
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlBR,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.detectedInfoTitle,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          AppSpacing.gapSm,
          if (data.name.isNotEmpty) Text(l.deviceInfoName(data.name)),
          if (data.model.isNotEmpty) Text(l.deviceInfoModel(data.model)),
          if (data.mac.isNotEmpty) Text(l.deviceInfoMac(data.mac)),
        ],
      ),
    );
  }
}
