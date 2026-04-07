import 'dart:convert';
import 'dart:developer' as dev;

import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../data/dto/wled_device_dto.dart';
import '../../../../data/mappers/wled_device_mapper.dart';
import '../../../../domain/entities/wled_device.dart';
import '../../../../domain/repositories/wled_repository.dart';

class WledLocalRepository implements WledRepository {
  final LocalStorage _storage;
  final IdGenerator _idGenerator;

  WledLocalRepository(this._storage, {IdGenerator? idGenerator})
      : _idGenerator = idGenerator ?? const TimestampIdGenerator();

  @override
  Future<List<WledDevice>> loadAll() async {
    final raw = await _storage.getString(StorageKeys.wledDevices);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => WledDeviceMapper.toDomain(
                WledDeviceDto.fromMap(e as Map<String, dynamic>),
              ))
          .toList();
    } on FormatException catch (e, st) {
      dev.log('Failed to parse WLED devices', error: e, stackTrace: st);
      return [];
    }
  }

  Future<void> _saveAll(List<WledDevice> items) async {
    final json = jsonEncode(
      items.map((d) => WledDeviceMapper.fromDomain(d).toMap()).toList(),
    );
    await _storage.setString(StorageKeys.wledDevices, json);
  }

  @override
  Future<WledDevice?> loadById(String id) async {
    final all = await loadAll();
    final matches = all.where((d) => d.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<void> add(WledDevice device) async {
    final all = await loadAll();
    final withId = device.copyWith(
      id: device.id.isEmpty ? _idGenerator.generate() : null,
    );
    all.add(withId);
    await _saveAll(all);
  }

  @override
  Future<void> update(WledDevice device) async {
    final all = await loadAll();
    final index = all.indexWhere((d) => d.id == device.id);
    if (index == -1) return;
    all[index] = device;
    await _saveAll(all);
  }

  @override
  Future<void> deleteById(String id) async {
    final all = await loadAll();
    all.removeWhere((d) => d.id == id);
    await _saveAll(all);
  }
}
