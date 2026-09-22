class Dish {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int calories;
  final int prepTimeMinutes;
  final String difficulty; // e.g., "Trung bình", "Dễ"
  final String category; // e.g., "Healthy", "Bữa sáng", "Ăn nhẹ"
  final int likesCount;
  final bool isLiked;
  final bool isSpecialOfTheWeek;
  final String? region; // 'Miền bắc', 'Miền trung', 'Miền nam'
  final String? weather; // 'Nắng', 'Mưa', 'Mát mẻ', 'Se lạnh', 'Lạnh'
  final String? mood; // 'Vui vẻ', 'Buồn', 'Bực bội', 'Phấn khích', 'Chán nản'

  Dish({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.calories,
    required this.prepTimeMinutes,
    required this.difficulty,
    required this.category,
    this.likesCount = 0,
    this.isLiked = false,
    this.isSpecialOfTheWeek = false,
    this.region,
    this.weather,
    this.mood,
  });

  Dish copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    int? calories,
    int? prepTimeMinutes,
    String? difficulty,
    String? category,
    int? likesCount,
    bool? isLiked,
    bool? isSpecialOfTheWeek,
    String? region,
    String? weather,
    String? mood,
  }) {
    return Dish(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      calories: calories ?? this.calories,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      isSpecialOfTheWeek: isSpecialOfTheWeek ?? this.isSpecialOfTheWeek,
      region: region ?? this.region,
      weather: weather ?? this.weather,
      mood: mood ?? this.mood,
    );
  }
}
