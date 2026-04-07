import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/mappers/equipment_mapper.dart';
import '../../../domain/entities/equipment.dart';
import '../../../domain/entities/room.dart';
import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../live/controllers/live_polling_controller.dart';

/// Manages all state and side-effects for the equipment details screen.
///
/// The page is responsible only for displaying this state and forwarding
/// user actions. No repository or live-polling calls belong in the UI.
class EquipmentDetailsController extends ChangeNotifier {
  final EquipmentRepository _equipmentRepo;
  final RoomRepository _roomRepo;
  final LivePollingController _live;

  EquipmentDetailsController({
    required EquipmentRepository equipmentRepo,
    required RoomRepository roomRepo,
    required LivePollingController live,
  })  : _equipmentRepo = equipmentRepo,
        _roomRepo = roomRepo,
        _live = live;

  Equipment? _equipment;
  Equipment? get equipment => _equipment;

  List<Room> _rooms = const [];
  List<Room> get rooms => _rooms;

  bool _loading = true;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  /// Loads equipment and rooms. Returns false if the equipment was not found.
  Future<bool> load(String equipmentId) async {
    _loading = true;
    _error = null;
    var found = false;

    try {
      final results = await Future.wait([
        _equipmentRepo.loadAll(),
        _roomRepo.loadAll(),
      ]);

      final equipments = results[0] as List<Equipment>;
      final rooms = results[1] as List<Room>;

      final equipment = equipments.where((e) => e.id == equipmentId).firstOrNull;

      if (equipment != null) {
        _live.syncFollowed([equipment.toEndpoint()], forcePollNow: true);
        _equipment = equipment;
        _rooms = rooms;
        found = true;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }

    return found;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> updateName(String name) async {
    final e = _equipment;
    if (e == null) return;
    final updated = e.copyWith(name: name);
    try {
      await _equipmentRepo.update(updated);
      _equipment = updated;
      notifyListeners();
    } catch (err) {
      _error = err.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateIp(String ip) async {
    final e = _equipment;
    if (e == null) return;
    final updated = e.copyWith(ip: ip);
    try {
      await _equipmentRepo.update(updated);
      _equipment = updated;
      notifyListeners();
    } catch (err) {
      _error = err.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleFavorite() async {
    final e = _equipment;
    if (e == null) return;
    final updated = e.copyWith(isFavorite: !e.isFavorite);
    try {
      await _equipmentRepo.update(updated);
      _equipment = updated;
      notifyListeners();
    } catch (err) {
      _error = err.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateType(EquipmentType type) async {
    final e = _equipment;
    if (e == null) return;
    if (e.type == type) return;
    final updated = e.copyWith(type: type);
    try {
      await _equipmentRepo.update(updated);
      _equipment = updated;
      notifyListeners();
    } catch (err) {
      _error = err.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateRoom(String? roomId) async {
    final e = _equipment;
    if (e == null) return;
    if (e.roomId == roomId) return;
    final updated = e.copyWith(roomId: roomId);
    try {
      await _equipmentRepo.update(updated);
      _equipment = updated;
      notifyListeners();
    } catch (err) {
      _error = err.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Toggles the live output of the current equipment.
  Future<void> toggleOutput() {
    final e = _equipment;
    if (e == null) return Future.value();
    return _live.toggle(e.toEndpoint());
  }

  /// Deletes the equipment and removes it from live tracking.
  Future<void> delete() async {
    final e = _equipment;
    if (e == null) return;
    await _equipmentRepo.deleteById(e.id);
    _live.unfollowDevice(e.id);
    await _live.deleteHistoryForDevice(e.id);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String roomName(String? roomId, String fallback) {
    if (roomId == null) return fallback;
    return _rooms.where((r) => r.id == roomId).firstOrNull?.name ?? fallback;
  }
}
