import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/loc.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_font_sizes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../domain/entities/cob_led_cct_device.dart';
import '../../../../domain/entities/room.dart';
import '../../../equipments/controllers/equipments_controller.dart';

/// Bottom sheet for adding a new COB LED CCT controller device.
///
/// Calls [EquipmentsController.addCobLedCctDevice] on save, and optionally
/// tests the connection before saving.
class AddCobLedCctSheet extends StatefulWidget {
  const AddCobLedCctSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.sheetTopBR,
        ),
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
  bool? _testResult;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ipCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _testing = true;
      _testResult = null;
    });
    try {
      final ok = await context
          .read<EquipmentsController>()
          .testCobLedCctConnection(_ipCtrl.text.trim());
      if (mounted) setState(() => _testResult = ok);
    } catch (_) {
      if (mounted) setState(() => _testResult = false);
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
      if (mounted) Navigator.of(context).pop();
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rooms =
        context.watch<EquipmentsController>().rooms;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: AppSpacing.sheetPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Handle ───────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: AppRadius.xsBR,
                    ),
                  ),
                ),
                AppSpacing.gapX3l,

                Text(
                  l10n.cobLedCctAddTitle,
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSizes.heading,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.gapX3l,

                // ── Name ─────────────────────────────────────────────────
                TextFormField(
                  controller: _nameCtrl,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.detailsEditNameTooltip,
                    hintText: l10n.nameHintExample,
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.validationNameRequired : null,
                ),
                AppSpacing.gapX3l,

                // ── IP ───────────────────────────────────────────────────
                TextFormField(
                  controller: _ipCtrl,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.smartPlugInfoLocalIp,
                    hintText: l10n.ipLocalHint,
                    suffixIcon: _testing
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _testResult == null
                            ? null
                            : Icon(
                                _testResult!
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                                color: _testResult!
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.validationIpRequired;
                    if (!Validators.isValidIpv4(v.trim())) return l10n.validationIpInvalidFormat;
                    return null;
                  },
                ),
                AppSpacing.gapX3l,

                // ── Model ────────────────────────────────────────────────
                TextFormField(
                  controller: _modelCtrl,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    fontFamily: 'ShareTech',
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.addDeviceModelOptionalLabel,
                    hintText: l10n.cobLedCctDeviceHint,
                  ),
                ),
                AppSpacing.gapX3l,

                // ── Room picker ──────────────────────────────────────────
                _RoomDropdown(
                  rooms: rooms,
                  selectedRoomId: _selectedRoomId,
                  onChanged: (id) => setState(() => _selectedRoomId = id),
                ),
                AppSpacing.gapX3l,

                // ── Favourite ────────────────────────────────────────────
                Row(
                  children: [
                    Text(
                      l10n.addDeviceAddToFavorites,
                      style: const TextStyle(
                        fontFamily: 'ShareTech',
                        fontSize: AppFontSizes.body,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isFavorite,
                      onChanged: (v) => setState(() => _isFavorite = v),
                      activeThumbColor: const Color(0xFFE8C46A),
                    ),
                  ],
                ),
                AppSpacing.gapX3l,

                // ── Buttons ──────────────────────────────────────────────
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _testing ? null : _testConnection,
                      icon: const Icon(Icons.wifi_tethering_rounded, size: 16),
                      label: Text(l10n.test),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    AppSpacing.gapHX3l,
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(l10n.save),
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapMd,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Room dropdown ─────────────────────────────────────────────────────────────

class _RoomDropdown extends StatelessWidget {
  final List<Room> rooms;
  final String? selectedRoomId;
  final ValueChanged<String?> onChanged;

  const _RoomDropdown({
    required this.rooms,
    required this.selectedRoomId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: selectedRoomId,
      dropdownColor: AppColors.surface,
      style: const TextStyle(
        fontFamily: 'ShareTech',
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: context.l10n.addDeviceRoomOptionalLabel,
      ),
      items: [
        DropdownMenuItem<String?>(
          value: null,
          child: Text(context.l10n.none),
        ),
        ...rooms.map(
          (r) => DropdownMenuItem<String?>(
            value: r.id,
            child: Text(r.name),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
