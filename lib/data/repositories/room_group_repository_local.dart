import 'dart:convert';

import '../../core/storage/local_storage.dart';
import '../../domain/models/room_group.dart';
import '../../domain/repositories/room_group_repository.dart';

class RoomGroupRepositoryLocal implements RoomGroupRepository {
  static const String _key = 'room_groups_v1';

  final LocalStorage _storage;

  RoomGroupRepositoryLocal(this._storage);

  @override
  Future<List<RoomGroup>> loadAll() async {
    final raw = await _storage.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <RoomGroup>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;

    final groups = decoded
        .whereType<Map<String, dynamic>>()
        .map(RoomGroup.fromMap)
        .toList(growable: true);

    groups.sort((a, b) {
      final sortComparison = a.sortOrder.compareTo(b.sortOrder);
      if (sortComparison != 0) return sortComparison;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return groups;
  }

  @override
  Future<void> saveAll(List<RoomGroup> groups) async {
    final raw = jsonEncode(
      groups.map((group) => group.toMap()).toList(growable: false),
    );

    await _storage.setString(_key, raw);
  }

  @override
  Future<RoomGroup> add(String name) async {
    final groups = await loadAll();

    final nextGroup = RoomGroup(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      sortOrder: groups.length,
    );

    groups.add(nextGroup);
    await saveAll(groups);

    return nextGroup;
  }

  @override
  Future<void> update(RoomGroup group) async {
    final groups = await loadAll();
    final index = groups.indexWhere((item) => item.id == group.id);
    if (index == -1) return;

    groups[index] = group;
    await saveAll(groups);
  }

  @override
  Future<void> deleteById(String id) async {
    final groups = await loadAll();
    groups.removeWhere((group) => group.id == id);
    await saveAll(groups);
  }
}