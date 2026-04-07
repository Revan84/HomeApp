import '../../domain/entities/tv_device.dart';
import '../dto/tv_device_dto.dart';

/// Maps between [TvDeviceDto] and [TvDevice].
class TvDeviceMapper {
  TvDeviceMapper._();

  static TvDevice toDomain(TvDeviceDto dto) => TvDevice(
        id: dto.id,
        name: dto.name,
        ipAddress: dto.ipAddress,
        roomId: dto.roomId,
        isFavorite: dto.isFavorite,
        modelName: dto.modelName,
        source: dto.source,
        wsToken: dto.wsToken,
      );

  static TvDeviceDto fromDomain(TvDevice tv) => TvDeviceDto(
        id: tv.id,
        name: tv.name,
        ipAddress: tv.ipAddress,
        roomId: tv.roomId,
        isFavorite: tv.isFavorite,
        modelName: tv.modelName,
        source: tv.source,
        wsToken: tv.wsToken,
      );
}
