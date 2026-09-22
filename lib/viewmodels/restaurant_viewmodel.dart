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
    
    final Map<String, List<Map<String, String>>> hanoiData = {
      'Món Chay': [
        {'name': 'Chay Aummee', 'address': '26 Châu Long, Q. Ba Đình, Hà Nội'},
        {'name': 'Chay Vị Lai', 'address': '67 Lý Thường Kiệt, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Chay Ưu Đàm (Sadhu)', 'address': '87 Lý Thường Kiệt, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Buffet Chay Hương Cảnh', 'address': '168 Khuất Duy Tiến, Q. Thanh Xuân, Hà Nội'},
        {'name': 'Cơm Chay An Phúc', 'address': '11 Ngõ 131 Thái Hà, Q. Đống Đa, Hà Nội'},
        {'name': 'Lẩu Nấm Chay An Lạc', 'address': '109 Trần Hưng Đạo, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Chay Thiện Duyên', 'address': '45 Nguyễn Chí Thanh, Q. Ba Đình, Hà Nội'},
        {'name': 'Quán Chay Sen Vàng', 'address': '12 Đội Cấn, Q. Ba Đình, Hà Nội'},
        {'name': 'Cơm Chay Diệu Tâm', 'address': '88 Kim Mã, Q. Ba Đình, Hà Nội'},
        {'name': 'Chay Tĩnh Quán', 'address': '19 Trần Hưng Đạo, Q. Hoàn Kiếm, Hà Nội'},
      ],
      'Healthy': [
        {'name': 'Salad Station Hà Nội', 'address': '88 Tô Ngọc Vân, Q. Tây Hồ, Hà Nội'},
        {'name': 'Fresh Garden Bakery & Cafe', 'address': '104 Cầu Giấy, Q. Cầu Giấy, Hà Nội'},
        {'name': 'HealthWitch Eat Clean', 'address': '12 Nguyễn Khánh Toàn, Q. Cầu Giấy, Hà Nội'},
        {'name': 'Poke Hà Nội', 'address': '11B Hàng Hành, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Green Life Kitchen', 'address': '45 Xuân Diệu, Q. Tây Hồ, Hà Nội'},
        {'name': 'Organic Bowl Hà Thành', 'address': '28 Hoàng Quốc Việt, Q. Cầu Giấy, Hà Nội'},
        {'name': 'Eat Clean Kitchen', 'address': '55 Trần Thái Tông, Q. Cầu Giấy, Hà Nội'},
        {'name': 'Smoothie Factory Hà Nội', 'address': '15 Trích Sài, Q. Tây Hồ, Hà Nội'},
        {'name': 'The Green Box Eat Clean', 'address': '92 Lê Văn Lương, Q. Thanh Xuân, Hà Nội'},
        {'name': 'Nước Ép Trị Liệu & Healthy', 'address': '34 Bùi Thị Xuân, Q. Hai Bà Trưng, Hà Nội'},
      ],
      'Nhà hàng': [
        {'name': 'Phở Thìn Lò Đúc', 'address': '13 Lò Đúc, Q. Hai Bà Trưng, Hà Nội'},
        {'name': 'Phở Bát Đàn', 'address': '49 Bát Đàn, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Bún Chả Hương Liên (Obama)', 'address': '24 Lê Văn Hưu, Q. Hai Bà Trưng, Hà Nội'},
        {'name': 'Bún Chả Cửa Đông', 'address': '41 Cửa Đông, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Chả Cá Lã Vọng', 'address': '14 Chả Cá, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Chả Cá Thăng Long', 'address': '21 Đường Thành, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Bún Thang Cầu Gỗ', 'address': '32 Cầu Gỗ, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Quán Ăn Ngon', 'address': '18 Phan Bội Châu, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Bún Đậu Mắm Tôm Ngõ Trạm', 'address': '1B Ngõ Trạm, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Nét Huế Nguyễn Chí Thanh', 'address': '33 Nguyễn Chí Thanh, Q. Ba Đình, Hà Nội'},
        {'name': 'Cơm Niêu Tố Uyên', 'address': '102 C2 Phạm Ngọc Thạch, Q. Đống Đa, Hà Nội'},
        {'name': 'Bánh Đa Cua Lý Thường Kiệt', 'address': '42C Lý Thường Kiệt, Q. Hoàn Kiếm, Hà Nội'},
      ],
      'Ăn vặt': [
        {'name': 'Nem Chua Nướng Tạm Thương', 'address': '36 Tạm Thương, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Nộm Bò Khô Long Thủy', 'address': '23 Hàng Giầy, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Chè Bốn Mùa', 'address': '4 Hàng Cân, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Bánh Tráng Nướng Hàng Trống', 'address': '86 Hàng Trống, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Sữa Chua Dầm Tô Tịch', 'address': '17 Tô Tịch, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Kem Tràng Tiền', 'address': '35 Tràng Tiền, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Caramen Hàng Than', 'address': '29 Hàng Than, Q. Ba Đình, Hà Nội'},
        {'name': 'Bánh Cuốn Bà Hoành', 'address': '66 Tô Hiến Thành, Q. Hai Bà Trưng, Hà Nội'},
        {'name': 'Xôi Yến Nguyễn Hữu Huân', 'address': '35B Nguyễn Hữu Huân, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Bánh Mì Dân Tổ', 'address': '32 Trần Nhật Duật, Q. Hoàn Kiếm, Hà Nội'},
      ],
      'Quán Nhậu': [
        {'name': 'Bia Hơi Hà Nội Tạ Hiện', 'address': '18 Tạ Hiện, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Lẩu Nấm Ashima', 'address': '182 Triệu Việt Vương, Q. Hai Bà Trưng, Hà Nội'},
        {'name': 'Nướng Gầm Cầu', 'address': '15 Gầm Cầu, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Bò Tơ Quan Mộc', 'address': '102 Thái Thịnh, Q. Đống Đa, Hà Nội'},
        {'name': 'Lẩu Đuôi Bò Định Công', 'address': '120 Định Công, Q. Hoàng Mai, Hà Nội'},
        {'name': 'Bia Hơi Cổ Đô', 'address': '109 Lãng Yên, Q. Hai Bà Trưng, Hà Nội'},
        {'name': 'Lẩu Dê Nhất Ly', 'address': '167 Tây Sơn, Q. Đống Đa, Hà Nội'},
        {'name': 'Hải Sản Biển Đông', 'address': '2 Phố Trần Quốc Toản, Q. Hoàn Kiếm, Hà Nội'},
        {'name': 'Quán Nhậu Tự Do', 'address': '67 Trần Đại Nghĩa, Q. Hai Bà Trưng, Hà Nội'},
        {'name': 'Bò Nhúng Dấm 555', 'address': '105-C8 Giảng Võ, Q. Ba Đình, Hà Nội'},
      ],
    };

    final Map<String, String> pexelsIds = {
      'Món Chay': '1143754',
      'Healthy': '1640777',
      'Nhà hàng': '262959',
      'Ăn vặt': '4109128',
      'Quán Nhậu': '2313642',
    };

    final List<String> hanoiStreets = [
      'Chùa Bộc, Q. Đống Đa, Hà Nội',
      'Lê Văn Lương, Q. Thanh Xuân, Hà Nội',
      'Hoàng Hoa Thám, Q. Ba Đình, Hà Nội',
      'Kim Mã, Q. Ba Đình, Hà Nội',
      'Nguyễn Văn Cừ, Q. Long Biên, Hà Nội',
      'Trần Phú, Q. Hà Đông, Hà Nội',
      'Mễ Trì, Q. Nam Từ Liêm, Hà Nội',
      'Lạc Long Quân, Q. Tây Hồ, Hà Nội',
    ];

    int idCount = 1;
    hanoiData.forEach((cat, nameList) {
      for (int i = 0; i < 20; i++) {
        final item = nameList[i % nameList.length];
        final isExact = i < nameList.length;
        final name = isExact ? item['name']! : '${item['name']} (Cơ sở ${i ~/ nameList.length + 1})';
        final address = isExact ? item['address']! : '${10 + i * 3} ${hanoiStreets[i % hanoiStreets.length]}';

        list.add(Restaurant(
          id: 'res_$idCount',
          name: name,
          address: address,
          rating: double.parse((4.2 + (i % 8) / 10.0).toStringAsFixed(1)),
          imageUrl: 'https://images.pexels.com/photos/${pexelsIds[cat]}/pexels-photo-${pexelsIds[cat]}.jpeg?auto=compress&cs=tinysrgb&w=800',
          category: cat,
          distance: '${(0.4 + (i * 0.3)).toStringAsFixed(1)} km',
          isOpen: i % 7 != 0,
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
