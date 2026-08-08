import 'rgb_scene.dart';

/// A WLED-powered LED strip/light device stored locally.
class CobLedRgbDevice {
  final String id;
  final String name;
  final String ipAddress;
  final String? roomId;
  final bool isFavorite;
  final String modelName;
  final List<RgbScene> scenes;
  final String activeSceneId;

  const CobLedRgbDevice({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.roomId,
    this.isFavorite = false,
    this.modelName = '',
    this.scenes = const [],
    this.activeSceneId = '',
  });

  CobLedRgbDevice copyWith({
    String? id,
    String? name,
    String? ipAddress,
    String? roomId,
    bool? isFavorite,
    String? modelName,
    List<RgbScene>? scenes,
    String? activeSceneId,
    bool clearRoomId = false,
    bool clearActiveSceneId = false,
  }) {
    return CobLedRgbDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      roomId: clearRoomId ? null : (roomId ?? this.roomId),
      isFavorite: isFavorite ?? this.isFavorite,
      modelName: modelName ?? this.modelName,
      scenes: scenes ?? this.scenes,
      activeSceneId:
          clearActiveSceneId ? '' : (activeSceneId ?? this.activeSceneId),
    );
  }
}
