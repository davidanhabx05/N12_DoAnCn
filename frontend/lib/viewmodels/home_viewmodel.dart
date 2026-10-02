import 'dart:async';

import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../models/dish.dart';
import 'filter_viewmodel.dart';

/// Trang chủ: danh sách gợi ý món lấy từ backend (GET /api/dishes/suggestions).
/// Backend lọc theo bộ lọc + hồ sơ ăn uống (dị ứng, chế độ ăn, ngân sách) và xáo trộn.
class HomeViewModel extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  List<Dish> _items = [];
  Map<String, dynamic> _query = {};
  bool _isFilterActive = false;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;
  int _currentIndex = 0;
  int _preferencesVersion = -1;
  int _requestId = 0;
  Timer? _reloadTimer;
  bool _disposed = false;

  HomeViewModel() {
    _api.sessionVersion.addListener(_scheduleReload);
  }

  @override
  void dispose() {
    _disposed = true;
    _reloadTimer?.cancel();
    _api.sessionVersion.removeListener(_scheduleReload);
    super.dispose();
  }

  // ------------------------------------------------------------ Getters
  bool get isFilterActive => _isFilterActive;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _error;
  int get currentDishIndex => _currentIndex;

  /// Danh sách món dùng cho "Ăn theo ý trời" và Chatbot.
  List<Dish> get dishes => _items;

  /// Danh sách hiển thị trên Trang chủ (đang lọc: đúng kết quả lọc, có thể rỗng).
  List<Dish> getRecommendedDishes(String dietType) => _items;

  Dish? get currentDish => _items.isEmpty ? null : _items[_currentIndex % _items.length];

  List<Dish> get likedDishes => _items.where((d) => d.isLiked).toList();

  bool isLiked(String dishId) => _items.any((d) => d.id == dishId && d.isLiked);

  // --------------------------------------------------------- Tải dữ liệu
  /// Gọi (qua ProxyProvider) mỗi khi hồ sơ ăn uống trên server thay đổi.
  void onPreferencesChanged(int version) {
    if (version == _preferencesVersion) return;
    _preferencesVersion = version;
    _scheduleReload();
  }

  /// Gộp nhiều yêu cầu tải lại liên tiếp (đăng nhập + đổi hồ sơ) thành một lần gọi API.
  void _scheduleReload() {
    _reloadTimer?.cancel();
    _reloadTimer = Timer(const Duration(milliseconds: 80), reload);
  }

  Future<void> reload() async {
    if (_disposed) return;
    final id = ++_requestId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('/api/dishes/suggestions', query: _query);
      if (_disposed || id != _requestId) return;
      if (data is Map<String, dynamic>) {
        _items = Dish.listFromJson(data['items']);
        _isFilterActive = data['filterActive'] == true;
      }
      _currentIndex = 0;
      _hasLoaded = true;
    } catch (e) {
      if (_disposed || id != _requestId) return;
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void applyFilter(FilterViewModel filterVm, String dietType) {
    _query = {
      if (filterVm.selectedTime != 'Bất kỳ') 'time': filterVm.selectedTime,
      if (filterVm.maxTimeSlider < 180) 'maxTime': filterVm.maxTimeSlider.round(),
      'region': filterVm.selectedRegion,
      'weather': filterVm.selectedWeather,
      'mood': filterVm.selectedMood,
    };
    // Đổi chế độ hiển thị ngay, kết quả về sau
    _isFilterActive = filterVm.selectedTime != 'Bất kỳ' ||
        filterVm.selectedRegion != null ||
        filterVm.selectedWeather != null ||
        filterVm.selectedMood != null;
    _items = [];
    _currentIndex = 0;
    reload();
  }

  // ------------------------------------------------------------ Điều hướng
  void nextDish() {
    if (_items.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _items.length;
    notifyListeners();
  }

  void previousDish() {
    if (_items.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _items.length) % _items.length;
    notifyListeners();
  }

  // ------------------------------------------------------------- Yêu thích
  void toggleLikeCurrent() {
    final dish = currentDish;
    if (dish != null) toggleLike(dish.id);
  }

  /// Cập nhật giao diện ngay, rồi gửi lên server (POST/DELETE /api/me/likes/{id}).
  Future<void> toggleLike(String dishId) async {
    final index = _items.indexWhere((d) => d.id == dishId);
    final before = index == -1 ? null : _items[index];
    final liked = !(before?.isLiked ?? false);
    if (before != null) {
      _replace(before.copyWith(isLiked: liked, likesCount: before.likesCount + (liked ? 1 : -1)));
    }

    try {
      final data = liked ? await _api.post('/api/me/likes/$dishId') : await _api.delete('/api/me/likes/$dishId');
      if (data is Map<String, dynamic>) {
        final i = _items.indexWhere((d) => d.id == dishId);
        if (i != -1) {
          final count = data['likesCount'];
          _replace(_items[i].copyWith(
            isLiked: data['liked'] == true,
            likesCount: count is num ? count.toInt() : _items[i].likesCount,
          ));
        }
      }
    } catch (e) {
      // Lỗi mạng / chưa đăng nhập -> hoàn tác
      if (before != null) _replace(before);
      _error = e.toString();
      notifyListeners();
    }
  }

  void _replace(Dish dish) {
    final i = _items.indexWhere((d) => d.id == dish.id);
    if (i == -1) return;
    _items = List.of(_items)..[i] = dish;
    notifyListeners();
  }

  /// Về trạng thái ban đầu (dùng khi xoá tài khoản / đăng xuất).
  void reset() {
    _query = {};
    _isFilterActive = false;
    _items = [];
    _currentIndex = 0;
    _error = null;
    _scheduleReload();
    notifyListeners();
  }
}
