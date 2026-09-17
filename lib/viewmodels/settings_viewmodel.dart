import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  bool notificationsEnabled = true;
  String language = 'Tiếng Việt';

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void setLanguage(String lang) {
    language = lang;
    notifyListeners();
  }

  void clearCache() {
    // Simulate cache clearing
  }
}
