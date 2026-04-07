import '../../domain/entities/room.dart';
import '../dto/room_dto.dart';

/// Maps between [RoomDto] and [Room].
class RoomMapper {
  RoomMapper._();

  static Room toDomain(RoomDto dto) => Room(
        id: dto.id,
        name: dto.name,
        groupId: dto.groupId,
        sortOrder: dto.sortOrder,
      );

  static RoomDto fromDomain(Room r) => RoomDto(
        id: r.id,
        name: r.name,
        groupId: r.groupId,
        sortOrder: r.sortOrder,
      );
}
