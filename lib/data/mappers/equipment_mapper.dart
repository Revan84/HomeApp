import '../../domain/entities/device_endpoint.dart';
import '../../domain/entities/equipment.dart';
import '../dto/equipment_dto.dart';

/// Maps between [EquipmentDto] and [Equipment].
///
/// Also provides [EquipmentEndpointX] for projecting an [Equipment]
/// into a [DeviceEndpoint] used by the live-polling layer.
class EquipmentMapper {
  EquipmentMapper._();

  static Equipment toDomain(EquipmentDto dto) => Equipment(
        id: dto.id,
        name: dto.name,
        ip: dto.ip,
        type: _typeFromString(dto.type),
        roomId: dto.roomId,
        isFavorite: dto.isFavorite,
        showToggle: dto.showToggle,
        showPower: dto.showPower,
        showEnergy: dto.showEnergy,
        showRssi: dto.showRssi,
        channel: dto.channel,
      );

  static EquipmentDto fromDomain(Equipment e) => EquipmentDto(
        id: e.id,
        name: e.name,
        ip: e.ip,
        type: e.type.name,
        roomId: e.roomId,
        isFavorite: e.isFavorite,
        showToggle: e.showToggle,
        showPower: e.showPower,
        showEnergy: e.showEnergy,
        showRssi: e.showRssi,
        channel: e.channel,
      );

  static EquipmentType _typeFromString(String v) =>
      EquipmentType.values.firstWhere(
        (e) => e.name == v,
        orElse: () => EquipmentType.other,
      );
}

/// Projects an [Equipment] to the [DeviceEndpoint] shape consumed by the
/// live-polling layer.  Defined here (data/mapper) so the domain entity
/// itself has no knowledge of live-polling infrastructure.
extension EquipmentEndpointX on Equipment {
  DeviceEndpoint toEndpoint() =>
      DeviceEndpoint(deviceId: id, ip: ip, channel: channel);
}
