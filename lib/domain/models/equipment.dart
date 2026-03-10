import 'dart:convert';

enum EquipmentType { shellyPlusPlugS, shellyPlugS, other }

EquipmentType equipmentTypeFromString(String v) {
  return EquipmentType.values.firstWhere(
    (e) => e.name == v,
    orElse: () => EquipmentType.other,
  );
}

class Equipment {
  final String id;
  final String name;
  final String ip;
  final EquipmentType type;
  final String? roomId;
  final bool isFavorite;

  // Toggles d’affichage
  final bool showToggle;
  final bool showPower;
  final bool showEnergy;
  final bool showRssi;

  final int channel;

  const Equipment({
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

  Equipment copyWith({
    String? id,
    String? name,
    String? ip,
    EquipmentType? type,
    String? roomId,
    bool? isFavorite,
    bool? showToggle,
    bool? showPower,
    bool? showEnergy,
    bool? showRssi,
    int? channel,
  }) {
    return Equipment(
      id: id ?? this.id,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      type: type ?? this.type,
      roomId: roomId ?? this.roomId,
      isFavorite: isFavorite ?? this.isFavorite,
      showToggle: showToggle ?? this.showToggle,
      showPower: showPower ?? this.showPower,
      showEnergy: showEnergy ?? this.showEnergy,
      showRssi: showRssi ?? this.showRssi,
      channel: channel ?? this.channel,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'ip': ip,
    'type': type.name,
    'showToggle': showToggle,
    'showPower': showPower,
    'showEnergy': showEnergy,
    'showRssi': showRssi,
    'roomId': roomId,
    'isFavorite': isFavorite,
    'channel': channel,
  };

  static Equipment fromMap(Map<String, dynamic> m) {
    int parseChannel(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return Equipment(
      id: (m['id'] ?? '') as String,
      name: (m['name'] ?? '') as String,
      ip: (m['ip'] ?? '') as String,
      type: equipmentTypeFromString((m['type'] ?? 'other') as String),
      showToggle: (m['showToggle'] ?? true) as bool,
      showPower: (m['showPower'] ?? true) as bool,
      showEnergy: (m['showEnergy'] ?? false) as bool,
      showRssi: (m['showRssi'] ?? false) as bool,
      roomId: m['roomId'] as String?,
      isFavorite: (m['isFavorite'] ?? false) as bool,

      channel: parseChannel(m['channel']),
    );
  }

  String toJson() => jsonEncode(toMap());

  static Equipment fromJson(String s) =>
      fromMap(jsonDecode(s) as Map<String, dynamic>);
}
