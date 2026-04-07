import 'package:flutter/foundation.dart';

import '../../../../core/network/http_client.dart';

import '../../../../domain/entities/device_endpoint.dart';
import '../../../../domain/entities/live_state.dart';
import '../../../../domain/repositories/live_device_repository.dart';

import 'dto/shelly_switch_status_dto.dart';
import 'shelly_rpc_client.dart';

class ShellyLiveDeviceRepository implements LiveDeviceRepository {
  final ShellyRpcClient _rpc;

  ShellyLiveDeviceRepository(this._rpc);

  @override
  Future<LiveState> fetch(DeviceEndpoint endpoint, LiveState previous) async {
    try {
      final json = await _rpc.getSwitchStatus(
        endpoint.ip,
        id: endpoint.channel,
      );

      final dto = ShellySwitchStatusDto.fromJson(json);

      return previous.copyWith(
        online: true,
        failCount: 0,
        output: dto.output,
        powerW: dto.apower,
        energyWh: dto.energyWh,
        rssi: dto.rssi,
        lastUpdatedAt: DateTime.now(),
      );
    } on HttpStatusException catch (error) {
      if (kDebugMode) {
        debugPrint(
          'Shelly fetch failed for ${endpoint.ip} '
          '(status ${error.statusCode}) body=${error.body}',
        );
      }

      return previous.copyWith(
        online: false,
        failCount: previous.failCount + 1,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Shelly fetch failed for ${endpoint.ip}: $error');
      }

      return previous.copyWith(
        online: false,
        failCount: previous.failCount + 1,
      );
    }
  }

  @override
  Future<void> setOutput(DeviceEndpoint endpoint, bool on) async {
    await _rpc.setSwitch(
      endpoint.ip,
      id: endpoint.channel,
      on: on,
    );
  }
}