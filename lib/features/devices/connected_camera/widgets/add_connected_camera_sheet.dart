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
import '../../../../domain/entities/camera_brand.dart';
import '../../../../domain/entities/camera_capabilities.dart';
import '../../../../domain/entities/connected_camera_device.dart';
import '../../../equipments/controllers/equipments_controller.dart';
import '../../../integrations/cameras/data/camera_api_client_factory.dart';

/// Bottom sheet for adding a new IP camera.
///
/// Generic entry form — name, IP, and optional credentials. A real
/// brand-specific test (Reolink, Tapo, etc.) will be added when a camera
/// is available. Until then the Test button checks basic HTTP reachability.
class AddConnectedCameraSheet extends StatefulWidget {
  const AddConnectedCameraSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTopBR),
        builder: (_) => const AddConnectedCameraSheet(),
      );

  @override
  State<AddConnectedCameraSheet> createState() =>
      _AddConnectedCameraSheetState();
}

class _AddConnectedCameraSheetState extends State<AddConnectedCameraSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ipCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

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
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Validators ────────────────────────────────────────────────────────────────

  String? _validateIp(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return context.l10n.validationIpRequired;
    if (!Validators.isValidIpv4(s)) return context.l10n.validationIpInvalidFormat;
    return null;
  }

  String? _validateName(String? v) =>
      (v == null || v.trim().isEmpty) ? context.l10n.validationNameRequired : null;

  // ── Test connection ───────────────────────────────────────────────────────────

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    final factory = context.read<CameraApiClientFactory>();
    setState(() {
      _testing = true;
      _testOk = false;
      _testError = null;
    });
    try {
      final api = factory.forBrand(CameraBrand.generic);
      final ip = _ipCtrl.text.trim();
      final user = _userCtrl.text.trim();
      final pass = _passCtrl.text;

      final ok = await api.testConnection(
        ip: ip,
        httpApiPort: 80,
        username: user.isEmpty ? null : user,
        password: pass.isEmpty ? null : pass,
      );

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

  // ── Save ──────────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final device = ConnectedCameraDevice(
      id: const TimestampIdGenerator().generate(),
      name: _nameCtrl.text.trim(),
      ipAddress: _ipCtrl.text.trim(),
      roomId: _selectedRoomId,
      isFavorite: _isFavorite,
      brand: CameraBrand.generic,
      capabilities: CameraCapabilities.unknown,
      cameraAccountUser: _userCtrl.text.trim(),
      cameraAccountPassword: _passCtrl.text,
      httpApiPort: 80,
      onvifPort: 8000,
    );

    try {
      await context.read<EquipmentsController>().addConnectedCameraDevice(device);
      if (mounted) Navigator.of(context).pop(true);
    } catch (err, st) {
      dev.log('ConnectedCamera add failed', error: err, stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.connectedCameraAddDeviceError)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

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
                title: l.connectedCameraAddTitle,
                leadingIcon: Icons.videocam_rounded,
                showDragHandle: true,
                onClose: () => Navigator.of(context).pop(false),
              ),
              AppSpacing.gapXs,
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _nameCtrl,
                      label: l.nameLabel,
                      hint: l.nameHintExample,
                      validator: _validateName,
                    ),
                    AppSpacing.gapLg,
                    AppTextField(
                      controller: _ipCtrl,
                      keyboardType: TextInputType.number,
                      label: l.deviceInfoLocalIp,
                      hint: l.ipLocalHint,
                      validator: _validateIp,
                    ),
                    AppSpacing.gapLg,
                    AppTextField(
                      controller: _userCtrl,
                      label: l.cameraAccountUserLabel,
                      hint: l.cameraAccountUserHint,
                    ),
                    AppSpacing.gapLg,
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l.cameraAccountPasswordLabel,
                        hintText: l.cameraAccountPasswordHint,
                      ),
                    ),
                    AppSpacing.gapLg,
                    DropdownButtonFormField<String?>(
                      initialValue: _selectedRoomId,
                      dropdownColor: AppColors.surface,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textPrimary),
                      borderRadius: AppRadius.xlBR,
                      decoration: InputDecoration(labelText: l.roomLabel),
                      items: [
                        DropdownMenuItem<String?>(
                            value: null, child: Text(l.none)),
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
                    AppSpacing.gapMd,

                    // Test feedback
                    if (_testError != null) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _testError!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      AppSpacing.gapXs,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: _saving ? null : _save,
                          child: Text(
                            l.cameraTestSaveAnyway,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],

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
                            onPressed: _saving ? null : _save,
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
