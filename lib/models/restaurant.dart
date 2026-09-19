class Restaurant {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String imageUrl;
  final String category;
  final String distance;
  final bool isOpen;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.imageUrl,
    required this.category,
    this.distance = '1.2 km',
    this.isOpen = true,
  });
}
