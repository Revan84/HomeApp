import '../models/equipment.dart';

abstract class EquipmentRepository {
  Future<List<Equipment>> loadAll();
  Future<void> saveAll(List<Equipment> items);
  Future<void> add(Equipment equipment);
  Future<void> update(Equipment equipment);
  Future<void> deleteById(String id);
}
