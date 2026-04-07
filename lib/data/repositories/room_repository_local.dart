import 'dart:convert';
import 'dart:developer' as dev;

import '../../core/storage/local_storage.dart';
import '../../core/storage/storage_keys.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/room_repository.dart';
import '../dto/room_dto.dart';
import '../mappers/room_mapper.dart';

class RoomRepositoryLocal implements RoomRepository {
  static const _fallbackGroupId = 'default_room_group';

  final LocalStorage _storage;
  final IdGenerator _idGenerator;

  RoomRepositoryLocal(this._storage, {IdGenerator? idGenerator})
      : _idGenerator = idGenerator ?? const TimestampIdGenerator();

  @override
  Future<List<Room>> loadAll() async {
    final raw = await _storage.getString(StorageKeys.rooms);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => RoomMapper.toDomain(
                RoomDto.fromMap(
                  e as Map<String, dynamic>,
                  fallbackGroupId: _fallbackGroupId,
                ),
              ))
          .toList();
    } on FormatException catch (e, st) {
      dev.log('Failed to parse rooms', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<void> saveAll(List<Room> items) async {
    final json = jsonEncode(
      items.map((r) => RoomMapper.fromDomain(r).toMap()).toList(),
    );
    await _storage.setString(StorageKeys.rooms, json);
  }

  @override
  Future<Room> add({required String name, required String groupId}) async {
    final all = await loadAll();
    final maxSort = all.isEmpty
        ? 0
        : all.map((r) => r.sortOrder).reduce((a, b) => a > b ? a : b);

    final room = Room(
      id: _idGenerator.generate(),
      name: name.trim(),
      groupId: groupId,
      sortOrder: maxSort + 1,
    );
    all.add(room);
    await saveAll(all);
    return room;
  }

  @override
  Future<void> update(Room room) async {
    final all = await loadAll();
    final index = all.indexWhere((r) => r.id == room.id);
    if (index == -1) return;
    all[index] = room;
    await saveAll(all);
  }

  @override
  Future<void> deleteById(String id) async {
    final all = await loadAll();
    all.removeWhere((r) => r.id == id);
    await saveAll(all);
  }
}
