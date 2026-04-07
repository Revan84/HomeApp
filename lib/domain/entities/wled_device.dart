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
}
