import 'package:flutter/foundation.dart';

import '../../domain/entities/room.dart';
import '../../domain/repositories/room_repository.dart';

/// Abstract base for all device/equipment controllers.
///
/// Provides the safe-notify pattern, room list loading, and [roomName] helper
/// that every device controller duplicates verbatim.
///
/// Subclasses must implement [currentRoomId] to expose the entity's room
/// assignment so [roomName] can resolve the display name.
abstract class BaseDeviceController extends ChangeNotifier {
  final RoomRepository _roomRepo;
  List<Room> _rooms = const [];
  bool _disposed = false;

  BaseDeviceController({required RoomRepository roomRepo})
      : _roomRepo = roomRepo;

  // ── Rooms ────────────────────────────────────────────────────────────────────

  List<Room> get rooms => List.unmodifiable(_rooms);

  /// The current room id of the managed entity. Implemented by each subclass.
  @protected
  String? get currentRoomId;

  /// Resolves the room name for [currentRoomId], or returns [fallback].
  String roomName(String fallback) {
    final id = currentRoomId;
    if (id == null) return fallback;
    return _rooms.where((r) => r.id == id).map((r) => r.name).firstOrNull ??
        fallback;
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  /// Safe [notifyListeners] — no-op after [dispose].
  @protected
  void notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Loads all rooms from the repository, swallowing errors gracefully.
  /// Call from [initState]-equivalent logic in subclasses.
  @protected
  Future<void> loadRooms() async {
    await _roomRepo.loadAll().then((r) => _rooms = r).catchError((_) {
      _rooms = const [];
      return _rooms;
    });
  }
}
