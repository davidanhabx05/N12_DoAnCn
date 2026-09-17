import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../core/services/places_service.dart';

class RestaurantViewModel extends ChangeNotifier {
  final PlacesService _placesService = PlacesService();

  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  final List<String> categories = ['Tất cả', 'Món Chay', 'Healthy', 'Nhà hàng', 'Ăn vặt', 'Quán Nhậu'];

  final List<Restaurant> _allRestaurants = [
    Restaurant(
      id: '1',
      name: 'Nhà hàng Chay An Phúc',
      address: '123 Nguyễn Văn Cừ, Quận 5, TP.HCM',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=1000&auto=format&fit=crop',
      category: 'Món Chay',
      distance: '0.8 km',
      isOpen: true,
    ),
    Restaurant(
      id: '2',
      name: 'Quán Ăn Healthy Green',
      address: '45 Lê Văn Sỹ, Quận Phú Nhuận, TP.HCM',
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000&auto=format&fit=crop',
      category: 'Healthy',
      distance: '1.5 km',
      isOpen: true,
    ),
    Restaurant(
      id: '3',
      name: 'Bếp Nhà Mình Restaurant',
      address: '88 Pasteur, Quận 1, TP.HCM',
      rating: 4.9,
      imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=1000&auto=format&fit=crop',
      category: 'Nhà hàng',
      distance: '2.1 km',
      isOpen: false,
    ),
    Restaurant(
      id: '4',
      name: 'Ăn Vặt Cô Ba Sài Gòn',
      address: '12 Điện Biên Phủ, Quận Bình Thạnh, TP.HCM',
      rating: 4.6,
      imageUrl: 'https://images.unsplash.com/photo-1550547660-d9450f859349?q=80&w=1000&auto=format&fit=crop',
      category: 'Ăn vặt',
      distance: '1.1 km',
      isOpen: true,
    ),
  ];

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Restaurant> get filteredRestaurants {
    final results = _allRestaurants.where((r) {
      final matchesQuery = _searchQuery.isEmpty || 
          r.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.address.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Tất cả' || r.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    // If searching and no results in local mock, simulate finding something
    if (_searchQuery.isNotEmpty && results.isEmpty) {
      return [
        Restaurant(
          id: 'mock_search',
          name: 'Kết quả tìm: $_searchQuery',
          address: 'Khu vực lân cận của bạn',
          rating: 4.5,
          imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=1000&auto=format&fit=crop',
          category: 'Nhà hàng',
          distance: '2.5 km',
          isOpen: true,
        )
      ];
    }
    return results;
  }

  List<Restaurant> getFilteredByPreference(String dietType) {
    if (dietType == 'Bình thường') return filteredRestaurants;
    final results = filteredRestaurants.where((r) => r.category.contains(dietType)).toList();
    if (results.isEmpty) return filteredRestaurants;
    return results;
  }

  Future<void> fetchNearbyFromPlaces() async {
    await _placesService.searchNearbyRestaurants(_searchQuery.isEmpty ? 'nhà hàng gần đây' : _searchQuery);
    notifyListeners();
  }
}
