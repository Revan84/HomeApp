import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/design_system/buttons/app_button.dart';
import '../../../../core/design_system/inputs/app_text_field.dart';
import '../../../../core/design_system/layout/app_sheet_header.dart';
import '../../../../core/i18n/loc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/tv_device.dart';
import '../../../equipments/controllers/equipments_controller.dart';

class AddTvSheet extends StatefulWidget {
  const AddTvSheet({super.key});

  @override
  State<AddTvSheet> createState() => _AddTvSheetState();
}

class _AddTvSheetState extends State<AddTvSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ipCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();

  String? _selectedRoomId;
  bool _isFavorite = false;

  bool _testing = false;
  bool _testOk = false;
  String? _testError;
  String? _pairedToken;

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

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<EquipmentsController>();
    setState(() {
      _testing = true;
      _testOk = false;
      _testError = null;
    });

    try {
      final result = await controller.testTvConnection(_ipCtrl.text.trim());
      if (!mounted) return;
      setState(() {
        _testOk = result.ok;
        _pairedToken = result.token;
        if (!result.ok) _testError = context.l10n.tvTestFailed;
      });
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<EquipmentsController>();
    final device = TvDevice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim().isEmpty
          ? context.l10n.tvDefaultName
          : _nameCtrl.text.trim(),
      ipAddress: _ipCtrl.text.trim(),
      roomId: _selectedRoomId,
      isFavorite: _isFavorite,
      modelName: _modelCtrl.text.trim(),
      wsToken: _pairedToken,
    );

    await controller.addTvDevice(device);

    if (!mounted) return;
    Navigator.of(context).pop(true);
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
                title: l.tvAddTitle,
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
                      hint: l.tvNameHint,
                    ),
                    AppSpacing.gapLg,
                    AppTextField(
                      controller: _ipCtrl,
                      keyboardType: TextInputType.number,
                      label: l.ipLocalLabel,
                      hint: l.ipLocalHint,
                      validator: _validateIp,
                    ),
                    AppSpacing.gapLg,
                    AppTextField(
                      controller: _modelCtrl,
                      label: l.tvModelLabel,
                      hint: l.tvModelHint,
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
                    AppSpacing.gapLg,
                    if (_testError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
