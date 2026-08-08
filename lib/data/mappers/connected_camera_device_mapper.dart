import '../../domain/entities/connected_camera_device.dart';
import '../dto/connected_camera_device_dto.dart';

/// Maps between [ConnectedCameraDeviceDto] and [ConnectedCameraDevice].
class ConnectedCameraDeviceMapper {
  ConnectedCameraDeviceMapper._();

  static ConnectedCameraDevice toDomain(ConnectedCameraDeviceDto dto) =>
      ConnectedCameraDevice(
        id: dto.id,
        name: dto.name,
        ipAddress: dto.ipAddress,
        roomId: dto.roomId,
        isFavorite: dto.isFavorite,
        modelName: dto.modelName,
        firmwareVersion: dto.firmwareVersion,
        brand: dto.brand,
        capabilities: dto.capabilities,
        cameraAccountUser: dto.cameraAccountUser,
        cameraAccountPassword: dto.cameraAccountPassword,
        rtspPort: dto.rtspPort,
        httpApiPort: dto.httpApiPort,
        onvifPort: dto.onvifPort,
        privacyModeEnabled: dto.privacyModeEnabled,
      );

  static ConnectedCameraDeviceDto fromDomain(ConnectedCameraDevice d) =>
      ConnectedCameraDeviceDto(
        id: d.id,
        name: d.name,
        ipAddress: d.ipAddress,
        roomId: d.roomId,
        isFavorite: d.isFavorite,
        modelName: d.modelName,
        firmwareVersion: d.firmwareVersion,
        brand: d.brand,
        capabilities: d.capabilities,
        cameraAccountUser: d.cameraAccountUser,
        cameraAccountPassword: d.cameraAccountPassword,
        rtspPort: d.rtspPort,
        httpApiPort: d.httpApiPort,
        onvifPort: d.onvifPort,
        privacyModeEnabled: d.privacyModeEnabled,
      );
}
