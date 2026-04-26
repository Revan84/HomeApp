import 'dart:convert';

/// Storage/transport shape for [CobLedCctDevice].
///
/// Contains only field declarations and Map/JSON conversion.
/// All domain mapping is handled by [CobLedCctDeviceMapper].
class CobLedCctDeviceDto {
  final String id;
  final String name;
  final String ipAddress;
  final String? roomId;
  final bool isFavorite;
  final String modelName;
  final List<Map<String, dynamic>> scenes;
  final String activeSceneId;

  const CobLedCctDeviceDto({
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

  factory CobLedCctDeviceDto.fromMap(Map<String, dynamic> m) =>
      CobLedCctDeviceDto(
        id: (m['id'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        ipAddress: (m['ipAddress'] ?? '') as String,
        roomId: m['roomId'] as String?,
        isFavorite: (m['isFavorite'] as bool?) ?? false,
        modelName: (m['modelName'] as String?) ?? '',
        scenes: ((m['scenes'] as List<dynamic>?) ?? [])
            .cast<Map<String, dynamic>>(),
        activeSceneId: (m['activeSceneId'] as String?) ?? '',
      );

  String toJson() => jsonEncode(toMap());

  factory CobLedCctDeviceDto.fromJson(String s) =>
      CobLedCctDeviceDto.fromMap(jsonDecode(s) as Map<String, dynamic>);
}
