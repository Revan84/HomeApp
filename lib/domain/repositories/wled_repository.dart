import '../entities/wled_device.dart';

abstract class WledRepository {
  Future<List<WledDevice>> loadAll();
  Future<WledDevice?> loadById(String id);
  Future<void> add(WledDevice device);
  Future<void> update(WledDevice device);
  Future<void> deleteById(String id);
}
