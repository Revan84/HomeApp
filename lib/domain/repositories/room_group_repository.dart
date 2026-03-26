import '../models/room_group.dart';

abstract class RoomGroupRepository {
  Future<List<RoomGroup>> loadAll();

  Future<void> saveAll(List<RoomGroup> groups);

  Future<RoomGroup> add(String name);

  Future<void> update(RoomGroup group);

  Future<void> deleteById(String id);
}
