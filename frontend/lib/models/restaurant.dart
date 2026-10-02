class Restaurant {
  final String id;
  final String name;
  final String address;

  /// Điểm đánh giá; 0 = nguồn dữ liệu chưa có điểm (vd quán lấy từ OpenStreetMap).
  final double rating;

  /// Ảnh quán; chuỗi rỗng = nguồn dữ liệu không có ảnh.
  final String imageUrl;
  final String category;
  final String distance;
  final bool isOpen;
  final double latitude;
  final double longitude;

  /// Chuỗi backend gợi ý để mở Google Maps chính xác nhất.
  final String? mapsQuery;

  /// place_id của Google (nếu quán lấy từ Google Places).
  final String? placeId;

  /// false = không rõ giờ mở cửa -> không hiển thị nhãn "Đang mở cửa / Đã đóng cửa".
  final bool openKnown;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.imageUrl,
    required this.category,
    this.distance = '1.2 km',
    this.isOpen = true,
    this.latitude = 21.028511, // Tọa độ trung tâm Hà Nội mặc định
    this.longitude = 105.804817,
    this.mapsQuery,
    this.placeId,
    this.openKnown = true,
  });

  /// Đọc quán ăn từ JSON của backend (RestaurantDto).
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v, double fallback) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? fallback;
    return Restaurant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      rating: toDouble(json['rating'], 0),
      imageUrl: json['imageUrl']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Nhà hàng',
      distance: json['distance']?.toString() ?? '-- km',
      isOpen: json['isOpen'] != false,
      latitude: toDouble(json['latitude'], 21.028511),
      longitude: toDouble(json['longitude'], 105.804817),
      mapsQuery: json['mapsQuery']?.toString(),
      placeId: json['placeId']?.toString(),
      openKnown: json['openKnown'] != false,
    );
  }

  Restaurant copyWith({
    String? id,
    String? name,
    String? address,
    double? rating,
    String? imageUrl,
    String? category,
    String? distance,
    bool? isOpen,
    double? latitude,
    double? longitude,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      distance: distance ?? this.distance,
      isOpen: isOpen ?? this.isOpen,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mapsQuery: mapsQuery,
      placeId: placeId,
      openKnown: openKnown,
    );
  }
}
