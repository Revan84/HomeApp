import '../../domain/entities/cob_led_rgb_device.dart';
import '../../domain/entities/rgb_scene.dart';
import '../dto/cob_led_rgb_device_dto.dart';

/// Maps between [CobLedRgbDeviceDto] and [CobLedRgbDevice].
class CobLedRgbDeviceMapper {
  CobLedRgbDeviceMapper._();

  static CobLedRgbDevice toDomain(CobLedRgbDeviceDto dto) => CobLedRgbDevice(
        id: dto.id,
        name: dto.name,
        ipAddress: dto.ipAddress,
        roomId: dto.roomId,
        isFavorite: dto.isFavorite,
        modelName: dto.modelName,
        scenes: dto.scenes.map(RgbScene.fromMap).toList(),
        activeSceneId: dto.activeSceneId,
      );

  static CobLedRgbDeviceDto fromDomain(CobLedRgbDevice d) =>
      CobLedRgbDeviceDto(
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
