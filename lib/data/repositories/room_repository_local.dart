import 'dart:convert';

import '../../core/storage/local_storage.dart';

import '../../domain/repositories/room_repository.dart';
import '../../domain/models/room.dart';

class RoomRepositoryLocal implements RoomRepository {
  static const _key = 'rooms_v1';
  final LocalStorage _storage;
  RoomRepositoryLocal(this._storage);

  @override
  Future<List<Room>> loadAll() async {
    final raw = await _storage.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Room.fromMap).toList();
  }

  @override
  Future<void> saveAll(List<Room> rooms) async {
    final raw = jsonEncode(rooms.map((r) => r.toMap()).toList());
    await _storage.setString(_key, raw);
  }

  @override
  Future<Room> add(String name) async {
    final rooms = await loadAll();
    final room = Room(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
    );
    rooms.add(room);
    await saveAll(rooms);
    return room;
  }
}
