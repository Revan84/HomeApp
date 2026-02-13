import 'package:flutter/foundation.dart';
import '../../../../domain/models/device_endpoint.dart';
import '../../../../domain/models/live_state.dart';
import '../../../../domain/repositories/live_device_repository.dart';
import 'dto/shelly_switch_status_dto.dart';
import 'shelly_rpc_client.dart';

class ShellyLiveDeviceRepository implements LiveDeviceRepository {
  final ShellyRpcClient _rpc;
  ShellyLiveDeviceRepository(this._rpc);

  @override
  Future<LiveState> fetch(DeviceEndpoint endpoint, LiveState previous) async {
    try {
      final json = await _rpc.getSwitchStatus(endpoint.ip, id: endpoint.channel);
      final dto = ShellySwitchStatusDto.fromJson(json);

      final prevPower = previous.powerW;
      final nextPower = dto.apower;

      final trend = (prevPower != null && nextPower != null)
          ? (nextPower > prevPower ? 1 : (nextPower < prevPower ? -1 : 0))
          : 0;

      return previous.copyWith(
        online: true,
        failCount: 0,
        output: dto.output,
        powerW: dto.apower,
        energyWh: dto.energyWh,
        rssi: dto.rssi,
        trendPower: trend,
        lastUpdatedAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Shelly fetch failed: $e');
      }
      return previous.copyWith(
        online: false,
        failCount: previous.failCount + 1,
      );
    }
  }

  @override
  Future<void> setOutput(DeviceEndpoint endpoint, bool on) async {
    await _rpc.setSwitch(endpoint.ip, id: endpoint.channel, on: on);
  }
}
