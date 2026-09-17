class IngredientItem {
  final String name;
  final String amount;
  bool isChecked;

  IngredientItem({
    required this.name,
    required this.amount,
    this.isChecked = false,
  });
}

class RecipeDetail {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int likesCount;
  final int priceVnd;
  final int prepTimeMinutes;
  final String difficulty;
  final int servings;
  final List<IngredientItem> ingredients;
  final List<String> steps;
  final String nutritionInfo;
  final String extraInfo;

  RecipeDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.likesCount = 1,
    this.priceVnd = 80000,
    this.prepTimeMinutes = 90,
    this.difficulty = 'Trung Bình',
    this.servings = 4,
    required this.ingredients,
    required this.steps,
    required this.nutritionInfo,
    required this.extraInfo,
  });
}
