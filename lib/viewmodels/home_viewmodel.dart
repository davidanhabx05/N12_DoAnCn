import 'package:flutter/material.dart';
import '../../models/dish.dart';

class HomeViewModel extends ChangeNotifier {
  final List<Dish> _dishes = _generate500Dishes();

  static List<Dish> _generate500Dishes() {
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

    final List<Dish> initialDishes = [
      Dish(
        id: '1',
        title: 'TÚI NGỌC XỐT MỀ',
        description: 'Món ăn chay hấp dẫn với bánh tráng bò bía chiên giòn và nhân rau củ tươi ngon, phủ xốt mè béo thơm.',
        imageUrl: getImageUrl('Healthy', 0),
        calories: 350,
        prepTimeMinutes: 30,
        difficulty: 'Trung bình',
        category: 'Healthy',
        likesCount: 4,
        isLiked: true,
        isSpecialOfTheWeek: true,
      ),
      Dish(
        id: '2',
        title: 'Bánh mì – Lưỡi heo khìa',
        description: 'Món ăn sáng độc đáo kết hợp giữa bánh mì giòn xốp và lưỡi heo khìa mềm mặn ngọt.',
        imageUrl: getImageUrl('Bánh mì', 1),
        calories: 450,
        prepTimeMinutes: 90,
        difficulty: 'Trung bình',
        category: 'Bữa sáng',
        likesCount: 28,
        isLiked: false,
        isSpecialOfTheWeek: true,
      ),
      Dish(
        id: '3',
        title: 'Phở bò truyền thống',
        description: 'Hương vị đậm đà với nước dùng hầm xương ngọt thanh, thịt bò mềm tan trong miệng.',
        imageUrl: getImageUrl('Phở', 0),
        calories: 500,
        prepTimeMinutes: 60,
        difficulty: 'Khó',
        category: 'Bữa sáng',
        likesCount: 156,
        isLiked: false,
      ),
      Dish(
        id: '4',
        title: 'Cơm tấm sườn bì chả',
        description: 'Món ăn đặc sản Sài Gòn với sườn nướng mật ong thơm phức và bì chả đậm đà.',
        imageUrl: getImageUrl('Cơm', 0),
        calories: 650,
        prepTimeMinutes: 45,
        difficulty: 'Trung bình',
        category: 'Bữa trưa',
        likesCount: 89,
        isLiked: true,
      ),
      Dish(
        id: '5',
        title: 'Gỏi cuốn tôm thịt',
        description: 'Món cuốn thanh mát với tôm tươi, thịt luộc, bún và rau sống chấm xốt đậu phộng.',
        imageUrl: getImageUrl('Gỏi', 0),
        calories: 250,
        prepTimeMinutes: 20,
        difficulty: 'Dễ',
        category: 'Healthy',
        likesCount: 72,
        isLiked: false,
      ),
      Dish(
        id: '6',
        title: 'Bún chả Hà Nội',
        description: 'Thịt nướng thơm lừng ăn kèm bún tươi, nước mắm chua ngọt và rau thơm.',
        imageUrl: getImageUrl('Bún', 0),
        calories: 550,
        prepTimeMinutes: 40,
        difficulty: 'Trung bình',
        category: 'Bữa trưa',
        likesCount: 110,
        isLiked: false,
      ),
      Dish(
        id: '7',
        title: 'Nấm và hành tây chiên giòn',
        description: 'Nấm tươi ngọt kết hợp hành tây tẩm bột chiên vàng giòn rụm.',
        imageUrl: getImageUrl('Healthy', 1),
        calories: 350,
        prepTimeMinutes: 30,
        difficulty: 'Dễ',
        category: 'Ăn nhẹ',
        likesCount: 30,
        isLiked: false,
      ),
      Dish(
        id: '8',
        title: 'Canh chua cá lóc',
        description: 'Món canh đậm đà hương vị miền Tây với vị chua thanh của dọc mùng, dứa và cá lóc tươi.',
        imageUrl: getImageUrl('Canh', 0),
        calories: 300,
        prepTimeMinutes: 35,
        difficulty: 'Trung bình',
        category: 'Bữa tối',
        likesCount: 45,
        isLiked: false,
      ),
    ];

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

    for (int i = 9; i <= 500; i++) {
      final cat = categoriesList[i % categoriesList.length];
      
      // Tạo tên duy nhất bằng cách kết hợp các thành phần mà không dùng số thứ tự
      final mainIdx = i % mainDishes.length;
      final ingIdx = (i ~/ mainDishes.length) % ingredients.length;
      final adjIdx = (i ~/ (mainDishes.length * ingredients.length)) % adjectives.length;
      
      final title = '${mainDishes[mainIdx]} ${ingredients[ingIdx]} ${adjectives[adjIdx]}';
      
      initialDishes.add(Dish(
        id: '$i',
        title: title,
        description: 'Món ${mainDishes[mainIdx]} đặc sản truyền thống được chế biến tinh tế với công thức ${adjectives[adjIdx]}, mang lại trải nghiệm vị giác tuyệt vời.',
        imageUrl: getImageUrl(title, i),
        calories: 200 + (i * 13) % 400,
        prepTimeMinutes: 15 + (i * 7) % 45,
        difficulty: i % 3 == 0 ? 'Khó' : (i % 2 == 0 ? 'Trung bình' : 'Dễ'),
        category: cat,
        likesCount: i % 100,
        isLiked: false,
      ));
    }
    return initialDishes;
  }

  List<Dish> get dishes => _dishes;

  List<Dish> getRecommendedDishes(String dietType) {
    if (dietType == 'Bình thường') return _dishes;
    return _dishes.where((d) => d.category == dietType || (dietType == 'Healthy' && d.category == 'Healthy')).toList();
  }

  int _currentIndex = 0;
  int get currentDishIndex => _currentIndex;

  Dish get currentDish => _dishes[_currentIndex % _dishes.length];

  void nextDish() {
    _currentIndex++;
    notifyListeners();
  }

  void previousDish() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void toggleLikeCurrent() {
    final dish = currentDish;
    final updated = dish.copyWith(
      isLiked: !dish.isLiked,
      likesCount: dish.isLiked ? dish.likesCount - 1 : dish.likesCount + 1,
    );
    _dishes[_currentIndex % _dishes.length] = updated;
    notifyListeners();
  }
}
