import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/device/base_device_controller.dart';
import '../../../../domain/entities/cct_scene.dart';
import '../../../../domain/entities/cob_led_cct_device.dart';
import '../../../../domain/repositories/cob_led_cct_repository.dart';
import '../../../integrations/cob_led_cct/data/cob_led_cct_api_client.dart';

/// Controller for the COB LED CCT device detail screen.
///
/// Manages device state (power, brightness, colour temperature, effects),
/// scene/template management, and live state refresh from the device API.
class CobLedCctController extends BaseDeviceController {
  final CobLedCctRepository _repo;
  final CobLedCctApiClient _api;

  CobLedCctDevice _device;
  CctDeviceState _cctState = CctDeviceState.defaultState;
  List<String> _effectNames = const [];
  bool _isReachable = false;

  CobLedCctController({
    required CobLedCctRepository repo,
    required super.roomRepo,
    required http.Client httpClient,
    CobLedCctDevice? initialDevice,
  })  : _repo = repo,
        _api = CobLedCctApiClient(httpClient),
        _device = initialDevice ??
            const CobLedCctDevice(id: '', name: '', ipAddress: '') {
    Future.microtask(() => init(_device.id));
  }

  // ── Getters ─────────────────────────────────────────────────────────────────

  CobLedCctDevice get device => _device;
  CctDeviceState get cctState => _cctState;
  List<String> get effectNames => List.unmodifiable(_effectNames);
  List<CctScene> get scenes => List.unmodifiable(_device.scenes);
  bool get isReachable => _isReachable;

  @override
  @protected
  String? get currentRoomId => _device.roomId;

  // ── Initialisation ───────────────────────────────────────────────────────────

  Future<void> init(String deviceId) async {
    if (deviceId.isNotEmpty && _device.id.isEmpty) {
      final loaded = await _repo.loadById(deviceId);
      if (loaded != null) _device = loaded;
    }

    await Future.wait([
      loadRooms(),
      _fetchState(),
    ]);

    // Load effect names in background — don't block the screen render.
    _api.getEffects(_device.ipAddress).then((effects) {
      _effectNames = effects;
      notify();
    });

    notify();
  }

  // ── State refresh ────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    await _fetchState();
    notify();
  }

  Future<void> _fetchState() async {
    final state = await _api.getState(_device.ipAddress);
    if (state != null) {
      _cctState = state;
      _isReachable = true;
    } else {
      _isReachable = false;
    }
  }

  // ── Power / Brightness / Colour temperature ──────────────────────────────────

  Future<void> togglePower() async {
    final next = !_cctState.isOn;
    _cctState = _cctState.copyWith(isOn: next);
    notify();
    await _api.setOn(_device.ipAddress, on: next);
  }

  /// Sets brightness from a normalised [value] in 0.0–1.0.
  Future<void> setBrightness(double value) async {
    final bri = (value.clamp(0.0, 1.0) * 255).round();
    _cctState = _cctState.copyWith(brightness: bri);
    notify();
    await _api.setBrightness(_device.ipAddress, bri);
  }

  /// Sets colour temperature from a normalised [value] in 0.0–1.0.
  /// 0.0 = 2700 K (warm), 1.0 = 6500 K (cool).
  Future<void> setColorTemp(double value) async {
    const minK = 2700;
    const maxK = 6500;
    final ct = (minK + (value.clamp(0.0, 1.0) * (maxK - minK))).round();
    _cctState = _cctState.copyWith(colorTempK: ct);
    notify();
    await _api.setColorTemp(_device.ipAddress, ct);
  }

  // ── WLED Controls ────────────────────────────────────────────────────────────

  /// Selects an effect by index into [effectNames].
  Future<void> setEffect(int effectId) async {
    _cctState = _cctState.copyWith(effectId: effectId);
    notify();
    await _api.setEffect(_device.ipAddress, effectId,
        speed: _cctState.effectSpeed);
  }

  /// Sets effect speed from a normalised [value] in 0.0–1.0.
  Future<void> setEffectSpeed(double value) async {
    final speed = (value.clamp(0.0, 1.0) * 255).round();
    _cctState = _cctState.copyWith(effectSpeed: speed);
    notify();
    await _api.setEffect(_device.ipAddress, _cctState.effectId, speed: speed);
  }

  Future<void> setAudio(bool enabled) async {
    _cctState = _cctState.copyWith(audioReactive: enabled);
    notify();
    await _api.setAudio(_device.ipAddress, enabled: enabled);
  }

  // ── Scene / Template management ──────────────────────────────────────────────

  /// Applies [scene] to the device (brightness + colour temperature).
  Future<void> applyScene(CctScene scene) async {
    final updated = _device.copyWith(activeSceneId: scene.id);
    await _repo.update(updated);
    _device = updated;
    _cctState = _cctState.copyWith(
      brightness: scene.brightness,
      colorTempK: scene.colorTempK,
    );
    notify();
    await Future.wait([
      _api.setBrightness(_device.ipAddress, scene.brightness),
      _api.setColorTemp(_device.ipAddress, scene.colorTempK),
    ]);
  }

  /// Adds a new scene with [name], current brightness and colour temperature.
  Future<void> addScene(String name) async {
    final scene = CctScene(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      colorTempK: _cctState.colorTempK,
      brightness: _cctState.brightness,
    );
    final updated = _device.copyWith(scenes: [..._device.scenes, scene]);
    await _repo.update(updated);
    _device = updated;
    notify();
  }

  /// Adds a new scene with explicit values (used by the "save as scene" dialog).
  Future<void> addSceneWithValues({
    required String name,
    required int colorTempK,
    required int brightness,
  }) async {
    final scene = CctScene(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      colorTempK: colorTempK,
      brightness: brightness,
    );
    final updated = _device.copyWith(scenes: [..._device.scenes, scene]);
    await _repo.update(updated);
    _device = updated;
    notify();
  }

  /// Removes a scene by [sceneId].
  Future<void> deleteScene(String sceneId) async {
    final nextScenes = _device.scenes.where((s) => s.id != sceneId).toList();
    final clearActive = _device.activeSceneId == sceneId;
    final updated = clearActive
        ? _device.copyWith(scenes: nextScenes, clearActiveSceneId: true)
        : _device.copyWith(scenes: nextScenes);
    await _repo.update(updated);
    _device = updated;
    notify();
  }

  // ── Device metadata edits ────────────────────────────────────────────────────

  Future<void> updateName(String name) async {
    final updated = _device.copyWith(name: name);
    await _repo.update(updated);
    _device = updated;
    notify();
  }

  Future<void> updateIp(String ip) async {
    final updated = _device.copyWith(ipAddress: ip);
    await _repo.update(updated);
    _device = updated;
    notify();
  }

  Future<void> updateRoom(String? roomId) async {
    if (_device.roomId == roomId) return;
    final updated = roomId != null
        ? _device.copyWith(roomId: roomId)
        : _device.copyWith(clearRoomId: true);
    await _repo.update(updated);
    _device = updated;
    notify();
  }

  Future<void> toggleFavorite() async {
    final updated = _device.copyWith(isFavorite: !_device.isFavorite);
    await _repo.update(updated);
    _device = updated;
    notify();
  }

  Future<void> delete() async {
    await _repo.deleteById(_device.id);
  }
}
