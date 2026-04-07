import 'dart:convert';

/// Storage/transport shape for [Equipment].
/// Contains only field declarations and Map/JSON conversion.
/// All domain mapping is handled by [EquipmentMapper].
class EquipmentDto {
  final String id;
  final String name;
  final String ip;
  final String type;
  final String? roomId;
  final bool isFavorite;
  final bool showToggle;
  final bool showPower;
  final bool showEnergy;
  final bool showRssi;
  final int channel;

  const EquipmentDto({
    required this.id,
    required this.name,
    required this.ip,
    required this.type,
    this.roomId,
    this.isFavorite = false,
    this.showToggle = true,
    this.showPower = true,
    this.showEnergy = false,
    this.showRssi = false,
    this.channel = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'ip': ip,
        'type': type,
        'showToggle': showToggle,
        'showPower': showPower,
        'showEnergy': showEnergy,
        'showRssi': showRssi,
        'roomId': roomId,
        'isFavorite': isFavorite,
        'channel': channel,
      };

  factory EquipmentDto.fromMap(Map<String, dynamic> m) => EquipmentDto(
        id: (m['id'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        ip: (m['ip'] ?? '') as String,
        type: (m['type'] ?? 'other') as String,
        showToggle: (m['showToggle'] ?? true) as bool,
        showPower: (m['showPower'] ?? true) as bool,
        showEnergy: (m['showEnergy'] ?? false) as bool,
        showRssi: (m['showRssi'] ?? false) as bool,
        roomId: m['roomId'] as String?,
        isFavorite: (m['isFavorite'] ?? false) as bool,
        channel: _parseChannel(m['channel']),
      );

  String toJson() => jsonEncode(toMap());

  factory EquipmentDto.fromJson(String s) =>
      EquipmentDto.fromMap(jsonDecode(s) as Map<String, dynamic>);

  static int _parseChannel(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
