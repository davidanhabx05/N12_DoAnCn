import '../../models/dish.dart';
import '../../models/recipe_detail.dart';

class RecipeService {
  static RecipeDetail getRecipeDetail(Dish dish) {
    final title = dish.title;
    final cal = dish.calories;
    final time = dish.prepTimeMinutes;
    final diff = dish.difficulty;
    final price = 30000 + (cal * 7);

    List<IngredientItem> ingList = [];
    if (title.toLowerCase().contains('phở')) {
      ingList = [
        IngredientItem(name: 'bánh phở tươi', amount: '300g'),
        IngredientItem(name: 'thịt bò tái/chín', amount: '200g'),
        IngredientItem(name: 'xương ống bò', amount: '1kg'),
        IngredientItem(name: 'hành tây, gừng', amount: '1 củ'),
        IngredientItem(name: 'hoa hồi, quế, thảo quả', amount: '1 gói'),
        IngredientItem(name: 'hành lá, ngò rí', amount: '50g'),
      ];
    } else if (title.toLowerCase().contains('cơm')) {
      ingList = [
        IngredientItem(name: 'gạo thơm / gạo tấm', amount: '300g'),
        IngredientItem(name: 'thịt sườn heo / tôm / trứng', amount: '250g'),
        IngredientItem(name: 'nước mắm, đường, tỏi ớt', amount: 'Vừa đủ'),
        IngredientItem(name: 'dưa leo, cà chua, mỡ hành', amount: '100g'),
      ];
    } else if (title.toLowerCase().contains('bánh mì') || title.toLowerCase().contains('túi ngọc')) {
      ingList = [
        IngredientItem(name: 'bánh mì giòn / bánh tráng', amount: '2-4 cái'),
        IngredientItem(name: 'thịt nguội / chả lụa / rau củ', amount: '150g'),
        IngredientItem(name: 'xốt mayonnaise / xốt mè', amount: '30g'),
        IngredientItem(name: 'dưa leo, đồ chua, ngò rí', amount: '80g'),
      ];
    } else {
      ingList = [
        IngredientItem(name: 'Nguyên liệu tươi chính', amount: '350g'),
        IngredientItem(name: 'Gia vị truyền thống', amount: 'Theo khẩu vị'),
        IngredientItem(name: 'Hành tỏi băm, tiêu', amount: '20g'),
        IngredientItem(name: 'Dầu ăn / bơ thực vật', amount: '2 muỗng canh'),
      ];
    }

    List<String> steps = [];
    if (title.toLowerCase().contains('phở')) {
      steps = [
        'Hầm xương ống bò với gừng và hành tây nướng trong 6-8 tiếng.',
        'Rang thơm hoa hồi, quế, thảo quả rồi cho vào túi vải thả vào nồi nước dùng.',
        'Nêm nếm gia vị vừa ăn với nước mắm và hạt nêm.',
        'Trần bánh phở, xếp thịt bò lên trên và chan nước dùng nóng hổi.'
      ];
    } else if (title.toLowerCase().contains('cơm tấm')) {
      steps = [
        'Nấu gạo tấm với lượng nước vừa phải để cơm tơi xốp.',
        'Ướp sườn với mật ong, tỏi, hành tím và gia vị rồi nướng chín vàng.',
        'Làm chả trứng và bì heo trộn thính thơm lừng.',
        'Bày cơm ra đĩa, thêm sườn, bì, chả và mỡ hành, ăn kèm nước mắm chua ngọt.'
      ];
    } else if (title.toLowerCase().contains('gỏi cuốn')) {
      steps = [
        'Luộc tôm và thịt ba chỉ, sau đó thái lát mỏng vừa ăn.',
        'Rửa sạch rau sống, bún tươi và chuẩn bị bánh tráng.',
        'Làm ướt bánh tráng, xếp rau, bún, thịt và tôm rồi cuốn chặt tay.',
        'Pha xốt tương đậu phộng béo ngậy để chấm gỏi cuốn.'
      ];
    } else {
      steps = [
        'Sơ chế sạch sẽ các nguyên liệu tươi ngon.',
        'Tẩm ướp gia vị chuẩn vị vừa ăn trong khoảng 20 phút.',
        'Chế biến ở nhiệt độ thích hợp cho đến khi chín đều, dậy mùi thơm phức.',
        'Trình bày ra đĩa, trang trí rau thơm và thưởng thức ngay khi còn nóng.'
      ];
    }

    return RecipeDetail(
      id: dish.id,
      title: title,
      description: dish.description,
      imageUrl: dish.imageUrl,
      likesCount: dish.likesCount,
      priceVnd: price,
      prepTimeMinutes: time,
      difficulty: diff,
      servings: 4,
      ingredients: ingList,
      steps: steps,
      nutritionInfo: 'Calories: $cal kcal | Protein: 25g | Fat: 15g | Carbs: 48g',
      extraInfo: 'Món ăn giàu dinh dưỡng, rất thích hợp cho thực đơn hằng ngày của gia đình.',
    );
  }
}
