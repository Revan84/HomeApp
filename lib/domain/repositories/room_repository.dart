import '../entities/room.dart';

abstract class RoomRepository {
  Future<List<Room>> loadAll();

  Future<void> saveAll(List<Room> rooms);

  Future<Room> add({required String name, required String groupId});

  Future<void> update(Room room);

  Future<void> deleteById(String id);
}
