import 'dart:convert';

import 'package:http/http.dart' as http;
import '../constants/api.dart';

/// Mirrors the backend's error envelope (docs/05-api.md §2.1):
/// `{ "error": { "code": "...", "message": "..." } }`.
class ApiException implements Exception {
  ApiException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'ApiException($code): $message';
}

class ApiClient {
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? apiBaseUrl;

  final String baseUrl;
  String? _accessToken;

  void setAccessToken(String? token) => _accessToken = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Future<dynamic> get(String path) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
    return _decode(res);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _decode(res) as Map<String, dynamic>;
  }

  dynamic _decode(http.Response res) {
    final body = res.bodyBytes.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    final error = body is Map ? body['error'] as Map<String, dynamic>? : null;
    throw ApiException(
      error?['code'] as String? ?? 'UNKNOWN',
      error?['message'] as String? ?? '요청에 실패했습니다.',
    );
  }
}

/// Shared instance so an access token set once (after sign-in) is visible
/// to every API call across the app.
final apiClient = ApiClient();
