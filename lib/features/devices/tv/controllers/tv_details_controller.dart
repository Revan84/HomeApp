import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/device/base_device_controller.dart';
import '../../../../domain/entities/tv_device.dart';
import '../../../../domain/repositories/tv_repository.dart';
import '../../../integrations/samsung/data/samsung_ws_client.dart';
import '../domain/tv_app.dart';
import '../domain/tv_remote_command.dart';

/// Manages all state and side-effects for the TV details screen.
///
/// Owns the WebSocket client lifecycle, token persistence, device editing,
/// and room data. The UI only displays state and forwards user actions.
class TvDetailsController extends BaseDeviceController {
  final TvRepository _tvRepo;
  final SamsungWsClient _client;

  TvDevice? _device;
  bool _loadingDevice;
  bool _isOn = true;

  StreamSubscription<TvConnectionState>? _connSub;
  StreamSubscription<String>? _tokenSub;
  DateTime? _lastConnectedAt;

  TvDetailsController({
    required TvRepository tvRepo,
    required super.roomRepo,
    TvDevice? initialDevice,
  })  : _tvRepo = tvRepo,
        _client = SamsungWsClient(),
        _device = initialDevice,
        _loadingDevice = initialDevice == null;

  // ── Getters ──────────────────────────────────────────────────────────────────

  TvDevice? get device => _device;
  bool get isLoading => _loadingDevice;
  bool get isOn => _isOn;
  TvConnectionState get connectionState => _client.state;
  DateTime? get lastConnectedAt => _lastConnectedAt;

  @override
  @protected
  String? get currentRoomId => _device?.roomId;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  Future<void> init(String deviceId) async {
    _connSub = _client.stateStream.listen((s) {
      if (s == TvConnectionState.connected) {
        _lastConnectedAt = DateTime.now();
      }
      notify();
    });

    _tokenSub = _client.onTokenReceived.listen((token) async {
      if (_device == null) return;
      final updated = _device!.copyWith(wsToken: token);
      await _tvRepo.update(updated);
      _device = updated;
      notify();
      await connect();
    });

    await Future.wait([
      _loadDevice(deviceId),
      _loadRooms(),
    ]);
  }

  @override
  void dispose() {
    // Cancel subscriptions before base dispose invalidates notify().
    super.dispose();
    _connSub?.cancel();
    _tokenSub?.cancel();
    _client.dispose();
  }

  Future<void> _loadRooms() async {
    await loadRooms();
    notify();
  }

  // ── Data loading ─────────────────────────────────────────────────────────────

  Future<void> _loadDevice(String deviceId) async {
    if (_device != null) {
      _loadingDevice = false;
      notify();
      await connect();
      return;
    }
    _loadingDevice = true;
    notify();
    _device = await _tvRepo.loadById(deviceId);
    _loadingDevice = false;
    notify();
    if (_device != null) await connect();
  }

  // ── Connection ───────────────────────────────────────────────────────────────

  Future<void> connect() async {
    final d = _device;
    if (d == null) return;
    await _client.connect(d.ipAddress, savedToken: d.wsToken);
  }

  // ── Commands ─────────────────────────────────────────────────────────────────

  void sendCommand(TvRemoteCommand cmd) => _client.sendKey(cmd);

  void launchApp(TvApp app) => _client.launchApp(app.samsungAppId);

  void sendText(String text) => _client.sendText(text);

  void togglePower(bool value) {
    _isOn = value;
    notify();
    _client.sendKey(value ? TvRemoteCommand.powerOn : TvRemoteCommand.powerOff);
  }

  // ── Editing ──────────────────────────────────────────────────────────────────

  Future<void> updateName(String name) async {
    if (_device == null) return;
    final updated = _device!.copyWith(name: name);
    await _tvRepo.update(updated);
    _device = updated;
    notify();
  }

  Future<void> updateIp(String ip) async {
    if (_device == null) return;
    final updated = _device!.copyWith(ipAddress: ip);
    await _tvRepo.update(updated);
    _device = updated;
    notify();
    await connect();
  }

  Future<void> toggleFavorite() async {
    if (_device == null) return;
    final updated = _device!.copyWith(isFavorite: !_device!.isFavorite);
    await _tvRepo.update(updated);
    _device = updated;
    notify();
  }

  Future<void> updateRoom(String? roomId) async {
    if (_device == null) return;
    final updated = _device!.copyWith(roomId: roomId);
    await _tvRepo.update(updated);
    _device = updated;
    notify();
  }

  Future<void> delete() async {
    if (_device == null) return;
    await _tvRepo.deleteById(_device!.id);
  }
}
