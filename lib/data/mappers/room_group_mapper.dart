import '../../domain/entities/room_group.dart';
import '../dto/room_group_dto.dart';

/// Maps between [RoomGroupDto] and [RoomGroup].
class RoomGroupMapper {
  RoomGroupMapper._();

  static RoomGroup toDomain(RoomGroupDto dto) => RoomGroup(
        id: dto.id,
        name: dto.name,
        sortOrder: dto.sortOrder,
      );

  static RoomGroupDto fromDomain(RoomGroup g) => RoomGroupDto(
        id: g.id,
        name: g.name,
        sortOrder: g.sortOrder,
      );
}
