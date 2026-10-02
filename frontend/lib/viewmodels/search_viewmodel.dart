import 'dart:async';

import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../models/dish.dart';
import 'filter_viewmodel.dart';

/// Tìm kiếm món: backend tìm không dấu (GET /api/dishes/search), app chỉ hiển thị.
class SearchViewModel extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  final List<String> categories = ['Tất cả', 'Cơm', 'Phở', 'Bún', 'Mì', 'Bánh mì', 'Lẩu', 'Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Ăn nhẹ', 'Healthy'];

  // Bộ lọc dùng chung với màn Bộ lọc
  String _time = 'Bất kỳ';
  double _maxTime = 180;
  String? _region;
  String? _weather;
  String? _mood;

  List<Dish> _results = [];
  List<Dish> _featured = [];
  Set<String> _bookmarkedIds = {};
  bool _isLoading = false;
  String? _error;
  Timer? _debounce;
  int _requestId = 0;
  bool _disposed = false;

  SearchViewModel() {
    _api.sessionVersion.addListener(_onSessionChanged);
    _onSessionChanged();
  }

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    _api.sessionVersion.removeListener(_onSessionChanged);
    super.dispose();
  }

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _error;

  /// Kết quả tìm kiếm hiện tại.
  List<Dish> get filteredDishes => _results;

  List<Dish> get featuredDishes => _featured;

  void _onSessionChanged() {
    _search();
    _loadFeatured();
    _loadBookmarks();
  }

  void setSearchQuery(String query) {
    if (query == _searchQuery) return;
    _searchQuery = query;
    notifyListeners();
    // Chờ người dùng ngừng gõ 350ms rồi mới gọi API
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _search);
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
    _search();
  }

  /// Đồng bộ các tiêu chí từ màn Bộ lọc (thời gian, vùng miền, thời tiết, tâm trạng).
  void applyFilter(FilterViewModel filterVm) {
    _time = filterVm.selectedTime;
    _maxTime = filterVm.maxTimeSlider;
    _region = filterVm.selectedRegion;
    _weather = filterVm.selectedWeather;
    _mood = filterVm.selectedMood;
    _search();
  }

  Future<void> _search() async {
    final id = ++_requestId;
    _isLoading = true;
    try {
      final data = await _api.get('/api/dishes/search', query: {
        'q': _searchQuery.trim(),
        if (_selectedCategory != 'Tất cả') 'category': _selectedCategory,
        if (_time != 'Bất kỳ') 'time': _time,
        if (_maxTime < 180) 'maxTime': _maxTime.round(),
        'region': _region,
        'weather': _weather,
        'mood': _mood,
      });
      if (_disposed || id != _requestId) return;
      _results = Dish.listFromJson(data);
      _error = null;
    } catch (e) {
      if (_disposed || id != _requestId) return;
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFeatured() async {
    try {
      final data = await _api.get('/api/dishes/featured');
      if (_disposed) return;
      _featured = Dish.listFromJson(data);
      notifyListeners();
    } catch (_) {}
  }

  // ------------------------------------------------------------ Lưu món
  Future<void> _loadBookmarks() async {
    if (!_api.hasSession) {
      _bookmarkedIds = {};
      if (!_disposed) notifyListeners();
      return;
    }
    try {
      final data = await _api.get('/api/me/bookmarks/ids');
      if (_disposed) return;
      if (data is List) {
        _bookmarkedIds = data.map((e) => e.toString()).toSet();
        notifyListeners();
      }
    } catch (_) {}
  }

  bool isBookmarked(String dishId) => _bookmarkedIds.contains(dishId);

  List<Dish> get bookmarkedDishes => _results.where((d) => _bookmarkedIds.contains(d.id)).toList();

  /// Trả về true nếu món vừa được lưu, false nếu vừa bỏ lưu.
  /// Giao diện đổi ngay, server lưu ở nền (POST/DELETE /api/me/bookmarks/{id}).
  bool toggleBookmark(String dishId) {
    final added = !_bookmarkedIds.contains(dishId);
    if (added) {
      _bookmarkedIds.add(dishId);
    } else {
      _bookmarkedIds.remove(dishId);
    }
    notifyListeners();

    final request = added ? _api.post('/api/me/bookmarks/$dishId') : _api.delete('/api/me/bookmarks/$dishId');
    request.catchError((Object e) {
      // Không lưu được -> hoàn tác
      if (added) {
        _bookmarkedIds.remove(dishId);
      } else {
        _bookmarkedIds.add(dishId);
      }
      _error = e.toString();
      if (!_disposed) notifyListeners();
    });
    return added;
  }

  void reset() {
    _bookmarkedIds = {};
    _searchQuery = '';
    _selectedCategory = 'Tất cả';
    _time = 'Bất kỳ';
    _maxTime = 180;
    _region = null;
    _weather = null;
    _mood = null;
    notifyListeners();
    _search();
  }
}
