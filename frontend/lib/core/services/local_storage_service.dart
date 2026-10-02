import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Các khoá lưu trữ cục bộ.
class StorageKeys {
  StorageKeys._();

  static const String sessionActive = 'session_active';
  static const String profile = 'profile';
  static const String preferences = 'user_preferences';
  static const String likedDishes = 'liked_dishes';
  static const String bookmarkedDishes = 'bookmarked_dishes';
  static const String savedFilters = 'saved_filters';
  static const String locale = 'locale';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String readNotifications = 'read_notifications';
  static const String deletedNotifications = 'deleted_notifications';
  static const String chatSessions = 'chat_sessions';
  static const String currentChat = 'current_chat';
  static const String authToken = 'auth_token';
  static const String chatSessionId = 'chat_session_id';
}

/// Lớp bọc SharedPreferences. Gọi [init] một lần trong main() trước runApp
/// để các ViewModel có thể đọc dữ liệu đồng bộ ngay trong constructor.
class LocalStorage {
  LocalStorage._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      _prefs = null;
    }
  }

  static bool containsKey(String key) => _prefs?.containsKey(key) ?? false;

  static String? getString(String key) => _prefs?.getString(key);

  static Future<void> setString(String key, String value) async {
    try {
      await _prefs?.setString(key, value);
    } catch (_) {}
  }

  static bool? getBool(String key) => _prefs?.getBool(key);

  static Future<void> setBool(String key, bool value) async {
    try {
      await _prefs?.setBool(key, value);
    } catch (_) {}
  }

  static List<String> getStringList(String key) => _prefs?.getStringList(key) ?? <String>[];

  static Future<void> setStringList(String key, List<String> value) async {
    try {
      await _prefs?.setStringList(key, value);
    } catch (_) {}
  }

  static dynamic getJson(String key) {
    final raw = getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? getJsonMap(String key) {
    final data = getJson(key);
    if (data is Map<String, dynamic>) return data;
    return null;
  }

  static List<dynamic> getJsonList(String key) {
    final data = getJson(key);
    if (data is List) return data;
    return <dynamic>[];
  }

  static Future<void> setJson(String key, Object value) async {
    try {
      await setString(key, jsonEncode(value));
    } catch (_) {}
  }

  static Future<void> remove(String key) async {
    try {
      await _prefs?.remove(key);
    } catch (_) {}
  }

  static Future<void> clearAll() async {
    try {
      await _prefs?.clear();
    } catch (_) {}
  }
}
