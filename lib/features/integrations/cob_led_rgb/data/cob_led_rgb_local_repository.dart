import 'dart:convert';
import 'dart:developer' as dev;

import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../data/dto/cob_led_rgb_device_dto.dart';
import '../../../../data/mappers/cob_led_rgb_device_mapper.dart';
import '../../../../domain/entities/cob_led_rgb_device.dart';
import '../../../../domain/repositories/cob_led_rgb_repository.dart';

class CobLedRgbLocalRepository implements CobLedRgbRepository {
  final LocalStorage _storage;
  final IdGenerator _idGenerator;

  CobLedRgbLocalRepository(this._storage, {IdGenerator? idGenerator})
      : _idGenerator = idGenerator ?? const TimestampIdGenerator();

  @override
  Future<List<CobLedRgbDevice>> loadAll() async {
    final raw = await _storage.getString(StorageKeys.cobLedRgbDevices);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CobLedRgbDeviceMapper.toDomain(
                CobLedRgbDeviceDto.fromMap(e as Map<String, dynamic>),
              ))
          .toList();
    } on FormatException catch (e, st) {
      dev.log('Failed to parse WLED devices', error: e, stackTrace: st);
      return [];
    }
  }

  Future<void> _saveAll(List<CobLedRgbDevice> items) async {
    final json = jsonEncode(
      items.map((d) => CobLedRgbDeviceMapper.fromDomain(d).toMap()).toList(),
    );
    await _storage.setString(StorageKeys.cobLedRgbDevices, json);
  }

  @override
  Future<CobLedRgbDevice?> loadById(String id) async {
    final all = await loadAll();
    final matches = all.where((d) => d.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<void> add(CobLedRgbDevice device) async {
    final all = await loadAll();
    final withId = device.copyWith(
      id: device.id.isEmpty ? _idGenerator.generate() : null,
    );
    all.add(withId);
    await _saveAll(all);
  }

  @override
  Future<void> update(CobLedRgbDevice device) async {
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
