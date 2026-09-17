import 'package:flutter/material.dart';
import '../core/services/firebase_service.dart';
import '../models/user_preferences.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserPreferences _preferences = UserPreferences();

  UserPreferences get preferences => _preferences;
  bool get isLoggedIn => _firebaseService.isLoggedIn;
  String? get userEmail => _firebaseService.userEmail;

  // Mock stats
  int get postCount => isLoggedIn ? 12 : 0;
  int get followingCount => isLoggedIn ? 45 : 0;
  int get followerCount => isLoggedIn ? 128 : 0;
  int get totalLikes => isLoggedIn ? 1540 : 0;

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
