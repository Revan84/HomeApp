import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../../core/device/base_device_controller.dart';
import '../../../../domain/entities/cct_scene.dart';
import '../../../../domain/entities/cob_led_cct_device.dart';
import '../../../../domain/repositories/cob_led_cct_repository.dart';
import '../../../integrations/cob_led_cct/data/api_client.dart';

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

  // Why: BaseDeviceController._disposed is private; we need our own flag to
  // guard fire-and-forget IO writes from the init() async chain.
  bool _disposed = false;

  CobLedCctController({
    required CobLedCctRepository repo,
    required super.roomRepo,
    required http.Client httpClient,
    CobLedCctDevice? initialDevice,
  }) : _repo = repo,
       _api = CobLedCctApiClient(httpClient),
       _device =
           initialDevice ??
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

    await Future.wait([loadRooms(), _fetchState()]);

    // Load effect names and device info in background — don't block render.
    _api.getEffects(_device.ipAddress).then((effects) {
      // Why: avoid notify() / state mutation after dispose.
      if (_disposed) return;
      _effectNames = effects;
      notify();
    });

    _api.getInfo(_device.ipAddress).then((model) async {
      // Why: avoid repo write + notify() after dispose.
      if (_disposed) return;
      if (model != null && model != _device.modelName) {
        final updated = _device.copyWith(modelName: model);
        await _repo.update(updated);
        if (_disposed) return;
        _device = updated;
        notify();
      }
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
    // Use setFullSegment so we don't clobber the active effect/speed with a
    // separate seg[] write, and to cover all WLED CCT field-name variants.
    final cct = ((ct - 2700) / (6500 - 2700) * 255).round().clamp(0, 255);
    await _api.setFullSegment(
      _device.ipAddress,
      cct: cct,
      effectId: _cctState.effectId,
      speed: _cctState.effectSpeed,
    );
  }

  // ── WLED Controls ────────────────────────────────────────────────────────────

  /// Selects an effect by index into [effectNames].
  Future<void> setEffect(int effectId) async {
    _cctState = _cctState.copyWith(effectId: effectId);
    notify();
    await _api.setEffect(
      _device.ipAddress,
      effectId,
      speed: _cctState.effectSpeed,
    );
  }

  /// Sets effect speed from a normalised [value] in 0.0–1.0.
  Future<void> setEffectSpeed(double value) async {
    final speed = (value.clamp(0.0, 1.0) * 255).round();
    _cctState = _cctState.copyWith(effectSpeed: speed);
    notify();
    await _api.setEffect(_device.ipAddress, _cctState.effectId, speed: speed);
  }

  // ── Scene / Template management ──────────────────────────────────────────────

  /// Applies [scene] to the device.
  ///
  /// Sequenced as 2 sequential PATCHes (CCT+effect+speed first, brightness
  /// second) instead of 3 parallel ones. Why: parallel writes had undefined
  /// ordering on the device and could flash an intermediate frame between the
  /// old colour/effect and the new brightness.
  Future<void> applyScene(CctScene scene) async {
    final updated = _device.copyWith(activeSceneId: scene.id);
    await _repo.update(updated);
    _device = updated;
    _cctState = _cctState.copyWith(
      brightness: scene.brightness,
      colorTempK: scene.colorTempK,
      effectId: scene.effectId,
      effectSpeed: scene.effectSpeed,
    );
    notify();
    final cct = ((scene.colorTempK - 2700) / (6500 - 2700) * 255)
        .round()
        .clamp(0, 255);
    await _api.setFullSegment(
      _device.ipAddress,
      cct: cct,
      effectId: scene.effectId,
      speed: scene.effectSpeed,
    );
    await _api.setBrightness(_device.ipAddress, scene.brightness);
  }

  /// Adds a new scene capturing all five parameters.
  Future<void> addSceneWithValues({
    required String name,
    required int colorTempK,
    required int brightness,
    required int effectId,
    required int effectSpeed,
  }) async {
    final scene = CctScene(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      colorTempK: colorTempK,
      brightness: brightness,
      effectId: effectId,
      effectSpeed: effectSpeed,
    );
    final updated = _device.copyWith(scenes: [..._device.scenes, scene]);
    await _repo.update(updated);
    _device = updated;
    notify();
  }

  /// Overwrites an existing scene (used when editing an active template).
  Future<void> updateScene(CctScene scene) async {
    final nextScenes = _device.scenes
        .map((s) => s.id == scene.id ? scene : s)
        .toList();
    final updated = _device.copyWith(scenes: nextScenes);
    await _repo.update(updated);
    _device = updated;
    notify();
  }

  /// If a template is currently active, overwrites it with the current device
  /// state.  Called automatically after the user finishes adjusting any
  /// parameter while a template is selected.
  Future<void> saveActiveSceneSnapshot() async {
    final activeId = _device.activeSceneId;
    if (activeId.isEmpty) return;
    final idx = _device.scenes.indexWhere((s) => s.id == activeId);
    if (idx < 0) return;
    await updateScene(
      _device.scenes[idx].copyWith(
        colorTempK: _cctState.colorTempK,
        brightness: _cctState.brightness,
        effectId: _cctState.effectId,
        effectSpeed: _cctState.effectSpeed,
      ),
    );
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

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
