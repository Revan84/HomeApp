import 'dart:convert';

import '../../../../core/storage/local_storage.dart';
import '../../../../domain/models/wled_device.dart';
import '../../../../domain/repositories/wled_repository.dart';

class WledLocalRepository implements WledRepository {
  final LocalStorage _storage;
  static const _key = 'wled_devices_v1';

  WledLocalRepository(this._storage);

  Future<List<WledDevice>> _readAll() async {
    final raw = await _storage.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .map(WledDevice.fromMap)
        .toList();
  }

  Future<void> _writeAll(List<WledDevice> devices) async {
    await _storage.setString(
      _key,
      jsonEncode(devices.map((d) => d.toMap()).toList()),
    );
  }

  @override
  Future<List<WledDevice>> loadAll() => _readAll();

  @override
  Future<WledDevice?> loadById(String id) async {
    final all = await _readAll();
    return all.cast<WledDevice?>().firstWhere(
          (d) => d?.id == id,
          orElse: () => null,
        );
  }

  @override
  Future<void> add(WledDevice device) async {
    final all = await _readAll();
    all.add(device);
    await _writeAll(all);
  }

  @override
  Future<void> update(WledDevice device) async {
    final all = await _readAll();
    final idx = all.indexWhere((d) => d.id == device.id);
    if (idx != -1) all[idx] = device;
    await _writeAll(all);
  }

  @override
  Future<void> deleteById(String id) async {
    final all = await _readAll();
    all.removeWhere((d) => d.id == id);
    await _writeAll(all);
  }
}
