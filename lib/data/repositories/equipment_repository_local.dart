import 'dart:convert';
import 'dart:developer' as dev;

import '../../core/storage/local_storage.dart';
import '../../core/storage/storage_keys.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../dto/equipment_dto.dart';
import '../mappers/equipment_mapper.dart';

class EquipmentRepositoryLocal implements EquipmentRepository {
  final LocalStorage _storage;
  final IdGenerator _idGenerator;

  EquipmentRepositoryLocal(this._storage, {IdGenerator? idGenerator})
      : _idGenerator = idGenerator ?? const TimestampIdGenerator();

  @override
  Future<List<Equipment>> loadAll() async {
    final raw = await _storage.getString(StorageKeys.equipments);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => EquipmentMapper.toDomain(
                EquipmentDto.fromMap(e as Map<String, dynamic>),
              ))
          .toList();
    } on FormatException catch (e, st) {
      dev.log('Failed to parse equipments', error: e, stackTrace: st);
      return [];
    }
  }

  @override
  Future<void> saveAll(List<Equipment> items) async {
    final json = jsonEncode(
      items.map((e) => EquipmentMapper.fromDomain(e).toMap()).toList(),
    );
    await _storage.setString(StorageKeys.equipments, json);
  }

  @override
  Future<void> add(Equipment equipment) async {
    final all = await loadAll();
    final withId = equipment.copyWith(
      id: equipment.id.isEmpty ? _idGenerator.generate() : null,
    );
    all.add(withId);
    await saveAll(all);
  }

  @override
  Future<void> update(Equipment equipment) async {
    final all = await loadAll();
    final index = all.indexWhere((e) => e.id == equipment.id);
    if (index == -1) return;
    all[index] = equipment;
    await saveAll(all);
  }

  @override
  Future<void> deleteById(String id) async {
    final all = await loadAll();
    all.removeWhere((e) => e.id == id);
    await saveAll(all);
  }
}
