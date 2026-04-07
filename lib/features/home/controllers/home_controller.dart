import 'package:flutter/foundation.dart';

import '../../../data/mappers/equipment_mapper.dart';
import '../../../domain/entities/equipment.dart';
import '../../../domain/entities/room.dart';
import '../../../domain/entities/room_group.dart';
import '../../../domain/entities/tv_device.dart';
import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/repositories/room_group_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/tv_repository.dart';
import '../../live/controllers/live_polling_controller.dart';

/// Manages home screen data: favorites, rooms, equipments, and live sync.
class HomeController extends ChangeNotifier {
  final RoomGroupRepository _roomGroupRepo;
  final RoomRepository _roomRepo;
  final EquipmentRepository _equipmentRepo;
  final TvRepository _tvRepo;
  final LivePollingController _liveController;

  HomeController({
    required RoomGroupRepository roomGroupRepo,
    required RoomRepository roomRepo,
    required EquipmentRepository equipmentRepo,
    required TvRepository tvRepo,
    required LivePollingController liveController,
  })  : _roomGroupRepo = roomGroupRepo,
        _roomRepo = roomRepo,
        _equipmentRepo = equipmentRepo,
        _tvRepo = tvRepo,
        _liveController = liveController;

  bool _loading = true;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;

  List<RoomGroup> _roomGroups = const [];
  List<RoomGroup> get roomGroups => _roomGroups;

  List<Room> _rooms = const [];
  List<Room> get allRooms => _rooms;

  List<Equipment> _equipments = const [];
  List<Equipment> get allEquipments => _equipments;

  List<TvDevice> _tvDevices = const [];
  List<TvDevice> get allTvDevices => _tvDevices;

  /// Loads all data in parallel and syncs live polling for the given group.
  Future<void> loadAll(String? selectedGroupId) async {
    _loading = true;
    _error = null;

    try {
      final results = await Future.wait([
        _roomGroupRepo.loadAll(),
        _roomRepo.loadAll(),
        _equipmentRepo.loadAll(),
        _tvRepo.loadAll(),
      ]);

      final roomGroups = results[0] as List<RoomGroup>;
      final rooms = results[1] as List<Room>;
      final equipments = results[2] as List<Equipment>;
      final tvDevices = results[3] as List<TvDevice>;

      _roomGroups = _sortedGroups(roomGroups);
      _rooms = _sortedRooms(rooms);
      _equipments = equipments;
      _tvDevices = tvDevices;

      syncLivePolling(selectedGroupId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Derived data
  // ---------------------------------------------------------------------------

  /// Rooms visible in the given group.
  List<Room> visibleRooms(String? groupId) {
    if (groupId == null) return const [];
    return _rooms.where((r) => r.groupId == groupId).toList(growable: false);
  }

  /// Room IDs visible in the given group.
  Set<String> visibleRoomIds(String? groupId) =>
      visibleRooms(groupId).map((r) => r.id).toSet();

  /// Favorite plug equipments in the selected group.
  List<Equipment> favoriteEquipments(String? groupId) {
    final roomIds = visibleRoomIds(groupId);
    return _equipments
        .where((e) => e.isFavorite && roomIds.contains(e.roomId))
        .toList(growable: false);
  }

  /// Favorite TV devices in the selected group.
  List<TvDevice> favoriteTvDevices(String? groupId) {
    final roomIds = visibleRoomIds(groupId);
    return _tvDevices
        .where((tv) => tv.isFavorite && roomIds.contains(tv.roomId))
        .toList(growable: false);
  }

  bool isPlugEquipment(Equipment e) =>
      e.type == EquipmentType.shellyPlusPlugS;

  bool isFavoriteSupported(Equipment e) =>
      isPlugEquipment(e) && e.showToggle;

  /// Resolves a room name by ID. Returns empty string when not found.
  String roomName(String? roomId) {
    if (roomId == null) return '';
    return _rooms.where((r) => r.id == roomId).firstOrNull?.name ?? '';
  }

  /// Finds the active RoomGroup by ID.
  RoomGroup? activeRoomGroup(String? groupId) {
    if (groupId == null) return null;
    return _roomGroups.where((g) => g.id == groupId).firstOrNull;
  }

  /// Determines the initial selected group ID.
  String? resolveGroupId(String? currentId) {
    if (_roomGroups.any((g) => g.id == currentId)) return currentId;
    return _roomGroups.isNotEmpty ? _roomGroups.first.id : null;
  }

  /// Syncs live polling with devices relevant to the home screen.
  void syncLivePolling(String? groupId) {
    final favoriteDevices = _equipments
        .where((e) => e.isFavorite && isFavoriteSupported(e))
        .toList(growable: false);

    final roomPlugs = <Equipment>[];
    for (final room in visibleRooms(groupId)) {
      final plugs = _equipments
          .where((e) => isPlugEquipment(e) && e.roomId == room.id)
          .take(3);
      roomPlugs.addAll(plugs);
    }

    final uniqueById = <String, Equipment>{};
    for (final e in [...favoriteDevices, ...roomPlugs]) {
      uniqueById[e.id] = e;
    }

    _liveController.syncFollowed(
      uniqueById.values.map((e) => e.toEndpoint()),
      forcePollNow: true,
    );
  }

  /// Plugs (Shelly-type) that belong to [roomId].
  List<Equipment> plugsForRoom(String roomId) {
    return _equipments
        .where(
          (e) => e.type == EquipmentType.shellyPlusPlugS && e.roomId == roomId,
        )
        .toList(growable: false);
  }

  /// Finds an equipment by id, or null.
  Equipment? equipmentById(String id) =>
      _equipments.where((e) => e.id == id).firstOrNull;

  // ---------------------------------------------------------------------------
  // Room group CRUD
  // ---------------------------------------------------------------------------

  /// Creates a new room group and inserts it into the sorted list.
  Future<RoomGroup> addRoomGroup(String name) async {
    final group = await _roomGroupRepo.add(name);
    _roomGroups = _sortedGroups([..._roomGroups, group]);
    notifyListeners();
    return group;
  }

  // ---------------------------------------------------------------------------
  // Favorites
  // ---------------------------------------------------------------------------

  Future<void> removeEquipmentFromFavorites(Equipment equipment) {
    return _equipmentRepo.update(equipment.copyWith(isFavorite: false));
  }

  Future<void> removeTvFromFavorites(TvDevice tv) {
    return _tvRepo.update(tv.copyWith(isFavorite: false));
  }

  // ---------------------------------------------------------------------------
  // Live actions
  // ---------------------------------------------------------------------------

  Future<void> togglePlug(Equipment equipment) =>
      _liveController.toggle(equipment.toEndpoint());

  // ---------------------------------------------------------------------------
  // Room CRUD
  // ---------------------------------------------------------------------------

  /// Returns all rooms NOT in [groupId] (available to be moved into it).
  Future<List<Room>> availableRoomsForGroup(String groupId) async {
    final all = await _roomRepo.loadAll();
    return all.where((r) => r.groupId != groupId).toList(growable: false);
  }

  Future<Room> addRoom({required String name, required String groupId}) =>
      _roomRepo.add(name: name, groupId: groupId);

  Future<void> moveRoomToGroup(Room room, String groupId) =>
      _roomRepo.update(room.copyWith(groupId: groupId));

  Future<void> renameRoom(Room room, String name) =>
      _roomRepo.update(room.copyWith(name: name));

  Future<void> deleteRoom(Room room) => _roomRepo.deleteById(room.id);

  // ---------------------------------------------------------------------------
  // Sort helpers
  // ---------------------------------------------------------------------------

  static List<RoomGroup> _sortedGroups(List<RoomGroup> groups) =>
      [...groups]..sort((a, b) {
          final s = a.sortOrder.compareTo(b.sortOrder);
          return s != 0
              ? s
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

  static List<Room> _sortedRooms(List<Room> rooms) =>
      [...rooms]..sort((a, b) {
          final groupCmp = a.groupId.compareTo(b.groupId);
          if (groupCmp != 0) return groupCmp;
          final sortCmp = a.sortOrder.compareTo(b.sortOrder);
          if (sortCmp != 0) return sortCmp;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
}
