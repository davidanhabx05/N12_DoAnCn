import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/services/firebase_service.dart';
import '../core/services/local_storage_service.dart';
import '../core/utils/image_utils.dart';
import '../models/user_preferences.dart';

enum LoginResult { success, cancelled, demo, failed }

/// Hồ sơ người dùng. Dữ liệu gốc nằm ở backend (PostgreSQL); bản sao được lưu
/// trên máy để mở app là hiển thị ngay, sau đó đồng bộ lại từ server.
class ProfileViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final ApiClient _api = ApiClient.instance;

  static const String _defaultName = 'Người dùng Foodie';
  static const String _defaultBio = 'Yêu thích nấu ăn và khám phá ẩm thực Việt Nam.';

  UserPreferences _preferences = UserPreferences();
  String _displayName = _defaultName;
  String _bio = _defaultBio;
  String _avatarUrl = ImageUtils.defaultAvatar;
  String? _email;
  bool _isGuest = false;
  String? _lastError;
  bool _isSyncing = false;

  /// Tăng mỗi khi hồ sơ ăn uống trên SERVER thay đổi -> Trang chủ tải lại gợi ý.
  int _preferencesVersion = 0;

  ProfileViewModel() {
    _loadLocal();
    if (_api.hasSession) refresh();
  }

  String get displayName => _displayName;
  String get bio => _bio;
  String get avatarUrl => _avatarUrl;
  String? get lastError => _lastError;
  bool get isGuest => _isGuest;
  bool get isSyncing => _isSyncing;
  int get preferencesVersion => _preferencesVersion;

  UserPreferences get preferences => _preferences;

  // --------------------------------------------------------- Sức khoẻ
  // (Backend tính giống hệt; giữ ở app để xem trước ngay khi đang nhập form.)
  static double? calculateBmi(double? weight, double? height) {
    if (weight == null || height == null || height <= 0 || weight <= 0) return null;
    final hMeter = height / 100;
    return weight / (hMeter * hMeter);
  }

  static String bmiCategoryOf(double? value) {
    if (value == null) return "Chưa có dữ liệu";
    if (value < 18.5) return "Thiếu cân";
    if (value < 25) return "Cân đối";
    if (value < 30) return "Thừa cân";
    return "Béo phì";
  }

  /// Công thức Mifflin-St Jeor x hệ số vận động.
  static int? calculateTdee({
    double? weight,
    double? height,
    int? birthYear,
    String? gender,
    String? activityLevel,
  }) {
    if (weight == null || height == null || birthYear == null || gender == null || activityLevel == null) {
      return null;
    }
    final age = DateTime.now().year - birthYear;
    if (age <= 0 || age > 120) return null;

    final double bmr;
    if (gender == 'Nam') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else if (gender == 'Nữ') {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 78;
    }

    double factor;
    switch (activityLevel) {
      case 'Vận động nhẹ':
        factor = 1.375;
        break;
      case 'Vận động vừa phải':
        factor = 1.55;
        break;
      case 'Năng động':
        factor = 1.725;
        break;
      case 'Rất năng động':
        factor = 1.9;
        break;
      default:
        factor = 1.2;
    }
    return (bmr * factor).round();
  }

  double? get bmi => calculateBmi(_preferences.weight, _preferences.height);

  String get bmiCategory => bmiCategoryOf(bmi);

  int? get tdee => calculateTdee(
        weight: _preferences.weight,
        height: _preferences.height,
        birthYear: _preferences.birthYear,
        gender: _preferences.gender,
        activityLevel: _preferences.activityLevel,
      );

  // ---------------------------------------------------------- Hồ sơ
  /// Cập nhật ngay trên màn hình rồi lưu lên server.
  void updateProfile({String? name, String? bio, String? avatar}) {
    if (name != null && name.trim().isNotEmpty) _displayName = name.trim();
    if (bio != null) _bio = bio.trim();
    if (avatar != null && avatar.isNotEmpty) _avatarUrl = avatar;
    _saveLocal();
    notifyListeners();

    _api.put('/api/me/profile', body: {
      'displayName': _displayName,
      'bio': _bio,
      'avatarUrl': _avatarUrl,
    }).then((data) {
      if (data is Map<String, dynamic>) _applyProfile(data);
    }).catchError((Object e) {
      _setError(e);
    });
  }

  void updatePreferences(UserPreferences newPrefs) {
    _preferences = newPrefs;
    _saveLocal();
    notifyListeners();

    _api.put('/api/me/preferences', body: newPrefs.toMap()).then((data) {
      if (data is Map<String, dynamic>) _applyProfile(data, forcePreferencesChanged: true);
    }).catchError((Object e) {
      _setError(e);
    });
  }

  bool get isLoggedIn => _api.hasSession && !_isGuest;
  String? get userEmail => _email ?? _firebaseService.userEmail;

  /// Đã đăng nhập (kể cả khách) ở lần trước -> mở thẳng Trang chủ.
  static bool get hasActiveSession => ApiClient.instance.hasSession;

  // Real-time stats
  final int _basePostCount = 12;
  final int _totalLikes = 1540;

  int get postCount => _basePostCount + _userPostsCount;
  int get totalLikes => _totalLikes;

  int _userPostsCount = 0;
  void syncUserPostsCount(int count) {
    _userPostsCount = count;
    notifyListeners();
  }

  // ------------------------------------------------------ Đồng bộ server
  /// Tải lại hồ sơ từ server (GET /api/me).
  Future<void> refresh() async {
    if (!_api.hasSession) return;
    _isSyncing = true;
    try {
      final data = await _api.get('/api/me');
      if (data is Map<String, dynamic>) _applyProfile(data);
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        // Token hết hạn / tài khoản đã bị xoá trên server
        await _api.setToken(null);
      }
      _setError(e);
    } finally {
      _isSyncing = false;
    }
  }

  void _applyProfile(Map<String, dynamic> json, {bool forcePreferencesChanged = false}) {
    _displayName = json['displayName']?.toString() ?? _displayName;
    _bio = json['bio']?.toString() ?? _bio;
    final avatar = json['avatarUrl']?.toString();
    _avatarUrl = (avatar == null || avatar.isEmpty) ? ImageUtils.defaultAvatar : avatar;
    _email = json['email']?.toString();
    _isGuest = json['isGuest'] == true;

    final prefsJson = json['preferences'];
    if (prefsJson is Map<String, dynamic>) {
      final newPrefs = UserPreferences.fromMap(prefsJson);
      final changed = jsonEncode(newPrefs.toMap()) != jsonEncode(_preferences.toMap());
      _preferences = newPrefs;
      if (changed || forcePreferencesChanged) _preferencesVersion++;
    }
    _lastError = null;
    _saveLocal();
    notifyListeners();
  }

  void _setError(Object e) {
    _lastError = e.toString();
    debugPrint('ProfileViewModel: $_lastError');
    notifyListeners();
  }

  // ------------------------------------------------------ Đăng nhập
  Future<LoginResult> loginWithGoogle() async {
    _lastError = null;
    try {
      // Máy chưa cấu hình Firebase (vd: Web chưa có firebase_options) -> tài khoản demo trên server
      if (!_firebaseService.isAvailable) {
        await _startSession(await _api.post('/api/auth/demo'));
        return LoginResult.demo;
      }

      final idToken = await _firebaseService.signInWithGoogleAndGetIdToken();
      if (idToken == null) return LoginResult.cancelled;

      await _startSession(await _api.post('/api/auth/google', body: {'idToken': idToken}));
      return LoginResult.success;
    } catch (e) {
      _lastError = e.toString();
      return LoginResult.failed;
    }
  }

  /// Dùng thử không cần tài khoản. Trả về false nếu không kết nối được server.
  Future<bool> continueAsGuest() async {
    _lastError = null;
    try {
      await _startSession(await _api.post('/api/auth/guest'));
      return true;
    } catch (e) {
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _startSession(dynamic data) async {
    if (data is! Map<String, dynamic> || data['token'] == null) {
      throw const ApiException('Phản hồi đăng nhập không hợp lệ');
    }
    await _api.setToken(data['token'].toString());
    final user = data['user'];
    if (user is Map<String, dynamic>) _applyProfile(user, forcePreferencesChanged: true);
  }

  Future<void> logout() async {
    try {
      await _api.post('/api/auth/logout');
    } catch (_) {}
    await _firebaseService.logout();
    await _api.setToken(null);
    _resetLocalState();
  }

  /// Xoá tài khoản: server xoá toàn bộ dữ liệu (ON DELETE CASCADE), xoá tài khoản Firebase
  /// và dữ liệu trên máy.
  Future<void> deleteAccount() async {
    try {
      await _api.delete('/api/me');
    } catch (e) {
      _setError(e);
    }
    await _firebaseService.deleteFirebaseUser();
    await _firebaseService.logout();
    await LocalStorage.clearAll();
    await _api.setToken(null);
    _resetLocalState();
  }

  void _resetLocalState() {
    _displayName = _defaultName;
    _bio = _defaultBio;
    _avatarUrl = ImageUtils.defaultAvatar;
    _email = null;
    _isGuest = false;
    _preferences = UserPreferences();
    _preferencesVersion++;
    LocalStorage.remove(StorageKeys.profile);
    LocalStorage.remove(StorageKeys.preferences);
    notifyListeners();
  }

  // ---------------------------------------------------- Bản sao trên máy
  void _loadLocal() {
    final profile = LocalStorage.getJsonMap(StorageKeys.profile);
    if (profile != null) {
      _displayName = profile['displayName']?.toString() ?? _displayName;
      _bio = profile['bio']?.toString() ?? _bio;
      _avatarUrl = profile['avatarUrl']?.toString() ?? _avatarUrl;
      _email = profile['email']?.toString();
      _isGuest = profile['isGuest'] == true;
    }
    final prefs = LocalStorage.getJsonMap(StorageKeys.preferences);
    if (prefs != null) {
      _preferences = UserPreferences.fromMap(prefs);
    }
  }

  void _saveLocal() {
    LocalStorage.setJson(StorageKeys.profile, {
      'displayName': _displayName,
      'bio': _bio,
      'avatarUrl': _avatarUrl,
      'email': _email,
      'isGuest': _isGuest,
    });
    LocalStorage.setJson(StorageKeys.preferences, _preferences.toMap());
  }
}
