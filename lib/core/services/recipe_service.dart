import '../../models/dish.dart';
import '../../models/recipe_detail.dart';

class RecipeService {
  static RecipeDetail getRecipeDetail(Dish dish) {
    final title = dish.title;
    final cal = dish.calories;
    final time = dish.prepTimeMinutes;
    final diff = dish.difficulty;
    final price = 30000 + (cal * 6);

    return RecipeDetail(
      dish: dish,
      id: dish.id,
      title: title,
      description: dish.description,
      imageUrl: dish.imageUrl,
      likesCount: dish.likesCount,
      priceVnd: price,
      prepTimeMinutes: time,
      difficulty: diff,
      servings: 1,
      ingredients: [
        IngredientItem(name: 'Giá trung bình tại quán', amount: '${(price / 1000).round()}k - ${((price + 20000) / 1000).round()}k VNĐ'),
        IngredientItem(name: 'Khuyên dùng cho', amount: 'Ăn sáng, Trưa, Tối'),
        IngredientItem(name: 'Độ phổ biến tại Hà Nội', amount: 'Rất phổ biến'),
      ],
      steps: [
        'Món ăn thơm ngon chuẩn vị được phục vụ tại các quán ăn lân cận.',
        'Nhấn "Tìm quán bán món này ngay" để xem danh sách quán và chỉ đường Google Maps.'
      ],
      nutritionInfo: 'Năng lượng: $cal kcal | Đạm: 20g | Chất béo: 12g | Tinh bột: 45g',
      extraInfo: 'Gợi ý món ăn ngon phục vụ tại các nhà hàng, quán ăn chất lượng ở Hà Nội.',
    );
  }
}
