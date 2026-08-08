import 'dart:developer' as dev;

import '../../../../core/device/base_device_controller.dart';
import '../../../../domain/entities/connected_camera_device.dart';
import '../../../../domain/repositories/connected_camera_repository.dart';
import '../../../integrations/cameras/data/camera_api_client.dart';
import '../../../integrations/cameras/data/camera_api_client_factory.dart';

/// Controller for the Connected Camera device detail screen.
///
/// Manages device metadata, polymorphic API probing, and live refresh.
/// Real RTSP stream player is deferred to PR-2.
class ConnectedCameraController extends BaseDeviceController {
  ConnectedCameraController({
    required ConnectedCameraRepository repo,
    required super.roomRepo,
    required CameraApiClientFactory apiClientFactory,
    ConnectedCameraDevice? initialDevice,
  })  : _repo = repo,
        _apiClientFactory = apiClientFactory,
        _device =
            initialDevice ??
            const ConnectedCameraDevice(id: '', name: '', ipAddress: '') {
    Future.microtask(() => _init());
  }

  final ConnectedCameraRepository _repo;
  final CameraApiClientFactory _apiClientFactory;

  ConnectedCameraDevice _device;

  /// null = probe not yet run; true = reachable; false = unreachable.
  bool? _isOnlineProbed;

  // Why: resolved lazily each call so that if `_device` is ever replaced
  // (e.g. after loadById) the correct brand client is always returned.
  CameraApiClient get _api => _apiClientFactory.forBrand(_device.brand);

  // ── Getters ──────────────────────────────────────────────────────────────────

  ConnectedCameraDevice get device => _device;

  /// null = probe pending; true = reachable; false = unreachable.
  bool? get isOnlineProbed => _isOnlineProbed;

  @override
  String? get currentRoomId => _device.roomId;

  // ── Initialisation ───────────────────────────────────────────────────────────

  Future<void> _init() async {
    if (_device.id.isNotEmpty) {
      final loaded = await _repo.loadById(_device.id);
      if (loaded != null) _device = loaded;
    }
    await Future.wait([loadRooms(), _probe()]);
    notify();
  }

  Future<void> _probe() async {
    try {
      final ok = await _api.testConnection(
        ip: _device.ipAddress,
        httpApiPort: _device.httpApiPort,
        username: _device.cameraAccountUser.isEmpty
            ? null
            : _device.cameraAccountUser,
        password: _device.cameraAccountPassword.isEmpty
            ? null
            : _device.cameraAccountPassword,
      );
      _isOnlineProbed = ok;
    } catch (e, st) {
      dev.log(
        'ConnectedCameraController._probe failed for ${_device.ipAddress}',
        error: e,
        stackTrace: st,
      );
      _isOnlineProbed = false;
    }
  }

  /// Re-probes the camera and fetches fresh model/firmware, persisting any
  /// new info so the detail screen reflects the latest state.
  Future<void> refresh() async {
    _isOnlineProbed = null;
    notify();
    try {
      final ok = await _api.testConnection(
        ip: _device.ipAddress,
        httpApiPort: _device.httpApiPort,
        username: _device.cameraAccountUser.isEmpty
            ? null
            : _device.cameraAccountUser,
        password: _device.cameraAccountPassword.isEmpty
            ? null
            : _device.cameraAccountPassword,
      );
      _isOnlineProbed = ok;
      if (ok) {
        final info = await _api.getInfo(
          ip: _device.ipAddress,
          httpApiPort: _device.httpApiPort,
          username: _device.cameraAccountUser.isEmpty
              ? null
              : _device.cameraAccountUser,
          password: _device.cameraAccountPassword.isEmpty
              ? null
              : _device.cameraAccountPassword,
        );
        if (info.model.isNotEmpty || info.firmware.isNotEmpty) {
          final updated = _device.copyWith(
            modelName: info.model.isEmpty ? _device.modelName : info.model,
            firmwareVersion:
                info.firmware.isEmpty ? _device.firmwareVersion : info.firmware,
          );
          await _repo.update(updated);
          _device = updated;
        }
      }
    } catch (e, st) {
      dev.log(
        'ConnectedCameraController.refresh failed for ${_device.ipAddress}',
        error: e,
        stackTrace: st,
      );
      _isOnlineProbed = false;
    }
    notify();
  }

  // ── Metadata edits ───────────────────────────────────────────────────────────

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
