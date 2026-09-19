import 'package:flutter/material.dart';
import '../../models/dish.dart';
import 'filter_viewmodel.dart';

class HomeViewModel extends ChangeNotifier {
  final List<Dish> _allDishes = _generate500Dishes();
  late List<Dish> _filteredDishes;

  HomeViewModel() {
    _filteredDishes = List.from(_allDishes);
  }

  static List<Dish> _generate500Dishes() {
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

  List<Dish> get dishes => _filteredDishes;

  bool _isFilterActive = false;
  bool get isFilterActive => _isFilterActive;

  void applyFilter(FilterViewModel filterVm, String dietType) {
    _isFilterActive = filterVm.selectedTime != 'Bất kỳ' || 
                      filterVm.selectedRegion != null || 
                      filterVm.selectedWeather != null || 
                      filterVm.selectedMood != null;

    _filteredDishes = _allDishes.where((dish) {
      // 1. Lọc theo chế độ ăn (dietType)
      bool matchesDiet = true;
      if (dietType != 'Bình thường') {
        matchesDiet = dish.category == dietType;
      }

      // 2. Lọc theo thời gian nấu
      bool matchesTime = true;
      if (filterVm.selectedTime != 'Bất kỳ') {
        if (filterVm.selectedTime == '≤ 15 phút') matchesTime = dish.prepTimeMinutes <= 15;
        else if (filterVm.selectedTime == '15–30 phút') matchesTime = dish.prepTimeMinutes > 15 && dish.prepTimeMinutes <= 30;
        else if (filterVm.selectedTime == '30–60 phút') matchesTime = dish.prepTimeMinutes > 30 && dish.prepTimeMinutes <= 60;
        else if (filterVm.selectedTime == '> 60 phút') matchesTime = dish.prepTimeMinutes > 60;
      }
      // Slider time (Tối đa)
      matchesTime = matchesTime && (dish.prepTimeMinutes <= filterVm.maxTimeSlider);

      // 3. Lọc theo Vùng miền, Thời tiết, Tâm trạng (Tìm trong title hoặc description)
      bool matchesRegion = true;
      if (filterVm.selectedRegion != null) {
        matchesRegion = dish.title.toLowerCase().contains(filterVm.selectedRegion!.toLowerCase()) ||
                        dish.description.toLowerCase().contains(filterVm.selectedRegion!.toLowerCase());
      }

      bool matchesWeather = true;
      if (filterVm.selectedWeather != null) {
        matchesWeather = dish.title.toLowerCase().contains(filterVm.selectedWeather!.toLowerCase()) ||
                         dish.description.toLowerCase().contains(filterVm.selectedWeather!.toLowerCase());
      }

      bool matchesMood = true;
      if (filterVm.selectedMood != null) {
        matchesMood = dish.title.toLowerCase().contains(filterVm.selectedMood!.toLowerCase()) ||
                      dish.description.toLowerCase().contains(filterVm.selectedMood!.toLowerCase());
      }

      return matchesDiet && matchesTime && matchesRegion && matchesWeather && matchesMood;
    }).toList();

    _currentIndex = 0; // Reset index khi có bộ lọc mới
    notifyListeners();
  }

  List<Dish> getRecommendedDishes(String dietType) {
    // Nếu danh sách lọc bị trống, tự động quay về danh sách mặc định theo chế độ ăn
    if (_filteredDishes.isEmpty) {
      if (dietType == 'Bình thường') return _allDishes;
      return _allDishes.where((d) => d.category == dietType || (dietType == 'Healthy' && d.category == 'Healthy')).toList();
    }
    return _filteredDishes;
  }

  int _currentIndex = 0;
  int get currentDishIndex => _currentIndex;

  Dish get currentDish {
    if (_filteredDishes.isEmpty) {
      // Fallback nếu lọc không ra món nào
      return _allDishes[0];
    }
    return _filteredDishes[_currentIndex % _filteredDishes.length];
  }

  void nextDish() {
    if (_filteredDishes.isNotEmpty) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousDish() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void toggleLikeCurrent() {
    if (_filteredDishes.isEmpty) return;
    final dish = currentDish;
    final updated = dish.copyWith(
      isLiked: !dish.isLiked,
      likesCount: dish.isLiked ? dish.likesCount - 1 : dish.likesCount + 1,
    );
    
    // Cập nhật trong cả 2 danh sách
    final idxInAll = _allDishes.indexWhere((d) => d.id == dish.id);
    if (idxInAll != -1) _allDishes[idxInAll] = updated;
    
    final idxInFiltered = _filteredDishes.indexWhere((d) => d.id == dish.id);
    if (idxInFiltered != -1) _filteredDishes[idxInFiltered] = updated;
    
    notifyListeners();
  }
}
