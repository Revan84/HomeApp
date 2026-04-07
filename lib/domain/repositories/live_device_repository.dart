import '../entities/device_endpoint.dart';
import '../entities/live_state.dart';

abstract class LiveDeviceRepository {
  Future<LiveState> fetch(DeviceEndpoint endpoint, LiveState previous);
  Future<void> setOutput(DeviceEndpoint endpoint, bool on);
}
