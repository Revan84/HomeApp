import 'dart:convert';

import '../../core/storage/local_storage.dart';
import '../../domain/models/room.dart';
import '../../domain/repositories/room_repository.dart';

class RoomRepositoryLocal implements RoomRepository {
  static const String _key = 'rooms_v1';

  /// Used to migrate old rooms that were stored before `groupId` existed.
  static const String _defaultFallbackGroupId = 'default_room_group';

  final LocalStorage _storage;

  RoomRepositoryLocal(this._storage);

  @override
  Future<List<Room>> loadAll() async {
    final raw = await _storage.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <Room>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;

    final rooms = decoded
        .whereType<Map<String, dynamic>>()
        .map(
          (map) => Room.fromMap(
            map,
            fallbackGroupId: _defaultFallbackGroupId,
          ),
        )
        .toList(growable: true);

    rooms.sort((a, b) {
      final groupComparison = a.groupId.compareTo(b.groupId);
      if (groupComparison != 0) return groupComparison;

      final sortComparison = a.sortOrder.compareTo(b.sortOrder);
      if (sortComparison != 0) return sortComparison;

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return rooms;
  }

  @override
  Future<void> saveAll(List<Room> rooms) async {
    final raw = jsonEncode(
      rooms.map((room) => room.toMap()).toList(growable: false),
    );

    await _storage.setString(_key, raw);
  }

  @override
  Future<Room> add({
    required String name,
    required String groupId,
  }) async {
    final rooms = await loadAll();

    final groupRooms = rooms.where((room) => room.groupId == groupId).toList();

    final nextRoom = Room(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      groupId: groupId,
      sortOrder: groupRooms.length,
    );

    rooms.add(nextRoom);
    await saveAll(rooms);

    return nextRoom;
  }

  @override
  Future<void> update(Room room) async {
    final rooms = await loadAll();
    final index = rooms.indexWhere((item) => item.id == room.id);
    if (index == -1) return;

    rooms[index] = room;
    await saveAll(rooms);
  }

  @override
  Future<void> deleteById(String id) async {
    final rooms = await loadAll();
    rooms.removeWhere((room) => room.id == id);
    await saveAll(rooms);
  }
}