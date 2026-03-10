import 'dart:convert';
import '../../core/storage/local_storage.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/models/equipment.dart';

class EquipmentRepositoryLocal implements EquipmentRepository {
  static const _key = 'equipments_v1';
  final LocalStorage _storage;
  EquipmentRepositoryLocal(this._storage);

  @override
  Future<List<Equipment>> loadAll() async {
    final raw = await _storage.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Equipment.fromMap).toList();
  }

  @override
  Future<void> saveAll(List<Equipment> items) async {
    final raw = jsonEncode(items.map((e) => e.toMap()).toList());
    await _storage.setString(_key, raw);
  }

  @override
  Future<void> add(Equipment equipment) async {
    final items = await loadAll();
    items.add(equipment);
    await saveAll(items);
  }

  @override
  Future<void> update(Equipment updated) async {
    final items = await loadAll();
    final idx = items.indexWhere((e) => e.id == updated.id);
    if (idx == -1) return;
    items[idx] = updated;
    await saveAll(items);
  }

  @override
  Future<void> deleteById(String id) async {
    final items = await loadAll();
    items.removeWhere((e) => e.id == id);
    await saveAll(items);
  }
}
