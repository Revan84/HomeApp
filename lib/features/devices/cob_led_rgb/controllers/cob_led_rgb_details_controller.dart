import '../../../../core/device/base_device_controller.dart';
import '../../../../domain/entities/cob_led_rgb_device.dart';
import '../../../../domain/repositories/cob_led_rgb_repository.dart';
import '../../../integrations/cob_led_rgb/data/cob_led_rgb_api_client.dart';
import '../domain/rgb_color.dart';

/// Manages all state and side-effects for the COB LED RGB details screen.
///
/// Owns the API client calls, device state (on/off, color, effects, presets),
/// and room data. The UI only displays state and forwards user actions.
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
    notify();
  }

  // ---------------------------------------------------------------------------
  // Controls
  // ---------------------------------------------------------------------------

  Future<void> togglePower() async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    final newOn = !_cobLedRgbState.isOn;
    _cobLedRgbState = _cobLedRgbState.copyWith(isOn: newOn);
    notify();
    await _api.setOn(ip, on: newOn);
  }

  /// [color] is already in the domain [RgbColor] format.
  /// The UI converts Flutter [Color] → [RgbColor] at the boundary.
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

  /// [value] is a 0.0–1.0 fraction; converted to 0–255 internally.
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

  /// [value] is a 0.0–1.0 fraction; converted to 0–255 internally.
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

  Future<void> setAudio(bool enabled) async {
    final ip = _device?.ipAddress;
    if (ip == null) return;
    _cobLedRgbState = _cobLedRgbState.copyWith(audioReactive: enabled);
    notify();
    await _api.setAudio(ip, enabled: enabled);
  }

  // ---------------------------------------------------------------------------
  // Editing
  // ---------------------------------------------------------------------------

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
