import 'cct_scene.dart';

/// Domain entity for a COB LED CCT (Correlated Colour Temperature) controller.
///
/// Represents a dimmable white-light LED controller reachable via HTTP.
/// [scenes] stores locally-created named presets (templates).
/// [activeSceneId] tracks which scene (if any) is currently applied.
class CobLedCctDevice {
  final String id;
  final String name;
  final String ipAddress;
  final String? roomId;
  final bool isFavorite;
  final String modelName;
  final List<CctScene> scenes;
  final String activeSceneId; // empty = no active scene

  const CobLedCctDevice({
    required this.id,
    required this.name,
    required this.ipAddress,
    this.roomId,
    this.isFavorite = false,
    this.modelName = '',
    this.scenes = const [],
    this.activeSceneId = '',
  });

  CobLedCctDevice copyWith({
    String? id,
    String? name,
    String? ipAddress,
    String? roomId,
    bool? isFavorite,
    String? modelName,
    List<CctScene>? scenes,
    String? activeSceneId,
    bool clearRoomId = false,
    bool clearActiveSceneId = false,
  }) {
    return CobLedCctDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      roomId: clearRoomId ? null : (roomId ?? this.roomId),
      isFavorite: isFavorite ?? this.isFavorite,
      modelName: modelName ?? this.modelName,
      scenes: scenes ?? this.scenes,
      activeSceneId: clearActiveSceneId ? '' : (activeSceneId ?? this.activeSceneId),
    );
  }
}
