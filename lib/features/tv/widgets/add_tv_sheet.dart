import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/i18n/loc.dart';
import '../../../domain/models/room.dart';
import '../../../domain/models/tv_device.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/tv_repository.dart';
import '../../integrations/samsung/data/samsung_ws_client.dart';

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

  List<Room> _rooms = [];
  String? _selectedRoomId;
  bool _isFavorite = false;

  bool _testing = false;
  bool _testOk = false;
  String? _testError;
  String? _pairedToken;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ipCtrl.dispose();
    _modelCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    final rooms = await context.read<RoomRepository>().loadAll();
    if (!mounted) return;
    setState(() => _rooms = rooms);
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

  /// Tests WebSocket connection to the TV.
  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _testing = true;
      _testOk = false;
      _testError = null;
    });

    final ip = _ipCtrl.text.trim();
    final client = SamsungWsClient();

    // Listen for the pairing token during the test connection
    final tokenSub = client.onTokenReceived.listen((token) {
      _pairedToken = token;
    });

    try {
      final ok = await client.connect(ip);
      // Wait briefly so the TV has time to send the token
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      _pairedToken ??= client.token;
      setState(() {
        _testOk = ok;
        if (!ok) _testError = context.l10n.tvTestFailed;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _testError = context.l10n.tvTestFailed);
    } finally {
      await tokenSub.cancel();
      await client.disconnect();
      client.dispose();
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

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

    await context.read<TvRepository>().add(device);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
                  Expanded(
                    child: Text(
                      l.tvAddTitle,
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
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: l.nameLabel,
                        hintText: l.tvNameHint,
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
                        hintText: l.tvModelHint,
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
                        ..._rooms.map(
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

                    const SizedBox(height: 10),

                    if (_testError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _testError!,
                            style: const TextStyle(color: Colors.red),
                          ),
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
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _testOk
                                        ? Icons.check
                                        : Icons.wifi_tethering,
                                  ),
                            label: Text(
                              _testOk ? l.testOk : l.test,
                            ),
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
