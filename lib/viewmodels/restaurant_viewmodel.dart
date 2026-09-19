import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../core/services/places_service.dart';

class RestaurantViewModel extends ChangeNotifier {
  final PlacesService _placesService = PlacesService();

  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  final List<String> categories = ['Tất cả', 'Món Chay', 'Healthy', 'Nhà hàng', 'Ăn vặt', 'Quán Nhậu'];

  late List<Restaurant> _allRestaurants;

  RestaurantViewModel() {
    _allRestaurants = _generate100Restaurants();
  }

  static List<Restaurant> _generate100Restaurants() {
    final List<Restaurant> list = [];
    
    final Map<String, List<String>> names = {
      'Món Chay': ['Cơm Chay Diệu Tâm', 'Buffet Chay Hương Từ', 'Nhà hàng Chay An Phúc', 'Chay Thiện Duyên', 'Quán Chay Sen Vàng', 'Lẩu Nấm Chay', 'Bún Bò Chay Cô Ba', 'Chay Tùy Duyên', 'Thực Phẩm Sạch Chay', 'Nhà hàng Chay Veggie'],
      'Healthy': ['Green Life Salad', 'Healthy Bites', 'Eat Clean Kitchen', 'Fresh Garden', 'Poke Saigon', 'Smoothie Factory', 'Organic House', 'Nước Ép Trị Liệu', 'Vegan Bowl', 'The Green Box'],
      'Nhà hàng': ['Bếp Nhà Mình', 'Cơm Niêu Việt', 'Nhà hàng Ngon', 'Quán Ăn Gia Đình', 'Ẩm Thực Quê Hương', 'Nhà hàng Sen', 'Bún Chả Sinh Từ', 'Phở Thìn Lò Đúc', 'Cơm Tấm Cali', 'Lẩu Cua Khôi'],
      'Ăn vặt': ['Ốc Đào', 'Bánh Tráng Trộn Cô Long', 'Chè Thái Ý Phương', 'Trà Sữa Nhà Làm', 'Nem Nướng Nha Trang', 'Bánh Xèo Kỷ Ty', 'Ăn Vặt Sài Gòn', 'Sữa Chua Trân Châu', 'Bánh Mì Huỳnh Hoa', 'Xôi Yến'],
      'Quán Nhậu': ['Bia Hơi Hà Nội', 'Lẩu Dê Đồng Quê', 'Bò Tơ Tây Ninh', 'Vuvuzela Beer Club', 'Quán Nhậu Bình Dân', 'Lẩu Gà Lá É', 'Nướng Ngói', 'Hải Sản Tươi Sống', 'Đồ Nướng Sapa', 'Bia Club 99'],
    };

    final Map<String, String> pexelsIds = {
      'Món Chay': '1143754',
      'Healthy': '1640777',
      'Nhà hàng': '262959',
      'Ăn vặt': '4109128',
      'Quán Nhậu': '2313642',
    };

    final List<String> cities = ['Quận 1, TP.HCM', 'Quận 3, TP.HCM', 'Quận Hoàn Kiếm, Hà Nội', 'Quận Cầu Giấy, Hà Nội', 'Quận Hải Châu, Đà Nẵng', 'Quận Ninh Kiều, Cần Thơ'];

    int idCount = 1;
    names.forEach((cat, nameList) {
      for (int i = 0; i < 30; i++) {
        final nameBase = nameList[i % nameList.length];
        final suffix = i >= nameList.length ? ' (CS ${i ~/ nameList.length + 1})' : '';
        
        list.add(Restaurant(
          id: 'res_$idCount',
          name: '$nameBase$suffix',
          address: '${10 + i} ${['Lê Lợi', 'Nguyễn Huệ', 'Trần Hưng Đạo', 'Lý Thường Kiệt', 'Bạch Đằng', 'Hoàng Hoa Thám', 'Kim Mã'][i % 7]}, ${cities[i % cities.length]}',
          rating: 4.0 + (i % 10) / 10.0,
          imageUrl: 'https://images.pexels.com/photos/${pexelsIds[cat]}/pexels-photo-${pexelsIds[cat]}.jpeg?auto=compress&cs=tinysrgb&w=800',
          category: cat,
          distance: '${(0.5 + (i * 0.2)).toStringAsFixed(1)} km',
          isOpen: i % 6 != 0,
        ));
        idCount++;
      }
    });

    return list;
  }

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
