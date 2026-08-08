import 'package:http/http.dart' as http;

import '../../../../domain/entities/camera_brand.dart';
import 'camera_api_client.dart';
import 'generic_camera_api_client.dart';

/// Resolves the correct [CameraApiClient] for a given [CameraBrand].
///
/// Each implementation is constructed once and cached for the lifetime of
/// the factory — API clients are stateless and IP-agnostic.
///
/// To add a brand: register a new implementation in [_clients] and add the
/// corresponding [CameraBrand] value. The factory throws [UnsupportedError]
/// for unknown brands so the omission is caught at development time.
class CameraApiClientFactory {
  CameraApiClientFactory(this._http);

  final http.Client _http;

  late final Map<CameraBrand, CameraApiClient> _clients = {
    CameraBrand.generic: GenericCameraApiClient(_http),
  };

  /// Returns the [CameraApiClient] for [brand].
  ///
  /// Throws [UnsupportedError] if no implementation has been registered.
  CameraApiClient forBrand(CameraBrand brand) {
    final client = _clients[brand];
    if (client == null) {
      throw UnsupportedError(
        'No CameraApiClient registered for brand: $brand. '
        'Add the implementation in CameraApiClientFactory.',
      );
    }
    return client;
  }
}
