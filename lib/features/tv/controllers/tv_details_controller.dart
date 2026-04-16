import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../domain/entities/room.dart';
import '../../../domain/entities/tv_device.dart';
import '../../../domain/repositories/room_repository.dart';
import '../../../domain/repositories/tv_repository.dart';
import '../../integrations/samsung/data/samsung_ws_client.dart';
import '../domain/tv_app.dart';
import '../domain/tv_remote_command.dart';

/// Manages all state and side-effects for the TV details screen.
///
/// Owns the WebSocket client lifecycle, token persistence, device editing,
/// and room data. The UI only displays state and forwards user actions.
class TvDetailsController extends ChangeNotifier {
  final TvRepository _tvRepo;
  final RoomRepository _roomRepo;
  final SamsungWsClient _client;

  TvDetailsController({
    required TvRepository tvRepo,
    required RoomRepository roomRepo,
  })  : _tvRepo = tvRepo,
        _roomRepo = roomRepo,
        _client = SamsungWsClient();

  TvDevice? _device;
  TvDevice? get device => _device;

  List<Room> _rooms = const [];
  List<Room> get rooms => _rooms;

  bool _loadingDevice = true;
  bool get isLoading => _loadingDevice;

  bool _isOn = true;
  bool get isOn => _isOn;

  TvConnectionState get connectionState => _client.state;

  DateTime? _lastConnectedAt;
  DateTime? get lastConnectedAt => _lastConnectedAt;

  StreamSubscription<TvConnectionState>? _connSub;
  StreamSubscription<String>? _tokenSub;

  bool _disposed = false;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  Future<void> init(String deviceId) async {
    _connSub = _client.stateStream.listen((s) {
      if (s == TvConnectionState.connected) {
        _lastConnectedAt = DateTime.now();
      }
      _notify();
    });

    _tokenSub = _client.onTokenReceived.listen((token) async {
      if (_device == null) return;
      final updated = _device!.copyWith(wsToken: token);
      await _tvRepo.update(updated);
      _device = updated;
      _notify();
      await connect();
    });

    await Future.wait([
      _loadDevice(deviceId),
      _loadRooms(),
    ]);
  }

  @override
  void dispose() {
    _disposed = true;
    _connSub?.cancel();
    _tokenSub?.cancel();
    _client.dispose();
    super.dispose();
  }

  /// Safe notifyListeners — no-op if the controller has already been disposed.
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadDevice(String deviceId) async {
    _loadingDevice = true;
    _notify();
    _device = await _tvRepo.loadById(deviceId);
    _loadingDevice = false;
    _notify();
    if (_device != null) await connect();
  }

  Future<void> _loadRooms() async {
    _rooms = await _roomRepo.loadAll();
    _notify();
  }

  // ---------------------------------------------------------------------------
  // Connection
  // ---------------------------------------------------------------------------

  Future<void> connect() async {
    final d = _device;
    if (d == null) return;
    await _client.connect(d.ipAddress, savedToken: d.wsToken);
  }

  // ---------------------------------------------------------------------------
  // Commands
  // ---------------------------------------------------------------------------

  void sendCommand(TvRemoteCommand cmd) => _client.sendKey(cmd);

  void launchApp(TvApp app) => _client.launchApp(app.samsungAppId);

  void sendText(String text) => _client.sendText(text);

  void togglePower(bool value) {
    _isOn = value;
    _notify();
    _client.sendKey(value ? TvRemoteCommand.powerOn : TvRemoteCommand.powerOff);
  }

  // ---------------------------------------------------------------------------
  // Editing
  // ---------------------------------------------------------------------------

  Future<void> updateName(String name) async {
    if (_device == null) return;
    final updated = _device!.copyWith(name: name);
    await _tvRepo.update(updated);
    _device = updated;
    _notify();
  }

  Future<void> updateIp(String ip) async {
    if (_device == null) return;
    final updated = _device!.copyWith(ipAddress: ip);
    await _tvRepo.update(updated);
    _device = updated;
    _notify();
    await connect();
  }

  Future<void> toggleFavorite() async {
    if (_device == null) return;
    final updated = _device!.copyWith(isFavorite: !_device!.isFavorite);
    await _tvRepo.update(updated);
    _device = updated;
    _notify();
  }

  Future<void> updateRoom(String? roomId) async {
    if (_device == null) return;
    final updated = _device!.copyWith(roomId: roomId);
    await _tvRepo.update(updated);
    _device = updated;
    _notify();
  }

  Future<void> delete() async {
    if (_device == null) return;
    await _tvRepo.deleteById(_device!.id);
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
