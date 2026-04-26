import 'dart:async' show unawaited;

import '../../../domain/entities/tv_device.dart';
import '../../../domain/repositories/tv_repository.dart';
import '../../devices/tv/domain/tv_remote_command.dart';
import '../../integrations/samsung/data/samsung_ws_client.dart';

class HomeTvHandler {
  final TvRepository _tvRepo;
  final void Function() _notify;

  HomeTvHandler({required TvRepository tvRepo, required void Function() notify})
      : _tvRepo = tvRepo,
        _notify = notify;

  final Map<String, bool> _isOn = {};
  final Map<String, SamsungWsClient> _clients = {};

  bool isOn(String id) => _isOn[id] ?? true;

  Future<void> sendCommand(TvDevice device, TvRemoteCommand cmd) async {
    if (cmd == TvRemoteCommand.powerOn) {
      _isOn[device.id] = true;
      _notify();
    } else if (cmd == TvRemoteCommand.powerOff) {
      _isOn[device.id] = false;
      _notify();
    }

    var client = _clients[device.id];
    if (client == null) {
      client = SamsungWsClient();
      _clients[device.id] = client;
      client.onTokenReceived.listen((token) async {
        final updated = device.copyWith(wsToken: token);
        await _tvRepo.update(updated);
      });
    }

    if (client.state != TvConnectionState.connected) {
      await client.connect(device.ipAddress, savedToken: device.wsToken);
    }
    client.sendKey(cmd);
  }

  void dispose() {
    for (final client in _clients.values) {
      unawaited(client.disconnect());
      client.dispose();
    }
  }
}
