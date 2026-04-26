import '../../domain/entities/cct_scene.dart';
import '../../domain/entities/cob_led_cct_device.dart';
import '../dto/cob_led_cct_device_dto.dart';

/// Maps between [CobLedCctDeviceDto] and [CobLedCctDevice].
class CobLedCctDeviceMapper {
  CobLedCctDeviceMapper._();

  static CobLedCctDevice toDomain(CobLedCctDeviceDto dto) => CobLedCctDevice(
        id: dto.id,
        name: dto.name,
        ipAddress: dto.ipAddress,
        roomId: dto.roomId,
        isFavorite: dto.isFavorite,
        modelName: dto.modelName,
        scenes: dto.scenes.map(CctScene.fromMap).toList(),
        activeSceneId: dto.activeSceneId,
      );

  static CobLedCctDeviceDto fromDomain(CobLedCctDevice d) =>
      CobLedCctDeviceDto(
        id: d.id,
        name: d.name,
        ipAddress: d.ipAddress,
        roomId: d.roomId,
        isFavorite: d.isFavorite,
        modelName: d.modelName,
        scenes: d.scenes.map((s) => s.toMap()).toList(),
        activeSceneId: d.activeSceneId,
      );
}
