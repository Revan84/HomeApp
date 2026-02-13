import 'package:flutter/material.dart';
import 'package:front_end/core/i18n/loc.dart';
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
      case EquipmentType.other:
        return context.l10n.equipmentTypeOther;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.initial.copyWith(
      name: _nameCtrl.text.trim().isEmpty ? context.l10n.defaultEquipmentName : _nameCtrl.text.trim(),
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
    final safeRoomId = (_selectedRoomId != null && roomIds.contains(_selectedRoomId)) ? _selectedRoomId : null;

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
                    Expanded(
                      child: Text(
                        context.l10n.editEquipmentTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close),
                      tooltip: context.l10n.close,
                    ),
                  ],
                ),

                TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(labelText: context.l10n.nameLabel),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _ipCtrl,
                  decoration: InputDecoration(labelText: context.l10n.ipLocalLabel),
                  keyboardType: TextInputType.number,
                  validator: _validateIp,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  initialValue: _channel.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: context.l10n.channelLabel,
                    hintText: context.l10n.channelHint,
                  ),
                  validator: _validateChannel,
                  onChanged: (v) => _channel = int.tryParse(v.trim()) ?? _channel,
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<EquipmentType>(
                  initialValue: _type,
                  decoration: InputDecoration(labelText: context.l10n.typeLabel),
                  items: EquipmentType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(_typeLabel(context, t)),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _type = v ?? EquipmentType.other),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String?>(
                  initialValue: safeRoomId,
                  decoration: InputDecoration(labelText: context.l10n.roomLabel),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(context.l10n.none),
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
                  title: Text(context.l10n.favorite),
                ),

                const SizedBox(height: 8),

                SwitchListTile(
                  value: _showToggle,
                  onChanged: (v) => setState(() => _showToggle = v),
                  title: Text(context.l10n.showOnOff),
                ),
                SwitchListTile(
                  value: _showPower,
                  onChanged: (v) => setState(() => _showPower = v),
                  title: Text(context.l10n.showPower),
                ),
                SwitchListTile(
                  value: _showEnergy,
                  onChanged: (v) => setState(() => _showEnergy = v),
                  title: Text(context.l10n.showEnergy),
                ),
                SwitchListTile(
                  value: _showRssi,
                  onChanged: (v) => setState(() => _showRssi = v),
                  title: Text(context.l10n.showRssi),
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: Text(context.l10n.save),
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
