import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../home/model/room.dart';
import '../model/equipment.dart';

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

  List<Room> _rooms = [];
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

    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final rooms = await context.read<RoomRepository>().loadAll();
    if (!mounted) return;

    final byId = <String, Room>{};
    for (final r in rooms) {
      byId[r.id] = r;
    }
    final uniqueRooms = byId.values.toList();

    final selected = _selectedRoomId;
    final exists = selected != null && byId.containsKey(selected);

    setState(() {
      _rooms = uniqueRooms;
      if (!exists) _selectedRoomId = null;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ipCtrl.dispose();
    super.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.initial.copyWith(
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

    await context.read<EquipmentRepository>().update(updated);

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final roomIds = _rooms.map((r) => r.id).toSet();
    final safeRoomId =
        (_selectedRoomId != null && roomIds.contains(_selectedRoomId))
        ? _selectedRoomId
        : null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Modifier l’équipement",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: "Nom"),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ipCtrl,
                  decoration: const InputDecoration(labelText: "IP"),
                  keyboardType: TextInputType.number,
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
                  onChanged: (v) =>
                      _channel = int.tryParse(v.trim()) ?? _channel,
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

                const SizedBox(height: 10),

                DropdownButtonFormField<String?>(
                  initialValue: safeRoomId,
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

                const SizedBox(height: 8),

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
                  title: const Text("Énergie"),
                ),
                SwitchListTile(
                  value: _showRssi,
                  onChanged: (v) => setState(() => _showRssi = v),
                  title: const Text("RSSI"),
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text("Sauvegarder"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
