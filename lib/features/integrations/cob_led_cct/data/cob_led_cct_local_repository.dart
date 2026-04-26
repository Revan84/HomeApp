import 'dart:convert';
import 'dart:developer' as dev;

import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../data/dto/cob_led_cct_device_dto.dart';
import '../../../../data/mappers/cob_led_cct_device_mapper.dart';
import '../../../../domain/entities/cob_led_cct_device.dart';
import '../../../../domain/repositories/cob_led_cct_repository.dart';

/// Local-storage implementation of [CobLedCctRepository].
///
/// Devices are persisted as a JSON array under [_storageKey].
class CobLedCctLocalRepository implements CobLedCctRepository {
  static const _storageKey = 'cob_led_cct_devices_v1';

  final LocalStorage _storage;
  final IdGenerator _idGenerator;

  CobLedCctLocalRepository(this._storage, {IdGenerator? idGenerator})
      : _idGenerator = idGenerator ?? const TimestampIdGenerator();

  @override
  Future<List<CobLedCctDevice>> loadAll() async {
    final raw = await _storage.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CobLedCctDeviceMapper.toDomain(
                CobLedCctDeviceDto.fromMap(e as Map<String, dynamic>),
              ))
          .toList();
    } on FormatException catch (e, st) {
      dev.log('Failed to parse CobLedCct devices', error: e, stackTrace: st);
      return [];
    }
  }

  Future<void> _saveAll(List<CobLedCctDevice> items) async {
    final json = jsonEncode(
      items
          .map((d) => CobLedCctDeviceMapper.fromDomain(d).toMap())
          .toList(),
    );
    await _storage.setString(_storageKey, json);
  }

  @override
  Future<CobLedCctDevice?> loadById(String id) async {
    final all = await loadAll();
    final matches = all.where((d) => d.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<void> add(CobLedCctDevice device) async {
    final all = await loadAll();
    final withId = device.copyWith(
      id: device.id.isEmpty ? _idGenerator.generate() : null,
    );
    all.add(withId);
    await _saveAll(all);
  }

  @override
  Future<void> update(CobLedCctDevice device) async {
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
