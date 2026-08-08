import 'package:http/http.dart' as http;

import '../../../../domain/entities/camera_brand.dart';
import 'camera_api_client.dart';

/// Brand-agnostic camera client used until a specific brand implementation
/// is available.
///
/// [testConnection] performs a plain HTTP GET to confirm something is listening
/// on [httpApiPort] — any HTTP response (including 401) counts as reachable.
/// [getInfo] always returns empty strings; populate this in a brand PR.
/// [buildStreamUrl] generates a generic RTSP URL with no path conventions.
class GenericCameraApiClient implements CameraApiClient {
  GenericCameraApiClient(this._http);

  final http.Client _http;

  static const _timeout = Duration(seconds: 3);

  @override
  CameraBrand get brand => CameraBrand.generic;

  @override
  Future<bool> testConnection({
    required String ip,
    required int httpApiPort,
    String? username,
    String? password,
  }) async {
    try {
      // Why: any HTTP response (including 401 Unauthorized) means a camera
      // or web server is listening at this address. Brand-specific clients
      // will replace this with a protocol-level handshake.
      final res = await _http
          .get(Uri.parse('http://$ip:$httpApiPort/'))
          .timeout(_timeout);
      return res.statusCode > 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<({String model, String firmware})> getInfo({
    required String ip,
    required int httpApiPort,
    String? username,
    String? password,
  }) async {
    // Why: no generic way to fetch model/firmware without a brand protocol.
    // Brand-specific PRs will override this.
    return (model: '', firmware: '');
  }

  @override
  String? buildStreamUrl({
    required String ip,
    required int rtspPort,
    required String username,
    required String password,
    bool subStream = false,
  }) {
    if (username.isEmpty || password.isEmpty) return null;
    // Why: generic RTSP URL without a brand-specific path. Brand PRs will
    // replace this with the correct path convention (e.g. Reolink's
    // h264Preview_01_main, Tapo's stream1, etc.).
    final encUser = Uri.encodeComponent(username);
    final encPass = Uri.encodeComponent(password);
    return 'rtsp://$encUser:$encPass@$ip:$rtspPort/stream';
  }
}
