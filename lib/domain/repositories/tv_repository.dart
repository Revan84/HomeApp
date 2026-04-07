import '../entities/tv_device.dart';

abstract class TvRepository {
  Future<List<TvDevice>> loadAll();
  Future<TvDevice?> loadById(String id);
  Future<void> add(TvDevice device);
  Future<void> update(TvDevice device);
  Future<void> deleteById(String id);
}
