import 'package:flutter/foundation.dart';

import '../../domain/entities/equipment.dart';
import '../../domain/repositories/equipment_repository.dart';
import 'base_device_controller.dart';

/// Base controller for Equipment-entity devices (smart plug, thermometer,
/// hygrometer).
///
/// Provides [updateName], [updateRoom], [toggleFavorite], and the protected
/// helpers [persistEquipment] and [deleteFromRepo] that subclasses use to
/// implement their own field-specific mutations and cleanup.
abstract class BaseEquipmentController extends BaseDeviceController {
  final EquipmentRepository _equipmentRepo;
  Equipment _equipment;

  BaseEquipmentController({
    required Equipment equipment,
    required EquipmentRepository equipmentRepo,
    required super.roomRepo,
  })  : _equipment = equipment,
        _equipmentRepo = equipmentRepo;

  // ── Getters ──────────────────────────────────────────────────────────────────

  Equipment get equipment => _equipment;

  @override
  @protected
  String? get currentRoomId => _equipment.roomId;

  // ── Shared mutations ─────────────────────────────────────────────────────────

  Future<void> updateName(String name) async {
    await persistEquipment(_equipment.copyWith(name: name));
  }

  Future<void> updateRoom(String? roomId) async {
    if (_equipment.roomId == roomId) return;
    final updated = _equipment.copyWith(roomId: roomId);
    await _equipmentRepo.update(updated);
    _equipment = updated;
    notify();
  }

  Future<void> toggleFavorite() async {
    await persistEquipment(_equipment.copyWith(isFavorite: !_equipment.isFavorite));
  }

  // ── Protected helpers for subclass mutations ─────────────────────────────────

  /// Persists [updated] to the repository, refreshes the local cache, and
  /// notifies listeners. Use this in subclasses for field-specific mutations
  /// (e.g. IP address, device type) not covered by the base methods.
  @protected
  Future<void> persistEquipment(Equipment updated) async {
    await _equipmentRepo.update(updated);
    _equipment = updated;
    notify();
  }

  /// Deletes the equipment from the repository. Subclasses call this as part
  /// of their [delete] implementation, adding any additional cleanup afterwards.
  @protected
  Future<void> deleteFromRepo() async {
    await _equipmentRepo.deleteById(_equipment.id);
  }
}
