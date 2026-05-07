import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../devices/tv/domain/tv_remote_command.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../data/mappers/equipment_mapper.dart';
import '../../../domain/entities/cob_led_cct_device.dart';
import '../../../domain/entities/device_bundle.dart';
import '../../../domain/entities/equipment.dart';
import '../../../domain/entities/live_state.dart';
import '../../../domain/entities/room.dart';
import '../../../domain/entities/room_group.dart';
import '../../../domain/entities/tv_device.dart';
import '../../../domain/entities/cob_led_rgb_device.dart';
import '../../../domain/repositories/cob_led_cct_repository.dart';
import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/repositories/room_group_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/tv_repository.dart';
import '../../../domain/repositories/cob_led_rgb_repository.dart';
import '../../integrations/cob_led_rgb/data/cob_led_rgb_api_client.dart' show CobLedRgbState;
import '../../integrations/cob_led_cct/data/api_client.dart' show CctDeviceState;
import '../../live/controllers/live_polling_controller.dart';
import '../domain/today_widget_type.dart';
import 'home_cct_handler.dart';
import 'home_rgb_handler.dart';
import 'home_tv_handler.dart';

/// Manages home screen data: favorites, rooms, devices, today stats, and live sync.
class HomeController extends ChangeNotifier {
  final RoomGroupRepository _roomGroupRepo;
  final RoomRepository _roomRepo;
  final EquipmentRepository _equipmentRepo;
  final TvRepository _tvRepo;
  final CobLedRgbRepository _cobLedRgbRepo;
  final CobLedCctRepository _cobLedCctRepo;
  final LivePollingController _liveController;
  final LocalStorage _storage;

  late final HomeRgbHandler _rgb;
  late final HomeCctHandler _cct;
  late final HomeTvHandler _tv;

  HomeController({
    required RoomGroupRepository roomGroupRepo,
    required RoomRepository roomRepo,
    required EquipmentRepository equipmentRepo,
    required TvRepository tvRepo,
    required CobLedRgbRepository cobLedRgbRepo,
    required CobLedCctRepository cobLedCctRepo,
    required LivePollingController liveController,
    required LocalStorage storage,
    required http.Client httpClient,
  })  : _roomGroupRepo = roomGroupRepo,
        _roomRepo = roomRepo,
        _equipmentRepo = equipmentRepo,
        _tvRepo = tvRepo,
        _cobLedRgbRepo = cobLedRgbRepo,
        _cobLedCctRepo = cobLedCctRepo,
        _liveController = liveController,
        _storage = storage {
    _rgb = HomeRgbHandler(httpClient: httpClient, notify: notifyListeners);
    _cct = HomeCctHandler(httpClient: httpClient, notify: notifyListeners);
    _tv = HomeTvHandler(tvRepo: tvRepo, notify: notifyListeners);
  }

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

  List<CobLedRgbDevice> _cobLedRgbDevices = const [];
  List<CobLedRgbDevice> get allCobLedRgbDevices => _cobLedRgbDevices;

  List<CobLedCctDevice> _cobLedCctDevices = const [];
  List<CobLedCctDevice> get allCobLedCctDevices => _cobLedCctDevices;

  DeviceBundle get allDevices => DeviceBundle(
        equipments: _equipments,
        tvDevices: _tvDevices,
        cobLedRgbDevices: _cobLedRgbDevices,
        cobLedCctDevices: _cobLedCctDevices,
      );

  CobLedRgbState? cobLedRgbStateFor(String id) => _rgb.stateFor(id);
  CctDeviceState? cctStateFor(String id) => _cct.stateFor(id);
  bool tvIsOn(String id) => _tv.isOn(id);

  // ---------------------------------------------------------------------------
  // Today section config
  // ---------------------------------------------------------------------------

  double _kwhPrice = 0.20;
  double get kwhPrice => _kwhPrice;

  List<TodayWidgetType> _visibleTodayWidgets = const [
    TodayWidgetType.consumption,
  ];
  List<TodayWidgetType> get visibleTodayWidgets => _visibleTodayWidgets;

  Future<void> _loadTodayConfig() async {
    final priceStr = await _storage.getString(StorageKeys.kwhPrice);
    if (priceStr != null) {
      _kwhPrice = double.tryParse(priceStr) ?? 0.20;
    }

    final widgetsJson = await _storage.getString(StorageKeys.todayWidgetConfig);
    if (widgetsJson != null) {
      final names = (jsonDecode(widgetsJson) as List).cast<String>();
      _visibleTodayWidgets = names
          .map((n) => TodayWidgetType.values.where((t) => t.name == n).firstOrNull)
          .whereType<TodayWidgetType>()
          .toList();
    }
  }

  Future<void> setKwhPrice(double price) async {
    _kwhPrice = price;
    await _storage.setString(StorageKeys.kwhPrice, price.toString());
    notifyListeners();
  }

  Future<void> setVisibleTodayWidgets(List<TodayWidgetType> types) async {
    _visibleTodayWidgets = types;
    await _storage.setString(
      StorageKeys.todayWidgetConfig,
      jsonEncode(types.map((t) => t.name).toList()),
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Today stats (computed, not cached — called from UI build with live map)
  // ---------------------------------------------------------------------------

  /// Sum of energy (kWh) across all plugs in the visible group.
  double totalEnergyKwh(String? groupId, Map<String, LiveState> live) {
    final roomIds = visibleRoomIds(groupId);
    return _equipments
        .where((e) => e.type.isPlug && roomIds.contains(e.roomId))
        .fold(0.0, (sum, e) => sum + ((live[e.id]?.energyWh ?? 0).toDouble() / 1000.0));
  }

  /// Estimated cost in € based on accumulated kWh and stored price.
  double estimatedCost(double totalKwh) => totalKwh * _kwhPrice;

  /// Average temperature across thermometer devices in the visible group.
  /// Returns null when no thermometers are present or no data available.
  double? averageTemperature(String? groupId, Map<String, LiveState> live) {
    final roomIds = visibleRoomIds(groupId);
    final temps = _equipments
        .where((e) => e.type.isThermometer && roomIds.contains(e.roomId))
        .map((e) => live[e.id]?.temperatureC)
        .whereType<double>()
        .toList();
    if (temps.isEmpty) return null;
    return temps.reduce((a, b) => a + b) / temps.length;
  }

  /// Average humidity across thermometer/sensor devices in the visible group.
  double? averageHumidity(String? groupId, Map<String, LiveState> live) {
    final roomIds = visibleRoomIds(groupId);
    final values = _equipments
        .where((e) => e.type.isThermometer && roomIds.contains(e.roomId))
        .map((e) => live[e.id]?.humidity)
        .whereType<double>()
        .toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Whether any thermometer devices exist in the visible group.
  bool hasThermometers(String? groupId) {
    final roomIds = visibleRoomIds(groupId);
    return _equipments.any(
      (e) => e.type.isThermometer && roomIds.contains(e.roomId),
    );
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

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
        _cobLedRgbRepo.loadAll(),
        _cobLedCctRepo.loadAll(),
        _loadTodayConfig(),
      ]);

      final roomGroups = results[0] as List<RoomGroup>;
      final rooms = results[1] as List<Room>;
      final equipments = results[2] as List<Equipment>;
      final tvDevices = results[3] as List<TvDevice>;
      final cobLedRgbDevices = results[4] as List<CobLedRgbDevice>;
      final cctDevices = results[5] as List<CobLedCctDevice>;

      _roomGroups = _sortedGroups(roomGroups);
      _rooms = _sortedRooms(rooms);
      _equipments = equipments;
      _tvDevices = tvDevices;
      _cobLedRgbDevices = cobLedRgbDevices;
      _cobLedCctDevices = cctDevices;

      syncLivePolling(selectedGroupId);
      unawaited(_fetchCobLedRgbStates(selectedGroupId));
      unawaited(_fetchCctStates(selectedGroupId));
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
  /// Unassigned favorites (roomId == null) are always included.
  List<Equipment> favoriteEquipments(String? groupId) {
    final roomIds = visibleRoomIds(groupId);
    return _equipments
        .where((e) => e.isFavorite && (e.roomId == null || roomIds.contains(e.roomId)))
        .toList(growable: false);
  }

  /// Favorite TV devices in the selected group.
  List<TvDevice> favoriteTvDevices(String? groupId) {
    final roomIds = visibleRoomIds(groupId);
    return _tvDevices
        .where((tv) => tv.isFavorite && (tv.roomId == null || roomIds.contains(tv.roomId)))
        .toList(growable: false);
  }

  /// Favorite WLED devices in the selected group.
  List<CobLedRgbDevice> favoriteCobLedRgbDevices(String? groupId) {
    final roomIds = visibleRoomIds(groupId);
    return _cobLedRgbDevices
        .where((w) => w.isFavorite && (w.roomId == null || roomIds.contains(w.roomId)))
        .toList(growable: false);
  }

  /// Favorite CCT LED devices in the selected group.
  List<CobLedCctDevice> favoriteCobLedCctDevices(String? groupId) {
    final roomIds = visibleRoomIds(groupId);
    return _cobLedCctDevices
        .where((c) => c.isFavorite && (c.roomId == null || roomIds.contains(c.roomId)))
        .toList(growable: false);
  }

  bool isPlugEquipment(Equipment e) => e.type.isPlug;

  bool isFavoriteSupported(Equipment e) => isPlugEquipment(e) && e.showToggle;

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

  /// Total device count in a room (all types).
  int deviceCountForRoom(String roomId) {
    final plugs = _equipments.where((e) => e.roomId == roomId).length;
    final tvs = _tvDevices.where((t) => t.roomId == roomId).length;
    final rgb = _cobLedRgbDevices.where((w) => w.roomId == roomId).length;
    final cct = _cobLedCctDevices.where((c) => c.roomId == roomId).length;
    return plugs + tvs + rgb + cct;
  }

  // ---------------------------------------------------------------------------
  // Per-room device accessors (all types)
  // ---------------------------------------------------------------------------

  List<Equipment> equipmentsForRoom(String roomId) =>
      _equipments.where((e) => e.roomId == roomId).toList(growable: false);

  List<TvDevice> tvDevicesForRoom(String roomId) =>
      _tvDevices.where((t) => t.roomId == roomId).toList(growable: false);

  List<CobLedRgbDevice> cobLedRgbDevicesForRoom(String roomId) =>
      _cobLedRgbDevices.where((w) => w.roomId == roomId).toList(growable: false);

  List<CobLedCctDevice> cobLedCctDevicesForRoom(String roomId) =>
      _cobLedCctDevices.where((c) => c.roomId == roomId).toList(growable: false);

  /// Plugs (Shelly-type) that belong to [roomId] — legacy helper.
  List<Equipment> plugsForRoom(String roomId) {
    return _equipments
        .where((e) => e.type.isPlug && e.roomId == roomId)
        .toList(growable: false);
  }

  /// Finds an equipment by id, or null.
  Equipment? equipmentById(String id) =>
      _equipments.where((e) => e.id == id).firstOrNull;

  // ---------------------------------------------------------------------------
  // Live polling sync
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // RGB / CCT / TV — delegated to sub-handlers
  // ---------------------------------------------------------------------------

  Future<void> _fetchCobLedRgbStates(String? groupId) {
    final roomIds = visibleRoomIds(groupId);
    return _rgb.fetchStates(
      _cobLedRgbDevices.where((w) => roomIds.contains(w.roomId) || w.isFavorite),
    );
  }

  Future<void> _fetchCctStates(String? groupId) {
    final roomIds = visibleRoomIds(groupId);
    return _cct.fetchStates(
      _cobLedCctDevices.where((c) => roomIds.contains(c.roomId) || c.isFavorite),
    );
  }

  Future<void> toggleCobLedRgb(CobLedRgbDevice device) => _rgb.toggle(device);
  Future<void> setCobLedRgbBrightness(CobLedRgbDevice device, double v) => _rgb.setBrightness(device, v);

  Future<void> toggleCobLedCct(CobLedCctDevice device) => _cct.toggle(device);
  Future<void> setCobLedCctBrightness(CobLedCctDevice device, double v) => _cct.setBrightness(device, v);
  Future<void> stepCobLedCctSpeed(CobLedCctDevice device, {required bool up}) =>
      _cct.stepSpeed(device, up: up);

  Future<void> sendTvCommand(TvDevice device, TvRemoteCommand cmd) => _tv.sendCommand(device, cmd);

  // ---------------------------------------------------------------------------
  // Room group CRUD
  // ---------------------------------------------------------------------------

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

  Future<void> removeCobLedRgbFromFavorites(CobLedRgbDevice device) {
    return _cobLedRgbRepo.update(device.copyWith(isFavorite: false));
  }

  Future<void> removeCobLedCctFromFavorites(CobLedCctDevice device) {
    return _cobLedCctRepo.update(device.copyWith(isFavorite: false));
  }

  /// Toggles the favorite flag, updates the in-memory cache immediately so
  /// reactive UIs (e.g. FavoritesPage) rebuild without a full [loadAll].
  Future<void> toggleEquipmentFavorite(Equipment e) async {
    final updated = e.copyWith(isFavorite: !e.isFavorite);
    await _equipmentRepo.update(updated);
    _equipments = [for (final x in _equipments) if (x.id == e.id) updated else x];
    notifyListeners();
  }

  Future<void> toggleTvFavorite(TvDevice tv) async {
    final updated = tv.copyWith(isFavorite: !tv.isFavorite);
    await _tvRepo.update(updated);
    _tvDevices = [for (final x in _tvDevices) if (x.id == tv.id) updated else x];
    notifyListeners();
  }

  Future<void> toggleCobLedRgbFavorite(CobLedRgbDevice d) async {
    final updated = d.copyWith(isFavorite: !d.isFavorite);
    await _cobLedRgbRepo.update(updated);
    _cobLedRgbDevices = [for (final x in _cobLedRgbDevices) if (x.id == d.id) updated else x];
    notifyListeners();
  }

  Future<void> toggleCobLedCctFavorite(CobLedCctDevice c) async {
    final updated = c.copyWith(isFavorite: !c.isFavorite);
    await _cobLedCctRepo.update(updated);
    _cobLedCctDevices = [for (final x in _cobLedCctDevices) if (x.id == c.id) updated else x];
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Remove from room (clears roomId, updates cache immediately)
  // ---------------------------------------------------------------------------

  Future<void> removeEquipmentFromRoom(Equipment e) async {
    final updated = e.copyWith(roomId: null);
    await _equipmentRepo.update(updated);
    _equipments = [for (final x in _equipments) if (x.id == e.id) updated else x];
    notifyListeners();
  }

  Future<void> removeTvFromRoom(TvDevice tv) async {
    final updated = tv.copyWith(clearRoomId: true);
    await _tvRepo.update(updated);
    _tvDevices = [for (final x in _tvDevices) if (x.id == tv.id) updated else x];
    notifyListeners();
  }

  Future<void> removeCobLedRgbFromRoom(CobLedRgbDevice d) async {
    final updated = d.copyWith(clearRoomId: true);
    await _cobLedRgbRepo.update(updated);
    _cobLedRgbDevices = [for (final x in _cobLedRgbDevices) if (x.id == d.id) updated else x];
    notifyListeners();
  }

  Future<void> removeCobLedCctFromRoom(CobLedCctDevice c) async {
    final updated = c.copyWith(clearRoomId: true);
    await _cobLedCctRepo.update(updated);
    _cobLedCctDevices = [for (final x in _cobLedCctDevices) if (x.id == c.id) updated else x];
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Live actions
  // ---------------------------------------------------------------------------

  Future<void> togglePlug(Equipment equipment) =>
      _liveController.toggle(equipment.toEndpoint());

  // ---------------------------------------------------------------------------
  // Room CRUD
  // ---------------------------------------------------------------------------

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

  @override
  void dispose() {
    _tv.dispose();
    super.dispose();
  }
}
