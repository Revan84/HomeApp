import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../data/mappers/equipment_mapper.dart';
import '../../../domain/entities/cob_led_cct_device.dart';
import '../../../domain/entities/equipment.dart';
import '../../../domain/entities/room.dart';
import '../../../domain/entities/tv_device.dart';
import '../../../domain/entities/cob_led_rgb_device.dart';
import '../../../domain/repositories/cob_led_cct_repository.dart';
import '../../../domain/repositories/equipment_repository.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/tv_repository.dart';
import '../../../domain/repositories/cob_led_rgb_repository.dart';
import '../../integrations/cob_led_cct/data/api_client.dart';
import '../../integrations/samsung/data/samsung_ws_client.dart';
import '../../integrations/shelly/data/dto/shelly_device_info_dto.dart';
import '../../integrations/shelly/data/shelly_rpc_client.dart';
import '../../integrations/cob_led_rgb/data/cob_led_rgb_api_client.dart';
import '../../live/controllers/live_polling_controller.dart';

/// Manages equipment list data, live polling sync, and device CRUD operations.
class EquipmentsController extends ChangeNotifier {
  final EquipmentRepository _equipmentRepo;
  final RoomRepository _roomRepo;
  final TvRepository _tvRepo;
  final CobLedRgbRepository _cobLedRgbRepo;
  final CobLedCctRepository _cobLedCctRepo;
  final LivePollingController _liveController;
  final ShellyRpcClient _rpc;
  final http.Client _httpClient;

  // Why: API clients are stateless and IP-agnostic — keep one instance per
  // controller instead of allocating one per test tap. Mirrors HomeCctHandler.
  late final CobLedCctApiClient _cctApi = CobLedCctApiClient(_httpClient);
  late final CobLedRgbApiClient _rgbApi = CobLedRgbApiClient(_httpClient);

  EquipmentsController({
    required EquipmentRepository equipmentRepo,
    required RoomRepository roomRepo,
    required TvRepository tvRepo,
    required CobLedRgbRepository cobLedRgbRepo,
    required CobLedCctRepository cobLedCctRepo,
    required LivePollingController liveController,
    required ShellyRpcClient rpc,
    required http.Client httpClient,
  })  : _equipmentRepo = equipmentRepo,
        _roomRepo = roomRepo,
        _tvRepo = tvRepo,
        _cobLedRgbRepo = cobLedRgbRepo,
        _cobLedCctRepo = cobLedCctRepo,
        _liveController = liveController,
        _rpc = rpc,
        _httpClient = httpClient;

  bool _loading = true;
  bool get isLoading => _loading;

  String? _error;
  String? get error => _error;

  List<Equipment> _allEquipments = [];
  List<Equipment> get allEquipments => _allEquipments;

  List<Room> _rooms = [];
  List<Room> get rooms => _rooms;

  List<TvDevice> _tvDevices = [];
  List<TvDevice> get tvDevices => _tvDevices;

  List<CobLedRgbDevice> _cobLedRgbDevices = [];
  List<CobLedRgbDevice> get cobLedRgbDevices => _cobLedRgbDevices;

  List<CobLedCctDevice> _cobLedCctDevices = [];
  List<CobLedCctDevice> get cobLedCctDevices => _cobLedCctDevices;

  bool isSupported(Equipment e) => e.type == EquipmentType.shellyPlusPlugS;

  /// Room IDs visible in the given group.
  Set<String> visibleRoomIds(String? groupId) {
    if (groupId == null) return const {};
    return _rooms.where((r) => r.groupId == groupId).map((r) => r.id).toSet();
  }

  /// Equipments filtered to visible rooms in the given group.
  /// Unassigned devices (roomId == null) are always included so they are
  /// never invisible after being removed from a room.
  List<Equipment> equipmentsForGroup(String? groupId) {
    if (groupId == null) return _allEquipments;
    final roomIds = visibleRoomIds(groupId);
    return _allEquipments
        .where((e) => e.roomId == null || roomIds.contains(e.roomId))
        .toList(growable: false);
  }

  /// TV devices filtered to visible rooms in the given group.
  List<TvDevice> tvDevicesForGroup(String? groupId) {
    if (groupId == null) return _tvDevices;
    final roomIds = visibleRoomIds(groupId);
    return _tvDevices
        .where((tv) => tv.roomId == null || roomIds.contains(tv.roomId))
        .toList(growable: false);
  }

  /// WLED devices filtered to visible rooms in the given group.
  List<CobLedRgbDevice> cobLedRgbDevicesForGroup(String? groupId) {
    if (groupId == null) return _cobLedRgbDevices;
    final roomIds = visibleRoomIds(groupId);
    return _cobLedRgbDevices
        .where((w) => w.roomId == null || roomIds.contains(w.roomId))
        .toList(growable: false);
  }

  /// COB LED CCT devices filtered to visible rooms in the given group.
  List<CobLedCctDevice> cobLedCctDevicesForGroup(String? groupId) {
    if (groupId == null) return _cobLedCctDevices;
    final roomIds = visibleRoomIds(groupId);
    return _cobLedCctDevices
        .where((c) => c.roomId == null || roomIds.contains(c.roomId))
        .toList(growable: false);
  }

  // ---------------------------------------------------------------------------
  // CRUD operations
  // ---------------------------------------------------------------------------

  Future<void> addEquipment(Equipment equipment) async {
    try {
      await _equipmentRepo.add(equipment);
      await loadAll();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEquipment(Equipment equipment) async {
    try {
      await _equipmentRepo.update(equipment);
      await loadAll();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addTvDevice(TvDevice device) async {
    try {
      await _tvRepo.add(device);
      await loadAll();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addCobLedRgbDevice(CobLedRgbDevice device) async {
    try {
      await _cobLedRgbRepo.add(device);
      await loadAll();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addCobLedCctDevice(CobLedCctDevice device) async {
    try {
      await _cobLedCctRepo.add(device);
      await loadAll();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Connection tests
  // ---------------------------------------------------------------------------

  /// Tests Shelly connection. Throws on failure.
  Future<ShellyDeviceInfoDto> testShellyConnection(String ip) {
    return _rpc.getDeviceInfo(ip);
  }

  /// Tests Samsung TV WebSocket connection. Returns ok flag and optional token.
  Future<({bool ok, String? token})> testTvConnection(String ip) async {
    final client = SamsungWsClient();
    String? token;
    final sub = client.onTokenReceived.listen((t) => token = t);
    try {
      final ok = await client.connect(ip);
      await Future<void>.delayed(const Duration(seconds: 2));
      token ??= client.token;
      return (ok: ok, token: token);
    } catch (_) {
      return (ok: false, token: null);
    } finally {
      await sub.cancel();
      await client.disconnect();
      client.dispose();
    }
  }

  /// Tests WLED connection. Returns true if reachable.
  Future<bool> testCobLedRgbConnection(String ip) {
    return _rgbApi.testConnection(ip);
  }

  /// Tests COB LED CCT connection. Returns true if reachable.
  Future<bool> testCobLedCctConnection(String ip) {
    return _cctApi.testConnection(ip);
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  /// Loads all device data and syncs live polling.
  Future<void> loadAll() async {
    _loading = true;
    _error = null;

    try {
      final results = await Future.wait([
        _equipmentRepo.loadAll(),
        _roomRepo.loadAll(),
        _tvRepo.loadAll(),
        _cobLedRgbRepo.loadAll(),
        _cobLedCctRepo.loadAll(),
      ]);

      _allEquipments = results[0] as List<Equipment>;
      _rooms = results[1] as List<Room>;
      _tvDevices = results[2] as List<TvDevice>;
      _cobLedRgbDevices = results[3] as List<CobLedRgbDevice>;
      _cobLedCctDevices = results[4] as List<CobLedCctDevice>;

      final endpoints = _allEquipments
          .where(isSupported)
          .map((e) => e.toEndpoint())
          .toList();
      _liveController.syncFollowed(endpoints, forcePollNow: true);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
