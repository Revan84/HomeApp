import 'dart:convert';
import 'dart:developer' as dev;

import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../data/dto/connected_camera_device_dto.dart';
import '../../../../data/mappers/connected_camera_device_mapper.dart';
import '../../../../domain/entities/connected_camera_device.dart';
import '../../../../domain/repositories/connected_camera_repository.dart';

/// Local-storage implementation of [ConnectedCameraRepository].
///
/// Devices are persisted as a JSON array under [StorageKeys.connectedCameraDevices].
class ConnectedCameraLocalRepository implements ConnectedCameraRepository {
  final LocalStorage _storage;
  final IdGenerator _idGenerator;

  ConnectedCameraLocalRepository(this._storage, {IdGenerator? idGenerator})
      : _idGenerator = idGenerator ?? const TimestampIdGenerator();

  @override
  Future<List<ConnectedCameraDevice>> loadAll() async {
    final raw = await _storage.getString(StorageKeys.connectedCameraDevices);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ConnectedCameraDeviceMapper.toDomain(
                ConnectedCameraDeviceDto.fromMap(e as Map<String, dynamic>),
              ))
          .toList();
    } on FormatException catch (e, st) {
      dev.log('Failed to parse ConnectedCamera devices', error: e, stackTrace: st);
      return [];
    }
  }

  Future<void> _saveAll(List<ConnectedCameraDevice> items) async {
    final json = jsonEncode(
      items
          .map((d) => ConnectedCameraDeviceMapper.fromDomain(d).toMap())
          .toList(),
    );
    await _storage.setString(StorageKeys.connectedCameraDevices, json);
  }

  @override
  Future<ConnectedCameraDevice?> loadById(String id) async {
    final all = await loadAll();
    final matches = all.where((d) => d.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  @override
  Future<void> add(ConnectedCameraDevice device) async {
    final all = await loadAll();
    final withId = device.copyWith(
      id: device.id.isEmpty ? _idGenerator.generate() : null,
    );
    all.add(withId);
    await _saveAll(all);
  }

  @override
  Future<void> update(ConnectedCameraDevice device) async {
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
