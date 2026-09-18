import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../models/user_preferences.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserPreferences _preferences = UserPreferences();

  UserPreferences get preferences => _preferences;
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
