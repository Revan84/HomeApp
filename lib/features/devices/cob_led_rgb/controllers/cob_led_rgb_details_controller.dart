import '../../../../core/device/base_device_controller.dart';
import '../../../../domain/entities/cob_led_rgb_device.dart';
import '../../../../domain/entities/rgb_scene.dart';
import '../../../../domain/repositories/cob_led_rgb_repository.dart';
import '../../../integrations/cob_led_rgb/data/cob_led_rgb_api_client.dart';
import '../domain/rgb_color.dart';

/// Manages all state and side-effects for the COB LED RGB details screen.
class CobLedRgbDetailsController extends BaseDeviceController {
  final CobLedRgbRepository _cobLedRgbRepo;
  final CobLedRgbApiClient _api;

  CobLedRgbDetailsController({
    required CobLedRgbRepository cobLedRgbRepo,
    required super.roomRepo,
    required CobLedRgbApiClient api,
  })  : _cobLedRgbRepo = cobLedRgbRepo,
        _api = api;

  CobLedRgbDevice? _device;
  CobLedRgbDevice? get device => _device;

  bool _loadingDevice = true;
  bool get isLoading => _loadingDevice;

  CobLedRgbState _cobLedRgbState = CobLedRgbState.defaultState;
  CobLedRgbState get cobLedRgbState => _cobLedRgbState;

  List<String> _effects = const [];
  List<String> get effects => _effects;

  List<CobLedRgbPreset> _presets = const [];
  List<CobLedRgbPreset> get presets => _presets;

  bool _polling = false;
  bool get isPolling => _polling;

  // True after the first refresh() completes (whether or not effects loaded).
  bool _effectsLoaded = false;
  bool get effectsLoaded => _effectsLoaded;

  List<RgbScene> get scenes => List.unmodifiable(_device?.scenes ?? const []);
  String get activeSceneId => _device?.activeSceneId ?? '';

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  String? get currentRoomId => _device?.roomId;

  Future<void> init(String deviceId) async {
    await Future.wait([
      _loadDevice(deviceId),
      loadRooms(),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadDevice(String deviceId) async {
    _loadingDevice = true;
    notify();
    _device = await _cobLedRgbRepo.loadById(deviceId);
    _loadingDevice = false;
    notify();
    if (_device != null) await refresh();
  }

  Future<void> refresh() async {
    final ip = _device?.ipAddress;
    if (ip == null) return;

    _polling = true;
    notify();

    final results = await Future.wait([
      _api.getState(ip),
      _api.getEffects(ip),
      _api.getPresets(ip),
    ]);

    final state = results[0] as CobLedRgbState?;
    final effects = results[1] as List<String>;
    final presets = results[2] as List<CobLedRgbPreset>;

    if (state != null) _cobLedRgbState = state;
    if (effects.isNotEmpty) _effects = effects;
    if (presets.isNotEmpty) _presets = presets;

    _polling = false;
    _effectsLoaded = true;
    notify();
  }

  // ---------------------------------------------------------------------------
  // Device controls
  // ---------------------------------------------------------------------------

  Future<void> togglePower() async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    final newOn = !_cobLedRgbState.isOn;
    _cobLedRgbState = _cobLedRgbState.copyWith(isOn: newOn);
    notify();
    await _api.setOn(ip, on: newOn);
  }

  Future<void> setColor(RgbColor color) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    _cobLedRgbState = _cobLedRgbState.copyWith(primaryColor: color);
    notify();
    await _api.setColor(ip, color);
  }

  /// [value] is a 0.0–1.0 fraction; converted to 0–255 internally.
  Future<void> setBrightness(double value) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    final bri = (value * 255).round();
    _cobLedRgbState = _cobLedRgbState.copyWith(brightness: bri);
    notify();
    await _api.setBrightness(ip, bri);
  }

  Future<void> setEffect(int effectId) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    _cobLedRgbState = _cobLedRgbState.copyWith(effectId: effectId);
    notify();
    await _api.setEffect(
      ip,
      effectId,
      speed: _cobLedRgbState.effectSpeed,
      intensity: _cobLedRgbState.effectIntensity,
    );
  }

  Future<void> setEffectSpeed(double value) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    final speed = (value * 255).round();
    _cobLedRgbState = _cobLedRgbState.copyWith(effectSpeed: speed);
    notify();
    await _api.setEffect(
      ip,
      _cobLedRgbState.effectId,
      speed: speed,
      intensity: _cobLedRgbState.effectIntensity,
    );
  }

  Future<void> setEffectIntensity(double value) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    final intensity = (value * 255).round();
    _cobLedRgbState = _cobLedRgbState.copyWith(effectIntensity: intensity);
    notify();
    await _api.setEffect(
      ip,
      _cobLedRgbState.effectId,
      speed: _cobLedRgbState.effectSpeed,
      intensity: intensity,
    );
  }

  Future<void> loadPreset(int presetId) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    _cobLedRgbState = _cobLedRgbState.copyWith(presetId: presetId);
    notify();
    await _api.loadPreset(ip, presetId);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await refresh();
  }

  // ---------------------------------------------------------------------------
  // Scene / template management
  // ---------------------------------------------------------------------------

  /// Applies [scene] to the device immediately.
  Future<void> applyScene(RgbScene scene) async {
    final d = _device;
    if (d == null) return;
    final updated = d.copyWith(activeSceneId: scene.id);
    await _cobLedRgbRepo.update(updated);
    _device = updated;
    final color = RgbColor(
        red: scene.colorRed,
        green: scene.colorGreen,
        blue: scene.colorBlue);
    _cobLedRgbState = _cobLedRgbState.copyWith(
      primaryColor: color,
      brightness: scene.brightness,
      effectId: scene.effectId,
      effectSpeed: scene.effectSpeed,
      effectIntensity: scene.effectIntensity,
    );
    notify();
    final ip = d.ipAddress;
    await _api.setColor(ip, color);
    await _api.setBrightness(ip, scene.brightness);
    await _api.setEffect(ip, scene.effectId,
        speed: scene.effectSpeed, intensity: scene.effectIntensity);
  }

  /// Captures the current device state as a new named scene.
  Future<void> addSceneWithValues({
    required String name,
    required int colorRed,
    required int colorGreen,
    required int colorBlue,
    required int brightness,
    required int effectId,
    required int effectSpeed,
    required int effectIntensity,
  }) async {
    final d = _device;
    if (d == null) return;
    final scene = RgbScene(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      colorRed: colorRed,
      colorGreen: colorGreen,
      colorBlue: colorBlue,
      brightness: brightness,
      effectId: effectId,
      effectSpeed: effectSpeed,
      effectIntensity: effectIntensity,
    );
    final updated = d.copyWith(scenes: [...d.scenes, scene]);
    await _cobLedRgbRepo.update(updated);
    _device = updated;
    notify();
  }

  /// Overwrites an existing scene (used when editing the active template).
  Future<void> updateScene(RgbScene scene) async {
    final d = _device;
    if (d == null) return;
    final nextScenes =
        d.scenes.map((s) => s.id == scene.id ? scene : s).toList();
    final updated = d.copyWith(scenes: nextScenes);
    await _cobLedRgbRepo.update(updated);
    _device = updated;
    notify();
  }

  /// Removes a scene by [sceneId].
  Future<void> deleteScene(String sceneId) async {
    final d = _device;
    if (d == null) return;
    final nextScenes = d.scenes.where((s) => s.id != sceneId).toList();
    final clearActive = d.activeSceneId == sceneId;
    final updated = clearActive
        ? d.copyWith(scenes: nextScenes, clearActiveSceneId: true)
        : d.copyWith(scenes: nextScenes);
    await _cobLedRgbRepo.update(updated);
    _device = updated;
    notify();
  }

  // ---------------------------------------------------------------------------
  // Device metadata
  // ---------------------------------------------------------------------------

  Future<void> toggleFavorite() async {
    final d = _device;
    if (d == null) return;
    final updated = d.copyWith(isFavorite: !d.isFavorite);
    await _cobLedRgbRepo.update(updated);
    _device = updated;
    notify();
  }

  Future<void> updateRoom(String? roomId) async {
    final d = _device;
    if (d == null) return;
    final updated = d.copyWith(roomId: roomId, clearRoomId: roomId == null);
    await _cobLedRgbRepo.update(updated);
    _device = updated;
    notify();
  }

  Future<void> delete() async {
    if (_device == null) return;
    await _cobLedRgbRepo.deleteById(_device!.id);
  }
}
