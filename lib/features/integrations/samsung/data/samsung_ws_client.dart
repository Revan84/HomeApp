import 'dart:async';
import 'dart:convert';
import 'dart:io' show HttpClient, WebSocket;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../devices/tv/domain/tv_remote_command.dart';
import 'samsung_key_mapper.dart';

/// Connection state exposed to the UI.
enum TvConnectionState { disconnected, connecting, connected }

/// WebSocket client for Samsung Tizen Smart TVs (remote control + app launch).
///
/// Remote keys are sent via WebSocket (ms.remote.control).
/// App launching uses the Samsung REST API on port 8001
/// (`POST /api/v2/applications/{appId}`) — the only reliable method on
/// Tizen 2022 Q-series TVs.
///
/// On first pairing the TV returns a token that must be persisted and
/// sent on subsequent connections so the TV skips authorization.
class SamsungWsClient {
  static const _timeout = Duration(seconds: 5);
  static const _appName = 'FlutterIoTRemote';

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  TvConnectionState _state = TvConnectionState.disconnected;
  TvConnectionState get state => _state;

  String? _ip;
  String? get ip => _ip;

  String? _token;
  String? get token => _token;

  final _stateController = StreamController<TvConnectionState>.broadcast();
  Stream<TvConnectionState> get stateStream => _stateController.stream;

  /// Fires when a new pairing token is received — persist it in [TvDevice.wsToken].
  final _tokenController = StreamController<String>.broadcast();
  Stream<String> get onTokenReceived => _tokenController.stream;

  static String get _encodedName => base64Encode(utf8.encode(_appName));

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Connects to the TV. Includes [savedToken] in the URL if available so
  /// the TV recognises the client and skips the authorisation prompt.
  Future<bool> connect(String ip, {String? savedToken}) async {
    await disconnect();
    _ip = ip;
    _token = savedToken;
    _setState(TvConnectionState.connecting);

    final tokenParam =
        (savedToken != null && savedToken.isNotEmpty) ? '&token=$savedToken' : '';

    final uris = [
      'wss://$ip:8002/api/v2/channels/samsung.remote.control?name=$_encodedName$tokenParam',
      'ws://$ip:8001/api/v2/channels/samsung.remote.control?name=$_encodedName$tokenParam',
    ];

    for (final uri in uris) {
      try {
        final channel = await _connectTo(uri);
        _channel = channel;
        _listenForMessages();
        _setState(TvConnectionState.connected);
        return true;
      } catch (_) {
        // Try next URI
      }
    }

    _setState(TvConnectionState.disconnected);
    return false;
  }

  /// Sends a remote key command via WebSocket.
  void sendKey(TvRemoteCommand cmd) {
    if (_state != TvConnectionState.connected || _channel == null) return;

    final payload = jsonEncode({
      'method': 'ms.remote.control',
      'params': {
        'Cmd': 'Click',
        'DataOfCmd': samsungKeyFor(cmd),
        'Option': 'false',
        'TypeOfRemote': 'SendRemoteKey',
      },
    });

    _channel!.sink.add(payload);
  }

  /// Launches a TV app via HTTP POST to the Samsung REST API (port 8001).
  Future<void> launchApp(String samsungAppId, {String? launchKey}) async {
    if (_ip == null) return;
    final url = 'http://$_ip:8001/api/v2/applications/$samsungAppId';
    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 3);
      final request = await client.postUrl(Uri.parse(url));
      // Fire-and-forget — the TV may return a non-standard response (e.g. Canal+)
      await request.close().timeout(const Duration(seconds: 3));
      client.close();
    } catch (_) {
      // Ignore HTTP errors: the TV may still launch the app (e.g. malformed
      // response on certain Canal+ firmwares).
    }
  }

  /// Sends a text string to the TV (e.g. into a focused search field).
  /// Samsung TVs accept base64-encoded text via SendInputString.
  void sendText(String text) {
    if (_state != TvConnectionState.connected || _channel == null) return;
    if (text.isEmpty) return;

    final encoded = base64Encode(utf8.encode(text));
    final payload = jsonEncode({
      'method': 'ms.remote.control',
      'params': {
        'Cmd': encoded,
        'DataOfCmd': encoded,
        'TypeOfRemote': 'SendInputString',
      },
    });

    _channel!.sink.add(payload);
  }

  /// Disconnects from the TV.
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
    _setState(TvConnectionState.disconnected);
  }

  void dispose() {
    disconnect();
    _stateController.close();
    _tokenController.close();
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<WebSocketChannel> _connectTo(String uri) async {
    final httpClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    final ws = await WebSocket.connect(
      uri,
      customClient: httpClient,
    ).timeout(_timeout);

    return IOWebSocketChannel(ws);
  }

  void _listenForMessages() {
    _subscription = _channel?.stream.listen(
      _tryExtractToken,
      onError: (_) => _handleDisconnect(),
      onDone: _handleDisconnect,
    );
  }

  /// Samsung TVs send the pairing token in one of two locations:
  ///   A) data.token                          (older firmware)
  ///   B) data.clients[0].attributes.token   (Q-series 2020+)
  void _tryExtractToken(dynamic message) {
    if (message is! String) return;
    try {
      final json = jsonDecode(message) as Map<String, dynamic>;
      final data = json['data'];
      if (data is! Map<String, dynamic>) return;

      String? newToken = data['token'] as String?;

      if (newToken == null || newToken.isEmpty) {
        final clients = data['clients'];
        if (clients is List && clients.isNotEmpty) {
          final attrs = clients.first['attributes'];
          if (attrs is Map) newToken = attrs['token'] as String?;
        }
      }

      if (newToken != null && newToken.isNotEmpty && newToken != _token) {
        _token = newToken;
        if (!_tokenController.isClosed) _tokenController.add(newToken);
      }
    } catch (_) {}
  }

  void _handleDisconnect() {
    _channel = null;
    _subscription = null;
    _setState(TvConnectionState.disconnected);
  }

  void _setState(TvConnectionState s) {
    if (_state == s) return;
    _state = s;
    if (!_stateController.isClosed) _stateController.add(s);
  }
}
