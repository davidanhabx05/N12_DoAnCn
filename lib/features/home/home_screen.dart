import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:n12_doan_cn/viewmodels/home_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/profile_viewmodel.dart';
import 'package:n12_doan_cn/core/theme/app_theme.dart';
import 'package:n12_doan_cn/features/chatbot/chatbot_screen.dart';
import 'package:n12_doan_cn/features/recipe/recipe_detail_screen.dart';
import 'package:n12_doan_cn/features/search/filter_screen.dart';
import 'package:n12_doan_cn/features/home/notification_screen.dart';
import 'package:n12_doan_cn/viewmodels/notification_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/filter_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final profileVm = context.watch<ProfileViewModel>();
    final notificationVm = context.watch<NotificationViewModel>();
    final dietType = profileVm.preferences.dietType;
    
    final recommendedDishes = viewModel.getRecommendedDishes(dietType);
    final hasDishes = recommendedDishes.isNotEmpty;
    final dish = hasDishes 
        ? recommendedDishes[viewModel.currentDishIndex % recommendedDishes.length]
        : null;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.backgroundLight, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.watch<HomeViewModel>().isFilterActive 
                              ? AppTheme.primaryOrange.withOpacity(0.1) 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.tune, 
                          color: context.watch<HomeViewModel>().isFilterActive 
                              ? AppTheme.primaryOrange 
                              : AppTheme.textDark
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen()));
                      },
                    ),
                    const Column(
                      children: [
                        Text(
                          'HÔM NAY ĂN GÌ?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Vuốt để xem tiếp!',
                          style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications_none, color: AppTheme.textDark),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                          },
                        ),
                        if (notificationVm.unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                '${notificationVm.unreadCount}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Active Filters Row
              if (context.watch<FilterViewModel>().activeFilters.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: context.watch<FilterViewModel>().activeFilters.map((f) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(f['label']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange)),
                          backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                          deleteIcon: const Icon(Icons.close, size: 14, color: AppTheme.primaryOrange),
                          onDeleted: () {
                            final filterVm = context.read<FilterViewModel>();
                            filterVm.removeFilter(f['type']!);
                            viewModel.applyFilter(filterVm, profileVm.preferences.dietType);
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              
              const SizedBox(height: 10),

              Expanded(
                child: Center(
                  child: hasDishes ? GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! < 0) {
                        viewModel.previousDish();
                      } else if (details.primaryVelocity! > 0) {
                        viewModel.nextDish();
                      }
                    },
                    onTap: () {
                      if (dish != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(dish: dish)));
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.62,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: dish!.imageUrl,
                                  height: 280,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 280,
                                    color: Colors.grey[200],
                                    child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange)),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    height: 280,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.restaurant, size: 50, color: Colors.grey),
                                  ),
                                ),
                                Positioned(
                                  top: 16,
                                  left: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.secondaryGreen,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.eco, color: Colors.white, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          dish.category,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            dish.title,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${dish.likesCount}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              dish.isLiked ? Icons.favorite : Icons.favorite_border,
                                              color: Colors.amber,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      dish.description,
                                      style: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatItem(Icons.local_fire_department, '${dish.calories} Calo', Colors.orange),
                                        _buildStatItem(Icons.access_time, '${dish.prepTimeMinutes} phút', Colors.blue),
                                        _buildStatItem(Icons.restaurant_menu, dish.difficulty, Colors.green),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ) : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Không tìm thấy món ăn nào!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text('Hãy thử điều chỉnh bộ lọc nhé.', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen()));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
                        child: const Text('Mở Bộ lọc', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),

              if (hasDishes) Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton(
                      heroTag: 'like',
                      backgroundColor: Colors.white,
                      elevation: 4,
                      onPressed: () => viewModel.toggleLikeCurrent(),
                      child: Icon(
                        dish!.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                    const SizedBox(width: 24),
                    FloatingActionButton(
                      heroTag: 'refresh',
                      backgroundColor: Colors.white,
                      elevation: 4,
                      onPressed: () => viewModel.nextDish(),
                      child: const Icon(Icons.refresh, color: AppTheme.primaryOrange),
                    ),
                    const SizedBox(width: 24),
                    FloatingActionButton(
                      heroTag: 'ai',
                      backgroundColor: Colors.white,
                      elevation: 4,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatbotScreen()),
                        );
                      },
                      child: const Icon(Icons.auto_awesome, color: AppTheme.primaryOrange),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 13),
        ),
      ],
    );
  }
}
