/// A WLED-powered LED strip/light device stored locally.
class WledDevice {
  final String id;
  final String name;
  final String ipAddress;
  final String? roomId;
  final bool isFavorite;
  final String modelName;

  const WledDevice({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.roomId,
    this.isFavorite = false,
    this.modelName = '',
  });

  WledDevice copyWith({
    String? id,
    String? name,
    String? ipAddress,
    String? roomId,
    bool? isFavorite,
    String? modelName,
    bool clearRoomId = false,
  }) {
    return WledDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      roomId: clearRoomId ? null : (roomId ?? this.roomId),
      isFavorite: isFavorite ?? this.isFavorite,
      modelName: modelName ?? this.modelName,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'ipAddress': ipAddress,
        'roomId': roomId,
        'isFavorite': isFavorite,
        'modelName': modelName,
      };

  factory WledDevice.fromMap(Map<String, dynamic> map) => WledDevice(
        id: map['id'] as String,
        name: map['name'] as String,
        ipAddress: map['ipAddress'] as String,
        roomId: map['roomId'] as String?,
        isFavorite: (map['isFavorite'] as bool?) ?? false,
        modelName: (map['modelName'] as String?) ?? '',
      );
}
