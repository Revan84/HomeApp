import '../../domain/entities/wled_device.dart';
import '../dto/wled_device_dto.dart';

/// Maps between [WledDeviceDto] and [WledDevice].
class WledDeviceMapper {
  WledDeviceMapper._();

  static WledDevice toDomain(WledDeviceDto dto) => WledDevice(
        id: dto.id,
        name: dto.name,
        ipAddress: dto.ipAddress,
        roomId: dto.roomId,
        isFavorite: dto.isFavorite,
        modelName: dto.modelName,
      );

  static WledDeviceDto fromDomain(WledDevice d) => WledDeviceDto(
        id: d.id,
        name: d.name,
        ipAddress: d.ipAddress,
        roomId: d.roomId,
        isFavorite: d.isFavorite,
        modelName: d.modelName,
      );
}
