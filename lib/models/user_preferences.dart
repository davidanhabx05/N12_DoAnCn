class UserPreferences {
  final String dietType; // e.g., "Bình thường", "Chay", "Eat Clean", "Keto"
  final List<String> favoriteFlavors; // e.g., ["Cay", "Ngọt", "Thanh đạm"]
  final String budgetLevel; // e.g., "Bình dân", "Trung lưu", "Sang trọng"
  final List<String> dislikedIngredients;
  
  // New fields from designs
  final String cookingLevel; // Dễ nấu, Trung bình, Hơi khó, Khó
  final String kitchenPreference; // Tự nấu, Mua ngoài, Cả hai
  final int defaultEaters;
  final List<String> mealTimes; // Bữa sáng, Bữa trưa, Bữa tối, Ăn nhẹ
  final List<String> allergies; // Gluten, Trứng, Sữa, Hải sản, ...
  final List<String> cuisines; // Việt Nam, Trung Quốc, Thái Lan, ...
  final String spiciness; // Không cay, Ít cay, Cay vừa, Cay, Rất cay

  // Health Profile
  final double? height; // cm
  final double? weight; // kg
  final String? gender; // Nam, Nữ, Khác
  final int? birthYear;
  final String? activityLevel; // Ít vận động -> Rất năng động
  final int? calorieGoal;

  UserPreferences({
    this.dietType = 'Bình thường',
    this.favoriteFlavors = const [],
    this.budgetLevel = 'Vừa',
    this.dislikedIngredients = const [],
    this.cookingLevel = 'Dễ nấu',
    this.kitchenPreference = 'Tự nấu',
    this.defaultEaters = 2,
    this.mealTimes = const ['Bữa trưa', 'Bữa tối'],
    this.allergies = const [],
    this.cuisines = const ['Việt Nam'],
    this.spiciness = 'Cay vừa',
    this.height,
    this.weight,
    this.gender,
    this.birthYear,
    this.activityLevel,
    this.calorieGoal,
  });

  UserPreferences copyWith({
    String? dietType,
    List<String>? favoriteFlavors,
    String? budgetLevel,
    List<String>? dislikedIngredients,
    String? cookingLevel,
    String? kitchenPreference,
    int? defaultEaters,
    List<String>? mealTimes,
    List<String>? allergies,
    List<String>? cuisines,
    String? spiciness,
    double? height,
    double? weight,
    String? gender,
    int? birthYear,
    String? activityLevel,
    int? calorieGoal,
  }) {
    return UserPreferences(
      dietType: dietType ?? this.dietType,
      favoriteFlavors: favoriteFlavors ?? this.favoriteFlavors,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      dislikedIngredients: dislikedIngredients ?? this.dislikedIngredients,
      cookingLevel: cookingLevel ?? this.cookingLevel,
      kitchenPreference: kitchenPreference ?? this.kitchenPreference,
      defaultEaters: defaultEaters ?? this.defaultEaters,
      mealTimes: mealTimes ?? this.mealTimes,
      allergies: allergies ?? this.allergies,
      cuisines: cuisines ?? this.cuisines,
      spiciness: spiciness ?? this.spiciness,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      activityLevel: activityLevel ?? this.activityLevel,
      calorieGoal: calorieGoal ?? this.calorieGoal,
    );
  }
}
