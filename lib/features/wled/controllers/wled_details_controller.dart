import 'package:flutter/foundation.dart';

import '../../../domain/entities/room.dart';
import '../../../domain/entities/wled_device.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/wled_repository.dart';
import '../../integrations/wled/data/wled_api_client.dart';
import '../domain/rgb_color.dart';

/// Manages all state and side-effects for the WLED details screen.
///
/// Owns the API client calls, device state (on/off, color, effects, presets),
/// and room data. The UI only displays state and forwards user actions.
class WledDetailsController extends ChangeNotifier {
  final WledRepository _wledRepo;
  final RoomRepository _roomRepo;
  final WledApiClient _api;

  WledDetailsController({
    required WledRepository wledRepo,
    required RoomRepository roomRepo,
    required WledApiClient api,
  })  : _wledRepo = wledRepo,
        _roomRepo = roomRepo,
        _api = api;

  WledDevice? _device;
  WledDevice? get device => _device;

  bool _loadingDevice = true;
  bool get isLoading => _loadingDevice;

  WledState _wledState = WledState.defaultState;
  WledState get wledState => _wledState;

  List<String> _effects = const [];
  List<String> get effects => _effects;

  List<WledPreset> _presets = const [];
  List<WledPreset> get presets => _presets;

  List<Room> _rooms = const [];
  List<Room> get rooms => _rooms;

  bool _polling = false;
  bool get isPolling => _polling;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  Future<void> init(String deviceId) async {
    await Future.wait([
      _loadDevice(deviceId),
      _loadRooms(),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadDevice(String deviceId) async {
    _loadingDevice = true;
    notifyListeners();
    _device = await _wledRepo.loadById(deviceId);
    _loadingDevice = false;
    notifyListeners();
    if (_device != null) await refresh();
  }

  Future<void> _loadRooms() async {
    _rooms = await _roomRepo.loadAll();
    notifyListeners();
  }

  Future<void> refresh() async {
    final ip = _device?.ipAddress;
    if (ip == null) return;

    _polling = true;
    notifyListeners();

    final results = await Future.wait([
      _api.getState(ip),
      _api.getEffects(ip),
      _api.getPresets(ip),
    ]);

    final state = results[0] as WledState?;
    final effects = results[1] as List<String>;
    final presets = results[2] as List<WledPreset>;

    if (state != null) _wledState = state;
    if (effects.isNotEmpty) _effects = effects;
    if (presets.isNotEmpty) _presets = presets;

    _polling = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Controls
  // ---------------------------------------------------------------------------

  Future<void> togglePower() async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    final newOn = !_wledState.isOn;
    _wledState = _wledState.copyWith(isOn: newOn);
    notifyListeners();
    await _api.setOn(ip, on: newOn);
  }

  /// [color] is already in the domain [RgbColor] format.
  /// The UI converts Flutter [Color] → [RgbColor] at the boundary.
  Future<void> setColor(RgbColor color) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    _wledState = _wledState.copyWith(primaryColor: color);
    notifyListeners();
    await _api.setColor(ip, color);
  }

  /// [value] is a 0.0–1.0 fraction; converted to 0–255 internally.
  Future<void> setBrightness(double value) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    final bri = (value * 255).round();
    _wledState = _wledState.copyWith(brightness: bri);
    notifyListeners();
    await _api.setBrightness(ip, bri);
  }

  Future<void> setEffect(int effectId) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    _wledState = _wledState.copyWith(effectId: effectId);
    notifyListeners();
    await _api.setEffect(
      ip,
      effectId,
      speed: _wledState.effectSpeed,
      intensity: _wledState.effectIntensity,
    );
  }

  /// [value] is a 0.0–1.0 fraction; converted to 0–255 internally.
  Future<void> setEffectSpeed(double value) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    final speed = (value * 255).round();
    _wledState = _wledState.copyWith(effectSpeed: speed);
    notifyListeners();
    await _api.setEffect(
      ip,
      _wledState.effectId,
      speed: speed,
      intensity: _wledState.effectIntensity,
    );
  }

  /// [value] is a 0.0–1.0 fraction; converted to 0–255 internally.
  Future<void> setEffectIntensity(double value) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    final intensity = (value * 255).round();
    _wledState = _wledState.copyWith(effectIntensity: intensity);
    notifyListeners();
    await _api.setEffect(
      ip,
      _wledState.effectId,
      speed: _wledState.effectSpeed,
      intensity: intensity,
    );
  }

  Future<void> loadPreset(int presetId) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    _wledState = _wledState.copyWith(presetId: presetId);
    notifyListeners();
    await _api.loadPreset(ip, presetId);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await refresh();
  }

  // ---------------------------------------------------------------------------
  // Editing
  // ---------------------------------------------------------------------------

  Future<void> updateRoom(String? roomId) async {
    final d = _device;
    if (d == null) return;
    final updated = d.copyWith(roomId: roomId, clearRoomId: roomId == null);
    await _wledRepo.update(updated);
    _device = updated;
    notifyListeners();
  }

  Future<void> delete() async {
    if (_device == null) return;
    await _wledRepo.deleteById(_device!.id);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String roomName(String fallback) {
    final roomId = _device?.roomId;
    if (roomId == null) return fallback;
    return _rooms
            .cast<Room?>()
            .firstWhere((r) => r?.id == roomId, orElse: () => null)
            ?.name ??
        fallback;
  }
}
