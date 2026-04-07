import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../domain/entities/wled_device.dart';
import '../../equipments/controllers/equipments_controller.dart';

class AddWledSheet extends StatefulWidget {
  const AddWledSheet({super.key});

  @override
  State<AddWledSheet> createState() => _AddWledSheetState();
}

class _AddWledSheetState extends State<AddWledSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ipCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();

  String? _selectedRoomId;
  bool _isFavorite = false;

  bool _testing = false;
  bool _testOk = false;
  String? _testError;

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
    final reg = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!reg.hasMatch(s)) return context.l10n.validationIpInvalidFormat;
    final parts = s.split('.').map(int.parse).toList();
    if (parts.any((p) => p < 0 || p > 255)) {
      return context.l10n.validationIpInvalid;
    }
    return null;
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<EquipmentsController>();
    setState(() { _testing = true; _testOk = false; _testError = null; });
    try {
      final ok = await controller.testWledConnection(_ipCtrl.text.trim());
      if (!mounted) return;
      setState(() {
        _testOk = ok;
        if (!ok) _testError = context.l10n.wledTestFailed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _testError = context.l10n.wledTestFailed);
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<EquipmentsController>();
    final device = WledDevice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim().isEmpty
          ? context.l10n.wledDefaultName
          : _nameCtrl.text.trim(),
      ipAddress: _ipCtrl.text.trim(),
      roomId: _selectedRoomId,
      isFavorite: _isFavorite,
      modelName: _modelCtrl.text.trim(),
    );
    await controller.addWledDevice(device);
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              // Title row
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.wledAddTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                    tooltip: l.close,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: l.nameLabel,
                        hintText: l.wledNameHint,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _ipCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l.ipLocalLabel,
                        hintText: l.ipLocalHint,
                      ),
                      validator: _validateIp,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _modelCtrl,
                      decoration: InputDecoration(
                        labelText: l.tvModelLabel,
                        hintText: l.wledModelHint,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Room dropdown
                    DropdownButtonFormField<String?>(
                      initialValue: _selectedRoomId,
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

                    const SizedBox(height: 8),

                    if (_testError != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _testError!,
                          style:
                              const TextStyle(color: Colors.redAccent),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _testing ? null : _testConnection,
                            icon: _testing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Icon(_testOk
                                    ? Icons.check
                                    : Icons.wifi_tethering),
                            label: Text(_testOk ? l.testOk : l.test),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.save),
                            label: Text(l.save),
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
