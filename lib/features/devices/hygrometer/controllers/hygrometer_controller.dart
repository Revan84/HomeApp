import '../../../../core/device/base_equipment_controller.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../data/mappers/equipment_mapper.dart';
import '../../../../domain/entities/history_window.dart';
import '../../../../domain/entities/live_point.dart';
import '../../../../domain/entities/live_state.dart';
import '../../../../domain/entities/sensor_alert.dart';
import '../../../live/controllers/live_polling_controller.dart';

/// Controller for the hygrometer detail screen.
class HygrometerController extends BaseEquipmentController {
  final LivePollingController _live;
  final LocalStorage _storage;
  List<SensorAlert> _alerts = const [];

  HygrometerController({
    required super.equipment,
    required super.equipmentRepo,
    required super.roomRepo,
    required LivePollingController live,
    required LocalStorage storage,
  })  : _live = live,
        _storage = storage {
    Future.microtask(_init);
  }

  // ── Getters ──────────────────────────────────────────────────────────────────

  List<SensorAlert> get alerts => List.unmodifiable(_alerts);

  /// Current live sensor state, or null if no data has arrived yet.
  LiveState? get liveState => _live.live[equipment.id];

  // ── Init ─────────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    _live.syncFollowed([equipment.toEndpoint()], forcePollNow: true);
    await Future.wait([
      loadRooms(),
      _loadAlerts(),
    ]);
    notify();
  }

  // ── Refresh ──────────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    await _live.pollDeviceNow(equipment.toEndpoint());
  }

  // ── History ──────────────────────────────────────────────────────────────────

  /// Returns the humidity history for the given time window.
  /// The live_point powerW field carries the humidity % value.
  List<LivePoint> historyOf(HistoryWindow window) {
    try {
      return _live.historyFor(equipment.id, window);
    } catch (_) {
      return const [];
    }
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  Future<void> delete() async {
    await deleteFromRepo();
    _live.unfollowDevice(equipment.id);
    await _live.deleteHistoryForDevice(equipment.id);
  }

  // ── Alerts ───────────────────────────────────────────────────────────────────

  Future<void> _loadAlerts() async {
    final raw =
        await _storage.getString(StorageKeys.sensorAlerts(equipment.id));
    if (raw != null && raw.isNotEmpty) {
      try {
        _alerts = SensorAlert.listFromJson(raw);
      } catch (_) {
        _alerts = const [];
      }
    }
  }

  Future<void> _saveAlerts() async {
    await _storage.setString(
      StorageKeys.sensorAlerts(equipment.id),
      SensorAlert.listToJson(_alerts),
    );
  }

  Future<void> addAlert(SensorAlert alert) async {
    _alerts = [..._alerts, alert];
    await _saveAlerts();
    notify();
  }

  Future<void> removeAlert(String alertId) async {
    _alerts = _alerts.where((a) => a.id != alertId).toList();
    await _saveAlerts();
    notify();
  }

  Future<void> toggleAlert(String alertId) async {
    _alerts = _alerts
        .map((a) => a.id == alertId ? a.copyWith(isEnabled: !a.isEnabled) : a)
        .toList();
    await _saveAlerts();
    notify();
  }
}
