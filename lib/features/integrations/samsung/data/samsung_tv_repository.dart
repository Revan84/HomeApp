import 'dart:convert';
import 'dart:developer' as dev;

import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../data/dto/tv_device_dto.dart';
import '../../../../data/mappers/tv_device_mapper.dart';
import '../../../../domain/entities/tv_device.dart';
import '../../../../domain/repositories/tv_repository.dart';

class SamsungTvRepository implements TvRepository {
  final LocalStorage _storage;
  final IdGenerator _idGenerator;

  SamsungTvRepository(this._storage, {IdGenerator? idGenerator})
      : _idGenerator = idGenerator ?? const TimestampIdGenerator();

  @override
  Future<List<TvDevice>> loadAll() async {
    final raw = await _storage.getString(StorageKeys.tvDevices);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => TvDeviceMapper.toDomain(
                TvDeviceDto.fromMap(e as Map<String, dynamic>),
              ))
          .toList();
    } on FormatException catch (e, st) {
      dev.log('Failed to parse TV devices', error: e, stackTrace: st);
      return [];
    }
  }

  Future<void> _saveAll(List<TvDevice> items) async {
    final json = jsonEncode(
      items.map((tv) => TvDeviceMapper.fromDomain(tv).toMap()).toList(),
    );
    await _storage.setString(StorageKeys.tvDevices, json);
  }

  @override
  Future<TvDevice?> loadById(String id) async {
    final all = await loadAll();
    final matches = all.where((tv) => tv.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<void> add(TvDevice device) async {
    final all = await loadAll();
    final withId = device.copyWith(
      id: device.id.isEmpty ? _idGenerator.generate() : null,
    );
    all.add(withId);
    await _saveAll(all);
  }

  @override
  Future<void> update(TvDevice device) async {
    final all = await loadAll();
    final index = all.indexWhere((tv) => tv.id == device.id);
    if (index == -1) return;
    all[index] = device;
    await _saveAll(all);
  }

  @override
  Future<void> deleteById(String id) async {
    final all = await loadAll();
    all.removeWhere((tv) => tv.id == id);
    await _saveAll(all);
  }
}
