class Dish {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int calories;
  final int prepTimeMinutes;
  final String difficulty;
  final String category;
  final int likesCount;
  final bool isLiked;
  final bool isSpecialOfTheWeek;
  final String price;

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
    required this.price,
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
    String? price,
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
      price: price ?? this.price,
    );
  }
}
