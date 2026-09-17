class UserPreferences {
  final String dietType; // e.g., "Bình thường", "Chay", "Eat Clean", "Keto"
  final List<String> favoriteFlavors; // e.g., ["Cay", "Ngọt", "Thanh đạm"]
  final String budgetLevel; // e.g., "Bình dân", "Trung lưu", "Sang trọng"
  final List<String> dislikedIngredients;

  UserPreferences({
    this.dietType = 'Bình thường',
    this.favoriteFlavors = const [],
    this.budgetLevel = 'Bình dân',
    this.dislikedIngredients = const [],
  });

  UserPreferences copyWith({
    String? dietType,
    List<String>? favoriteFlavors,
    String? budgetLevel,
    List<String>? dislikedIngredients,
  }) {
    return UserPreferences(
      dietType: dietType ?? this.dietType,
      favoriteFlavors: favoriteFlavors ?? this.favoriteFlavors,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
    );
  }
}
