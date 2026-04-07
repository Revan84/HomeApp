enum EquipmentType { shellyPlusPlugS, shellyPlugS, other }

class Equipment {
  final String id;
  final String name;
  final String ip;
  final EquipmentType type;
  final String? roomId;
  final bool isFavorite;

  // Display toggle preferences
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
}
