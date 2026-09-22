import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/dish.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/recipe_service.dart';
import '../../viewmodels/restaurant_viewmodel.dart';
import '../restaurant/restaurant_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Dish? dish;
  const RecipeDetailScreen({super.key, this.dish});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  void _findRestaurant(BuildContext context, String dishTitle) {
    final restaurantVm = context.read<RestaurantViewModel>();
    restaurantVm.setSearchQuery(dishTitle);
    restaurantVm.fetchNearbyFromPlaces();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RestaurantScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dish == null) return const Scaffold(body: Center(child: Text('Không có dữ liệu món ăn')));
    final recipe = RecipeService.getRecipeDetail(widget.dish!);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: AppTheme.textDark, size: 18),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: CachedNetworkImage(
                  imageUrl: recipe.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Container(color: Colors.grey[300], child: const Icon(Icons.restaurant, size: 50, color: Colors.grey)),
                ),
              ),
            ),
          ];
        },
        body: Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dish Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              recipe.title,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                            ),
                          ),
                          Text(
                            '~${(recipe.priceVnd / 1000).round()}k đ',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        recipe.description,
                        style: const TextStyle(color: AppTheme.textGrey, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetaItem(Icons.local_fire_department, '${widget.dish!.calories} Calo', Colors.orange),
                          _buildMetaItem(Icons.access_time, '${recipe.prepTimeMinutes} phút', Colors.blue),
                          _buildMetaItem(Icons.category, widget.dish!.category, Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Card gợi ý tìm quán
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.storefront, color: AppTheme.primaryOrange, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Gợi ý điểm bán tại Hà Nội',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Xem danh sách các quán ăn lân cận phục vụ món ăn này kèm khoảng cách và chỉ đường Google Maps.',
                        style: TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.map, size: 20),
                          label: const Text(
                            'TÌM QUÁN BÁN MÓN NÀY NGAY',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
                          ),
                          onPressed: () => _findRestaurant(context, recipe.title),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark)),
      ],
    );
  }
}
