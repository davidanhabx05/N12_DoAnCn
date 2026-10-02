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
  final String? region;
  final String? weather;
  final String? mood;
  final int price;

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
    this.price = 35000,
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
    int? price,
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
      price: price ?? this.price,
    );
  }

  /// Đọc món ăn từ JSON của backend (DishDto).
  factory Dish.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, [int fallback = 0]) => v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? fallback;
    return Dish(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      calories: toInt(json['calories']),
      prepTimeMinutes: toInt(json['prepTimeMinutes']),
      difficulty: json['difficulty']?.toString() ?? 'Dễ',
      category: json['category']?.toString() ?? '',
      likesCount: toInt(json['likesCount']),
      isLiked: json['isLiked'] == true,
      isSpecialOfTheWeek: json['isSpecialOfTheWeek'] == true,
      region: json['region']?.toString(),
      weather: json['weather']?.toString(),
      mood: json['mood']?.toString(),
      price: toInt(json['price'], 35000),
    );
  }

  static List<Dish> listFromJson(dynamic data) {
    if (data is! List) return [];
    return data.whereType<Map<String, dynamic>>().map(Dish.fromJson).toList();
  }
}
