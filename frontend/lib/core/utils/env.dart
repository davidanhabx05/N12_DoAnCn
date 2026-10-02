import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Đọc biến trong file .env của app (không crash nếu file chưa được load).
/// Lưu ý: các API key (Gemini, Google Places) giờ nằm ở BACKEND, app không giữ key nào.
class Env {
  Env._();

  static String get(String key) {
    try {
      return (dotenv.env[key] ?? '').trim();
    } catch (_) {
      return '';
    }
  }

  /// Địa chỉ backend, vd: http://192.168.1.10:8080 (để trống -> tự chọn theo nền tảng).
  static String get apiBaseUrl => get('API_BASE_URL');
}
