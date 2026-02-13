import '../../features/home/model/room.dart';

abstract class RoomRepository {
  Future<List<Room>> loadAll();
  Future<void> saveAll(List<Room> rooms);
  Future<Room> add(String name);
}
