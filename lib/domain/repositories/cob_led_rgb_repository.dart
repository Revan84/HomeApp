import '../entities/cob_led_rgb_device.dart';

abstract class CobLedRgbRepository {
  Future<List<CobLedRgbDevice>> loadAll();
  Future<CobLedRgbDevice?> loadById(String id);
  Future<void> add(CobLedRgbDevice device);
  Future<void> update(CobLedRgbDevice device);
  Future<void> deleteById(String id);
}
