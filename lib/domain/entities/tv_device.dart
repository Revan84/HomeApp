class TvDevice {
  final String id;
  final String name;
  final String ipAddress;
  final String? roomId;
  final bool isFavorite;
  final String modelName;
  final String source;

  /// Samsung pairing token — persisted so the TV doesn't ask for
  /// authorization on every reconnect.
  final String? wsToken;

  const TvDevice({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.roomId,
    this.isFavorite = false,
    this.modelName = '',
    this.source = 'HDMI 1',
    this.wsToken,
  });

  TvDevice copyWith({
    String? id,
    String? name,
    String? ipAddress,
    String? roomId,
    bool? isFavorite,
    String? modelName,
    String? source,
    String? wsToken,
    bool clearRoomId = false,
  }) {
    return TvDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      roomId: clearRoomId ? null : (roomId ?? this.roomId),
      isFavorite: isFavorite ?? this.isFavorite,
      modelName: modelName ?? this.modelName,
      source: source ?? this.source,
      wsToken: wsToken ?? this.wsToken,
    );
  }
}
