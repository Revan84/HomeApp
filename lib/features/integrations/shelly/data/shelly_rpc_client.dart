import '../../../../core/network/http_client.dart';

class ShellyRpcClient {
  final HttpClient _http;
  ShellyRpcClient(this._http);

  Future<Map<String, dynamic>> getSwitchStatus(String ip, {int id = 0}) async {
    final uri = Uri.parse('http://$ip/rpc/Switch.GetStatus?id=$id');
    return _http.getJson(uri, timeout: const Duration(seconds: 2));
  }

  Future<void> setSwitch(String ip, {int id = 0, required bool on}) async {
    final uri = Uri.parse('http://$ip/rpc/Switch.Set?id=$id&on=$on');
    await _http.getJson(uri, timeout: const Duration(seconds: 2));
  }

  Future<Map<String, dynamic>> getDeviceInfo(String ip) async {
    final uri = Uri.parse('http://$ip/rpc/Shelly.GetDeviceInfo');
    return _http.getJson(uri, timeout: const Duration(seconds: 2));
  }
}
