import 'dart:convert';
import '../../../../core/storage/local_storage.dart';
import '../../../../domain/models/tv_device.dart';
import '../../../../domain/repositories/tv_repository.dart';

class SamsungTvRepository implements TvRepository {
  static const _key = 'tv_devices_v1';
  final LocalStorage _storage;

  SamsungTvRepository(this._storage);

  @override
  Future<List<TvDevice>> loadAll() async {
    final raw = await _storage.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(TvDevice.fromMap).toList();
  }

  Future<void> _saveAll(List<TvDevice> items) async {
    final raw = jsonEncode(items.map((e) => e.toMap()).toList());
    await _storage.setString(_key, raw);
  }

  @override
  Future<TvDevice?> loadById(String id) async {
    final items = await loadAll();
    for (final d in items) {
      if (d.id == id) return d;
    }
    return null;
  }

  @override
  Future<void> add(TvDevice device) async {
    final items = await loadAll();
    items.add(device);
    await _saveAll(items);
  }

  @override
  Future<void> update(TvDevice updated) async {
    final items = await loadAll();
    final idx = items.indexWhere((e) => e.id == updated.id);
    if (idx == -1) return;
    items[idx] = updated;
    await _saveAll(items);
  }

  @override
  Future<void> deleteById(String id) async {
    final items = await loadAll();
    items.removeWhere((e) => e.id == id);
    await _saveAll(items);
  }
}
