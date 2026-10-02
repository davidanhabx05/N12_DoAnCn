import '../../models/dish.dart';
import '../../models/recipe_detail.dart';

class RecipeService {
  static RecipeDetail getRecipeDetail(Dish dish) {
    final title = dish.title;
    final cal = dish.calories;
    final time = dish.prepTimeMinutes;
    final diff = dish.difficulty;
    final price = dish.price; // giá tham khảo thật của món (cột price trong database)

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
        IngredientItem(name: 'Giá tham khảo tại quán', amount: 'khoảng ${(price / 1000).round()}k VNĐ'),
        IngredientItem(name: 'Khuyên dùng cho', amount: dish.category),
        if (dish.region != null) IngredientItem(name: 'Vùng miền', amount: dish.region!),
      ],
      steps: [
        'Món ăn thơm ngon chuẩn vị được phục vụ tại các quán ăn lân cận.',
        'Nhấn "Tìm quán bán món này ngay" để xem danh sách quán và chỉ đường Google Maps.'
      ],
      nutritionInfo: 'Năng lượng: khoảng $cal kcal mỗi suất',
      extraInfo: 'Món ăn có thật, được bán tại các quán quanh bạn. Giá và calo là số tham khảo.',
    );
  }
}
