import '../../../domain/models/device_endpoint.dart';
import 'equipment.dart';

extension EquipmentEndpointX on Equipment {
  DeviceEndpoint toEndpoint() =>
      DeviceEndpoint(deviceId: id, ip: ip, channel: channel);
}
