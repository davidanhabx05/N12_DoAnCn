import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../core/services/local_storage_service.dart';

class SettingsViewModel extends ChangeNotifier {
  bool notificationsEnabled = true;
  String language = 'Tiếng Việt';

  SettingsViewModel() {
    notificationsEnabled = LocalStorage.getBool(StorageKeys.notificationsEnabled) ?? true;
  }

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    LocalStorage.setBool(StorageKeys.notificationsEnabled, value);
    notifyListeners();
  }

  void setLanguage(String lang) {
    language = lang;
    notifyListeners();
  }

  /// Xoá ảnh đã tải về (bộ nhớ đệm trên đĩa + trong RAM).
  Future<void> clearCache() async {
    try {
      await DefaultCacheManager().emptyCache();
    } catch (_) {}
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  void reset() {
    notificationsEnabled = true;
    notifyListeners();
  }
}
