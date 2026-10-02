import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../core/network/api_client.dart';
import '../models/restaurant.dart';

/// Gợi ý quán: backend (GET /api/restaurants) tìm quán THẬT quanh vị trí người dùng
/// (Google Places nếu có key, không thì OpenStreetMap), tính khoảng cách & giờ mở cửa.
/// App chỉ gửi từ khoá + vị trí hiện tại; không gõ gì vẫn nhận được các quán gần nhất.
class RestaurantViewModel extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  String? _dishTitle;
  String _dietType = 'Bình thường';

  final List<String> categories = ['Tất cả', 'Món Chay', 'Healthy', 'Nhà hàng', 'Ăn vặt', 'Quán Nhậu'];

  List<Restaurant> _results = [];
  bool _isSearching = false;
  String? _error;
  Timer? _debounce;
  int _requestId = 0;
  bool _disposed = false;

  Position? _currentPosition;

  /// Nguồn của danh sách hiện tại: google | osm | local | none.
  String _source = 'none';

  /// Lý do chưa có vị trí (để hiển thị cho người dùng), null nếu đã có.
  String? _locationIssue;

  RestaurantViewModel() {
    _initLocation();
    _fetch();
  }

  bool get isSearching => _isSearching;
  bool get hasLocation => _currentPosition != null;
  String get source => _source;
  String? get locationIssue => _locationIssue;

  /// Xin lại quyền / lấy lại vị trí (người dùng bấm vào dòng cảnh báo).
  Future<void> retryLocation() => _initLocation();
  String? get errorMessage => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  @override
  void dispose() {
    _disposed = true;
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationIssue('Định vị (GPS) đang tắt');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setLocationIssue('App chưa được cấp quyền vị trí');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _setLocationIssue('Quyền vị trí đã bị chặn, hãy bật lại trong Cài đặt');
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      _locationIssue = null;
      // Có vị trí -> tải lại để server tìm quán quanh đây & sắp xếp theo độ gần
      _fetch();
    } catch (e) {
      debugPrint('Lỗi lấy vị trí: $e');
      _setLocationIssue('Chưa lấy được vị trí');
    }
  }

  void _setLocationIssue(String message) {
    _locationIssue = message;
    if (!_disposed) notifyListeners();
  }

  // ------------------------------------------------------------ Tìm kiếm
  /// Đặt từ khoá; chờ người dùng ngừng gõ rồi mới gọi API.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _dishTitle = null;
    notifyListeners();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _fetch);
  }

  void onSearchChanged(String query) => setSearchQuery(query);

  /// Tìm quán bán một món cụ thể (từ màn chi tiết món / chatbot).
  /// Backend tự rút gọn "Bún chả thịt bò thơm ngon" -> "Bún chả".
  void searchForDish(String dishTitle) {
    _debounce?.cancel();
    _selectedCategory = 'Tất cả';
    _searchQuery = dishTitle;
    _dishTitle = dishTitle;
    notifyListeners();
    _fetch();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
    _fetch();
  }

  /// Nhấn "Tìm" trên bàn phím -> gọi ngay.
  Future<void> fetchNearbyFromPlaces() {
    _debounce?.cancel();
    return _fetch();
  }

  Future<void> _fetch() async {
    if (_disposed) return;
    final id = ++_requestId;
    final dish = _dishTitle;
    _isSearching = true;
    notifyListeners();
    try {
      final data = await _api.get('/api/restaurants', query: {
        if (dish == null) 'q': _searchQuery.trim(),
        'dish': dish,
        if (_selectedCategory != 'Tất cả') 'category': _selectedCategory,
        'lat': _currentPosition?.latitude,
        'lng': _currentPosition?.longitude,
        'diet': _dietType,
      });
      if (_disposed || id != _requestId) return;
      if (data is Map<String, dynamic>) {
        final items = data['items'];
        _results = items is List
            ? items.whereType<Map<String, dynamic>>().map(Restaurant.fromJson).toList()
            : <Restaurant>[];
        _source = data['source']?.toString() ?? (data['usedGooglePlaces'] == true ? 'google' : 'none');
        // Server đã rút gọn tên món -> hiển thị trong ô tìm kiếm
        if (dish != null && data['query'] != null) _searchQuery = data['query'].toString();
      }
      _error = null;
    } catch (e) {
      if (_disposed || id != _requestId) return;
      _error = e.toString();
    }
    _isSearching = false;
    notifyListeners();
  }

  // ------------------------------------------------------------ Kết quả
  List<Restaurant> get filteredRestaurants => _results;

  /// Danh sách đã được server ưu tiên quán hợp chế độ ăn trong hồ sơ.
  List<Restaurant> getFilteredByPreference(String dietType) {
    if (dietType != _dietType) {
      _dietType = dietType;
      // Được gọi trong build() -> tải lại ở lượt sau
      Timer.run(_fetch);
    }
    return _results;
  }

  /// Chuỗi dùng để mở Google Maps chính xác nhất cho quán này.
  String mapsQueryFor(Restaurant r) => r.mapsQuery ?? '${r.name}, ${r.address}';
}
