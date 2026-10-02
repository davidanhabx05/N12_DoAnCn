import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../services/local_storage_service.dart';
import 'api_config.dart';

/// Lỗi khi gọi backend. [statusCode] = null nghĩa là không kết nối được máy chủ.
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException(this.message, {this.statusCode});

  bool get isNetworkError => statusCode == null;
  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Lớp gọi REST API của backend (JSON). Tự gắn header
/// `Authorization: Bearer <token>` sau khi đăng nhập.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final http.Client _http = http.Client();
  String? _token;

  /// Tăng mỗi khi đăng nhập / đăng xuất -> các ViewModel lắng nghe để tải lại dữ liệu.
  final ValueNotifier<int> sessionVersion = ValueNotifier<int>(0);

  /// Đọc token đã lưu (gọi trong main() sau LocalStorage.init()).
  void init() {
    final saved = LocalStorage.getString(StorageKeys.authToken);
    _token = (saved == null || saved.isEmpty) ? null : saved;
  }

  bool get hasSession => _token != null;

  String get baseUrl => ApiConfig.baseUrl;

  Future<void> setToken(String? token) async {
    _token = (token == null || token.isEmpty) ? null : token;
    if (_token == null) {
      await LocalStorage.remove(StorageKeys.authToken);
    } else {
      await LocalStorage.setString(StorageKeys.authToken, _token!);
    }
    sessionVersion.value++;
  }

  // ------------------------------------------------------------------ HTTP
  Future<dynamic> get(String path, {Map<String, dynamic>? query, Duration? timeout}) =>
      _send('GET', path, query: query, timeout: timeout);

  Future<dynamic> post(String path, {Object? body, Duration? timeout}) =>
      _send('POST', path, body: body, timeout: timeout);

  Future<dynamic> put(String path, {Object? body}) => _send('PUT', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Duration? timeout,
  }) async {
    final params = <String, String>{};
    query?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) params[key] = value.toString();
    });
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: params.isEmpty ? null : params);

    final request = http.Request(method, uri);
    request.headers['Accept'] = 'application/json';
    if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }

    http.Response response;
    try {
      final streamed = await _http.send(request).timeout(timeout ?? const Duration(seconds: 20));
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw ApiException('Máy chủ phản hồi quá lâu ($baseUrl). Vui lòng thử lại.');
    } catch (e) {
      debugPrint('API $method $uri lỗi: $e');
      throw ApiException(
        'Không kết nối được máy chủ ($baseUrl).\n'
        'Hãy kiểm tra backend đã chạy và địa chỉ API_BASE_URL đúng chưa.',
      );
    }

    final text = utf8.decode(response.bodyBytes);
    dynamic data;
    if (text.isNotEmpty) {
      try {
        data = jsonDecode(text);
      } catch (_) {
        data = text;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) return data;

    final message = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : 'Lỗi máy chủ (${response.statusCode})';
    throw ApiException(message, statusCode: response.statusCode);
  }
}
