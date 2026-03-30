import 'dart:convert';

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
  }) {
    return TvDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      roomId: roomId ?? this.roomId,
      isFavorite: isFavorite ?? this.isFavorite,
      modelName: modelName ?? this.modelName,
      source: source ?? this.source,
      wsToken: wsToken ?? this.wsToken,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'ipAddress': ipAddress,
        'roomId': roomId,
        'isFavorite': isFavorite,
        'modelName': modelName,
        'source': source,
        'wsToken': wsToken,
      };

  static TvDevice fromMap(Map<String, dynamic> m) => TvDevice(
        id: (m['id'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        ipAddress: (m['ipAddress'] ?? '') as String,
        roomId: m['roomId'] as String?,
        isFavorite: (m['isFavorite'] ?? false) as bool,
        modelName: (m['modelName'] ?? '') as String,
        source: (m['source'] ?? 'HDMI 1') as String,
        wsToken: m['wsToken'] as String?,
      );

  String toJson() => jsonEncode(toMap());

  static TvDevice fromJson(String s) =>
      fromMap(jsonDecode(s) as Map<String, dynamic>);
}
