import 'package:flutter/material.dart';
import '../../models/dish.dart';

class SearchViewModel extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  final List<String> categories = ['Tất cả', 'Cơm', 'Phở', 'Bún', 'Mì', 'Bánh mì', 'Lẩu', 'Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Ăn nhẹ', 'Healthy'];

  final List<Dish> _allDishes = _generate1200Dishes();

  static List<Dish> _generate1200Dishes() {
    // Bộ sưu tập mã ID Pexels chất lượng cao cho ẩm thực Việt Nam / Châu Á
    final Map<String, List<String>> dishImages = {
      'Phở': ['2641886', '6260921', '2313642'],
      'Bánh mì': ['4109128', '4109130', '461198'],
      'Gỏi': ['1600711', '4061557', '4061560'],
      'Cơm': ['1624487', '262959', '2116094'],
      'Bún': ['2410602', '6260921', '1273765'],
      'Mì': ['1273765', '1907244', '2098085'],
      'Canh': ['1731535', '1640772', '2313642'],
      'Lẩu': ['2313642', '6260921', '1624487'],
      'Healthy': ['1059943', '1640777', '1143754'],
    };

    final List<String> fallbackIds = [
      '2641886', '1600711', '2410602', '1624487', '4109128', 
      '1273765', '1731535', '1059943', '1640777', '1143754'
    ];

    String getImageUrl(String title, int index) {
      String? matchedId;
      final lowerTitle = title.toLowerCase();
      
      for (var entry in dishImages.entries) {
        if (lowerTitle.contains(entry.key.toLowerCase())) {
          matchedId = entry.value[index % entry.value.length];
          break;
        }
      }
      
      final finalId = matchedId ?? fallbackIds[index % fallbackIds.length];
      return 'https://images.pexels.com/photos/$finalId/pexels-photo-$finalId.jpeg?auto=compress&cs=tinysrgb&w=1000';
    }

    final List<String> categoriesList = ['Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Healthy', 'Ăn nhẹ'];
    
    final List<String> mainDishes = [
      'Phở', 'Bún bò', 'Cơm tấm', 'Hủ tiếu', 'Gỏi cuốn', 'Canh chua', 'Mì Quảng', 'Cháo gà', 'Lẩu thái', 'Bánh xèo', 
      'Xôi xéo', 'Bánh cuốn', 'Miến trộn', 'Cơm rang', 'Bún riêu', 'Bún chả', 'Cao lầu', 'Bánh đa cua', 'Bún mắm', 
      'Hủ tiếu Nam Vang', 'Bánh canh', 'Chả cá Lã Vọng', 'Bún đậu mắm tôm', 'Gỏi đu đủ', 'Bò kho', 'Phở cuốn', 'Bún thang', 'Bánh mì kẹp'
    ];
    final List<String> ingredients = [
      'thịt bò', 'gà xé', 'sườn nướng', 'hải sản tươi', 'tôm nhảy', 'heo quay', 'xá xíu', 'trứng muối', 'chả lụa', 'đậu hũ', 'nấm rơm', 'rau củ quả', 'mực một nắng', 'cá lóc', 'thịt băm'
    ];
    final List<String> adjectives = [
      'thơm ngon', 'đậm đà', 'thanh mát', 'bổ dưỡng', 'cay nồng', 'giòn rụm', 'béo ngậy', 'hảo hạng', 'đặc biệt', 'gia truyền', 'chuẩn vị', 'hấp dẫn', 'nóng hổi', 'thanh tao', 'mỹ vị'
    ];
    
    final List<Dish> generated = [];
    for (int i = 1; i <= 1200; i++) {
      final cat = categoriesList[(i - 1) % categoriesList.length];
      
      // Tạo tên duy nhất bằng cách kết hợp các thành phần mà không dùng số thứ tự
      final mainIdx = (i - 1) % mainDishes.length;
      final ingIdx = ((i - 1) ~/ mainDishes.length) % ingredients.length;
      final adjIdx = ((i - 1) ~/ (mainDishes.length * ingredients.length)) % adjectives.length;
      
      final title = '${mainDishes[mainIdx]} ${ingredients[ingIdx]} ${adjectives[adjIdx]}';
      
      generated.add(Dish(
        id: 'dish_$i',
        title: title,
        description: "Món ${mainDishes[mainIdx]} đặc sản truyền thống được chế biến tinh tế với công thức ${adjectives[adjIdx]}, mang lại trải nghiệm vị giác tuyệt vời và đầy đủ dinh dưỡng.",
        imageUrl: getImageUrl(title, i),
        calories: 200 + (i * 17) % 550,
        prepTimeMinutes: 10 + (i * 5) % 60,
        difficulty: i % 3 == 0 ? 'Khó' : (i % 2 == 0 ? 'Trung bình' : 'Dễ'),
        category: cat,
        likesCount: i % 150,
      ));
    }
    return generated;
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

  List<Dish> get filteredDishes {
    return _allDishes.where((dish) {
      final matchesQuery = dish.title.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesCategory = false;
      if (_selectedCategory == 'Tất cả') {
        matchesCategory = true;
      } else if (['Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Ăn nhẹ', 'Healthy'].contains(_selectedCategory)) {
        // Lọc theo thuộc tính category (loại bữa ăn)
        matchesCategory = dish.category == _selectedCategory;
      } else {
        // Lọc theo từ khóa trong tiêu đề (Cơm, Phở, Mì, Bún...)
        matchesCategory = dish.title.toLowerCase().contains(_selectedCategory.toLowerCase());
      }
      
      return matchesQuery && matchesCategory;
    }).toList();
  }

  List<Dish> get featuredDishes {
    final sorted = List<Dish>.from(_allDishes)..sort((a, b) => b.likesCount.compareTo(a.likesCount));
    return sorted.take(5).toList();
  }
}
