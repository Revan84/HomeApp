import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../features/integrations/shelly/data/shelly_rpc_client.dart';
import '../../home/model/room.dart';
import '../model/equipment.dart';

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

  List<Room> _rooms = [];
  String? _selectedRoomId;
  bool _isFavorite = false;

  bool _testing = false;
  bool _testOk = false;
  String? _testError;
  Map<String, dynamic>? _deviceInfo;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    widget.roomsRefreshNotifier.addListener(_onRoomsRefresh);
  }

  void _onRoomsRefresh() => _loadRooms();

  @override
  void dispose() {
    widget.roomsRefreshNotifier.removeListener(_onRoomsRefresh);
    _nameCtrl.dispose();
    _ipCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    final rooms = await context.read<RoomRepository>().loadAll();
    if (!mounted) return;

    // déduplique par id (si storage foire)
    final byId = <String, Room>{};
    for (final r in rooms) {
      byId[r.id] = r;
    }

    setState(() => _rooms = byId.values.toList());
  }

  String? _validateIp(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return "IP requise";
    final reg = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!reg.hasMatch(s)) return "Format IP invalide";
    final parts = s.split('.').map(int.parse).toList();
    if (parts.any((p) => p < 0 || p > 255)) return "IP invalide";
    return null;
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _testing = true;
      _testOk = false;
      _testError = null;
      _deviceInfo = null;
    });

    final ip = _ipCtrl.text.trim();

    try {
      // on passe par le client Shelly injectable (clean)
      final rpc = context.read<ShellyRpcClient>();
      final data = await rpc.getDeviceInfo(ip);

      if (!mounted) return;
      setState(() {
        _testOk = true;
        _deviceInfo = data;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _testError = "Test KO: $e");
    } finally {
      if (mounted) {
        setState(() => _testing = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final eq = Equipment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim().isEmpty
          ? "Équipement"
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

    await context.read<EquipmentRepository>().add(eq);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Ajouter un équipement",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Nom",
                        hintText: "ex: Prise bureau",
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _ipCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "IP locale",
                        hintText: "ex: 192.168.1.37",
                      ),
                      validator: _validateIp,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: _channel.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Canal (channel)",
                        hintText: "0",
                      ),
                      validator: (v) {
                        final n = int.tryParse((v ?? '').trim());
                        if (n == null) return "Nombre invalide";
                        if (n < 0 || n > 3) return "Canal invalide";
                        return null;
                      },
                      onChanged: (v) => _channel = int.tryParse(v.trim()) ?? 0,
                    ),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<EquipmentType>(
                      initialValue: _type,
                      decoration: const InputDecoration(labelText: "Type"),
                      items: const [
                        DropdownMenuItem(
                          value: EquipmentType.shellyPlusPlugS,
                          child: Text("Prise connectée (Shelly Plus)"),
                        ),
                        DropdownMenuItem(
                          value: EquipmentType.other,
                          child: Text("Thermomètre (test)"),
                        ),
                        DropdownMenuItem(
                          value: EquipmentType.other,
                          child: Text("Hygromètre (test)"),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _type = v ?? EquipmentType.other),
                    ),

                    DropdownButtonFormField<String?>(
                      initialValue: _selectedRoomId,
                      decoration: const InputDecoration(labelText: "Pièce"),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text("Aucune"),
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
                      title: const Text("Favori"),
                    ),

                    const SizedBox(height: 14),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Données à afficher",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),

                    SwitchListTile(
                      value: _showToggle,
                      onChanged: (v) => setState(() => _showToggle = v),
                      title: const Text("On/Off"),
                    ),
                    SwitchListTile(
                      value: _showPower,
                      onChanged: (v) => setState(() => _showPower = v),
                      title: const Text("Puissance (W)"),
                    ),
                    SwitchListTile(
                      value: _showEnergy,
                      onChanged: (v) => setState(() => _showEnergy = v),
                      title: const Text("Énergie (Wh/kWh)"),
                    ),
                    SwitchListTile(
                      value: _showRssi,
                      onChanged: (v) => setState(() => _showRssi = v),
                      title: const Text("RSSI / Wi-Fi"),
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

                    if (_deviceInfo != null)
                      _DeviceInfoPreview(data: _deviceInfo!),

                    const SizedBox(height: 12),

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
                            label: Text(_testOk ? "Test OK" : "Tester"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.save),
                            label: const Text("Sauvegarder"),
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
  final Map<String, dynamic> data;
  const _DeviceInfoPreview({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name']?.toString() ?? '';
    final model = data['model']?.toString() ?? '';
    final mac = data['mac']?.toString() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Infos détectées",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          if (name.isNotEmpty) Text("Nom: $name"),
          if (model.isNotEmpty) Text("Modèle: $model"),
          if (mac.isNotEmpty) Text("MAC: $mac"),
        ],
      ),
    );
  }
}
