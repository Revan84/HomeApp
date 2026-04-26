import '../entities/cob_led_cct_device.dart';

/// Repository interface for persisting and retrieving [CobLedCctDevice] records.
abstract interface class CobLedCctRepository {
  Future<List<CobLedCctDevice>> loadAll();
  Future<void> add(CobLedCctDevice device);
  Future<void> update(CobLedCctDevice device);
  Future<void> deleteById(String id);
  Future<CobLedCctDevice?> loadById(String id);
}
