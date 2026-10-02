import 'package:flutter/foundation.dart';

import '../utils/env.dart';

/// Địa chỉ backend Spring Boot.
///
/// Thứ tự ưu tiên:
/// 1. `flutter run --dart-define=API_URL=http://192.168.1.10:8080`
/// 2. Biến `API_BASE_URL` trong file .env của app
/// 3. Mặc định theo nền tảng:
///    - Máy ảo Android: http://10.0.2.2:8080 (10.0.2.2 = localhost của máy tính)
///    - Web / iOS Simulator / Desktop: http://localhost:8080
///
/// Điện thoại thật: dùng IP LAN của máy tính chạy backend (xem bằng `ipconfig`).
class ApiConfig {
  ApiConfig._();

  static const String _dartDefineUrl = String.fromEnvironment('API_URL');

  static String get baseUrl {
    var url = _dartDefineUrl.isNotEmpty ? _dartDefineUrl : Env.apiBaseUrl;
    if (url.isEmpty) {
      if (kIsWeb) {
        url = 'http://localhost:8080';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        url = 'http://10.0.2.2:8080';
      } else {
        url = 'http://localhost:8080';
      }
    }
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }
}
