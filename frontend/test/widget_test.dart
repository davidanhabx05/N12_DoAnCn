// Kiểm thử đơn vị phần logic còn ở app (phần lọc món / chatbot đã chuyển sang backend
// và được kiểm thử ở backend/src/test). Chạy: flutter test

import 'package:flutter_test/flutter_test.dart';

import 'package:n12_doan_cn/core/utils/allergy_labels.dart';
import 'package:n12_doan_cn/core/utils/text_utils.dart';
import 'package:n12_doan_cn/models/dish.dart';
import 'package:n12_doan_cn/models/restaurant.dart';
import 'package:n12_doan_cn/viewmodels/profile_viewmodel.dart';

void main() {
  group('TextUtils', () {
    test('normalize bỏ dấu tiếng Việt và chữ hoa', () {
      expect(TextUtils.normalize('Phở Bò  Hà Nội'), 'pho bo ha noi');
      expect(TextUtils.normalize('Bún Đậu Mắm Tôm'), 'bun dau mam tom');
    });

    test('formatVnd', () {
      expect(TextUtils.formatVnd(45000), '45.000');
      expect(TextUtils.formatVnd(1250000), '1.250.000');
    });
  });

  group('Đọc JSON từ backend', () {
    test('Dish.fromJson', () {
      final dish = Dish.fromJson({
        'id': '3',
        'title': 'Phở bò truyền thống',
        'description': 'Ngon',
        'imageUrl': 'https://example.com/pho.jpg',
        'calories': 500,
        'prepTimeMinutes': 60,
        'difficulty': 'Khó',
        'category': 'Bữa sáng',
        'likesCount': 156,
        'isLiked': true,
        'isSpecialOfTheWeek': false,
        'region': 'Miền bắc',
        'weather': 'Se lạnh',
        'mood': 'Vui vẻ',
        'price': 60000,
      });
      expect(dish.id, '3');
      expect(dish.isLiked, isTrue);
      expect(dish.price, 60000);
      expect(dish.region, 'Miền bắc');
    });

    test('Restaurant.fromJson', () {
      final r = Restaurant.fromJson({
        'id': 'res_1',
        'name': 'Chay Aummee',
        'address': '26 Châu Long',
        'rating': 4.2,
        'imageUrl': '',
        'category': 'Món Chay',
        'distance': '1.2 km',
        'isOpen': false,
        'latitude': 21.0,
        'longitude': 105.8,
        'mapsQuery': 'Chay Aummee, 26 Châu Long',
      });
      expect(r.isOpen, isFalse);
      expect(r.mapsQuery, 'Chay Aummee, 26 Châu Long');
    });
  });

  test('nhãn dị ứng ở hai màn cài đặt được quy về cùng một tên', () {
    expect(AllergyLabels.canonical('Bột mì (Gluten)'), 'Gluten');
    expect(AllergyLabels.canonical('Trứng'), 'Trứng');
  });

  group('Chỉ số sức khoẻ', () {
    test('BMI và phân loại', () {
      final bmi = ProfileViewModel.calculateBmi(65, 170)!;
      expect(bmi, closeTo(22.49, 0.01));
      expect(ProfileViewModel.bmiCategoryOf(bmi), 'Cân đối');
      expect(ProfileViewModel.calculateBmi(null, 170), isNull);
    });

    test('TDEE theo Mifflin-St Jeor', () {
      final year = DateTime.now().year - 25;
      final tdee = ProfileViewModel.calculateTdee(
        weight: 65,
        height: 170,
        birthYear: year,
        gender: 'Nam',
        activityLevel: 'Ít vận động',
      );
      // BMR = 10*65 + 6.25*170 - 5*25 + 5 = 1592.5 ; x1.2 = 1911
      expect(tdee, 1911);
    });
  });
}
