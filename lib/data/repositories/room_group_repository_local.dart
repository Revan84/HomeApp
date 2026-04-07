import 'dart:convert';
import 'dart:developer' as dev;

import '../../core/storage/local_storage.dart';
import '../../core/storage/storage_keys.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/entities/room_group.dart';
import '../../domain/repositories/room_group_repository.dart';
import '../dto/room_group_dto.dart';
import '../mappers/room_group_mapper.dart';

class RoomGroupRepositoryLocal implements RoomGroupRepository {
  final LocalStorage _storage;
  final IdGenerator _idGenerator;

  RoomGroupRepositoryLocal(this._storage, {IdGenerator? idGenerator})
      : _idGenerator = idGenerator ?? const TimestampIdGenerator();

  @override
  Future<List<RoomGroup>> loadAll() async {
    final raw = await _storage.getString(StorageKeys.roomGroups);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => RoomGroupMapper.toDomain(
                RoomGroupDto.fromMap(e as Map<String, dynamic>),
              ))
          .toList();
    } on FormatException catch (e, st) {
      dev.log('Failed to parse room groups', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<void> saveAll(List<RoomGroup> items) async {
    final json = jsonEncode(
      items.map((g) => RoomGroupMapper.fromDomain(g).toMap()).toList(),
    );
    await _storage.setString(StorageKeys.roomGroups, json);
  }

  @override
  Future<RoomGroup> add(String name) async {
    final all = await loadAll();
    final maxSort = all.isEmpty
        ? 0
        : all.map((g) => g.sortOrder).reduce((a, b) => a > b ? a : b);

    final group = RoomGroup(
      id: _idGenerator.generate(),
      name: name.trim(),
      sortOrder: maxSort + 1,
    );
    all.add(group);
    await saveAll(all);
    return group;
  }

  @override
  Future<void> update(RoomGroup group) async {
    final all = await loadAll();
    final index = all.indexWhere((g) => g.id == group.id);
    if (index == -1) return;
    all[index] = group;
    await saveAll(all);
  }

  @override
  Future<void> deleteById(String id) async {
    final all = await loadAll();
    all.removeWhere((g) => g.id == id);
    await saveAll(all);
  }
}
