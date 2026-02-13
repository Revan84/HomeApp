import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpClient {
  final http.Client _client;
  HttpClient(this._client);

  Future<Map<String, dynamic>> getJson(
    Uri uri, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final res = await _client.get(uri).timeout(timeout);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw HttpStatusException(res.statusCode, res.body);
    }
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw InvalidJsonException('Expected JSON object');
    }
    return decoded;
  }
}

class HttpStatusException implements Exception {
  final int statusCode;
  final String body;
  HttpStatusException(this.statusCode, this.body);
  @override
  String toString() => 'HttpStatusException($statusCode)';
}

class InvalidJsonException implements Exception {
  final String message;
  InvalidJsonException(this.message);
  @override
  String toString() => 'InvalidJsonException($message)';
}
