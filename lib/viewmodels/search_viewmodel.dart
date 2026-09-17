import 'package:flutter/material.dart';
import '../../models/dish.dart';

class SearchViewModel extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  final List<String> categories = ['Tất cả', 'Cơm', 'Phở', 'Bún', 'Mì', 'Bánh mì', 'Lẩu', 'Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Ăn nhẹ', 'Healthy'];

  final List<Dish> _allDishes = _generate1200Dishes();

  static List<Dish> _generate1200Dishes() {
    // Bộ sưu tập mã ID Unsplash chất lượng cao cho ẩm thực Việt Nam / Châu Á
    final Map<String, List<String>> dishImages = {
      'Phở': ['1582878826629-29b7ad1cdc43', '1513104890138-7c749659a591', '1606755962002-ad942337d050'],
      'Bánh mì': ['1550547660-d9450f859349', '1558961363-fa8fdf82db35', '1601050691515-3dfcde5bbadb'],
      'Gỏi': ['1546069901-ba9599a7e63c', '1512614738805-2b0a28a3a813', '1506084868270-3e230b05c361'],
      'Cơm': ['1555939594-58d7cb561ad1', '1541014741242-d99c4354c4ad', '1604467731203-d6151779aa49'],
      'Bún': ['1569718212165-3a8278d5f624', '1624300627563-04c1f3e74363', '1637536250583-b25b1ae95001'],
      'Mì': ['1526318896980-cf78c088911f', '1585032226651-759b368d724a', '1612929633738-8fe44f7f8b0c'],
      'Canh': ['1547592180-85f173990554', '1548946522-bb1f0590a27a'],
      'Lẩu': ['1476733419910-74b170a39f14', '1551183053-bf91c1d81141', '1630132332617-646c10c149a4'],
      'Healthy': ['1540420773420-3366772f4999', '1541544741938-0af808871cc0', '1490645935086-33b7e440855c'],
    };

    final List<String> fallbackIds = [
      '1512058560374-3a7c0d3a56e2', '1511910849309-0d58f8308e22', '1552611052-c2b603f5d9a5',
      '1509440159477-927bcfca4ec6', '1618449840183-c803402e1469', '1515516904322-1d57d207f212',
      '1590409892150-13f89e47510d', '1604467731203-d6151779aa49', '1612131810029-7901e5450ad1',
      '1473093226795-af9932fe5856'
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
      return 'https://images.unsplash.com/photo-$finalId?q=80&w=1000&auto=format&fit=crop';
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
