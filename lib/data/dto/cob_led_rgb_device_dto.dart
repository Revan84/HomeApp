import 'dart:convert';

/// Storage/transport shape for [CobLedRgbDevice].
/// Contains only field declarations and Map/JSON conversion.
/// All domain mapping is handled by [CobLedRgbDeviceMapper].
class CobLedRgbDeviceDto {
  final String id;
  final String name;
  final String ipAddress;
  final String? roomId;
  final bool isFavorite;
  final String modelName;
  final List<Map<String, dynamic>> scenes;
  final String activeSceneId;

  const CobLedRgbDeviceDto({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.roomId,
    this.isFavorite = false,
    this.modelName = '',
    this.scenes = const [],
    this.activeSceneId = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'ipAddress': ipAddress,
        'roomId': roomId,
        'isFavorite': isFavorite,
        'modelName': modelName,
        'scenes': scenes,
        'activeSceneId': activeSceneId,
      };

  factory CobLedRgbDeviceDto.fromMap(Map<String, dynamic> m) =>
      CobLedRgbDeviceDto(
        id: (m['id'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        ipAddress: (m['ipAddress'] ?? '') as String,
        roomId: m['roomId'] as String?,
        isFavorite: (m['isFavorite'] as bool?) ?? false,
        modelName: (m['modelName'] as String?) ?? '',
        scenes: (m['scenes'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>() ??
            const [],
        activeSceneId: (m['activeSceneId'] as String?) ?? '',
      );

  String toJson() => jsonEncode(toMap());

  factory CobLedRgbDeviceDto.fromJson(String s) =>
      CobLedRgbDeviceDto.fromMap(jsonDecode(s) as Map<String, dynamic>);
}
