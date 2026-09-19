import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../models/user_preferences.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserPreferences _preferences = UserPreferences();

  // Profile Data
  String _displayName = 'Người dùng Foodie';
  String _bio = 'Yêu thích nấu ăn và khám phá ẩm thực Việt Nam.';
  String _avatarUrl = 'https://images.pexels.com/users/avatars/1640777/pexels-user-1640777.jpeg?auto=compress&cs=tinysrgb&w=200';

  String get displayName => _displayName;
  String get bio => _bio;
  String get avatarUrl => _avatarUrl;

  UserPreferences get preferences => _preferences;

  double? get bmi {
    if (_preferences.weight == null || _preferences.height == null || _preferences.height == 0) return null;
    final hMeter = _preferences.height! / 100;
    return _preferences.weight! / (hMeter * hMeter);
  }

  String get bmiCategory {
    final val = bmi;
    if (val == null) return "Chưa có dữ liệu";
    if (val < 18.5) return "Thiếu cân";
    if (val < 25) return "Cân đối";
    if (val < 30) return "Thừa cân";
    return "Béo phì";
  }

  int? get tdee {
    if (_preferences.weight == null || 
        _preferences.height == null || 
        _preferences.birthYear == null || 
        _preferences.gender == null ||
        _preferences.activityLevel == null) return null;

    final age = DateTime.now().year - _preferences.birthYear!;
    double bmr;
    if (_preferences.gender == 'Nam') {
      bmr = 10 * _preferences.weight! + 6.25 * _preferences.height! - 5 * age + 5;
    } else {
      bmr = 10 * _preferences.weight! + 6.25 * _preferences.height! - 5 * age - 161;
    }

    double factor = 1.2;
    switch (_preferences.activityLevel) {
      case 'Ít vận động': factor = 1.2; break;
      case 'Vận động nhẹ': factor = 1.375; break;
      case 'Vận động vừa phải': factor = 1.55; break;
      case 'Năng động': factor = 1.725; break;
      case 'Rất năng động': factor = 1.9; break;
    }

    return (bmr * factor).round();
  }

  void updateProfile({String? name, String? bio, String? avatar}) {
    if (name != null) _displayName = name;
    if (bio != null) _bio = bio;
    if (avatar != null) _avatarUrl = avatar;
    notifyListeners();
  }

  bool get isLoggedIn => _firebaseService.isLoggedIn;
  String? get userEmail => _firebaseService.userEmail;

  // Real-time stats
  int _basePostCount = 12;
  int _followerCount = 128;
  int _followingCount = 45;
  int _totalLikes = 1540;

  int get postCount => isLoggedIn ? (_basePostCount + _userPostsCount) : 0;
  int get followingCount => isLoggedIn ? _followingCount : 0;
  int get followerCount => isLoggedIn ? _followerCount : 0;
  int get totalLikes => isLoggedIn ? _totalLikes : 0;

  int _userPostsCount = 0;
  void syncUserPostsCount(int count) {
    _userPostsCount = count;
    notifyListeners();
  }

  void updatePreferences(UserPreferences newPrefs) {
    _preferences = newPrefs;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _firebaseService.login(email, password);
    notifyListeners();
  }

  Future<void> logout() async {
    await _firebaseService.logout();
    notifyListeners();
  }
}
