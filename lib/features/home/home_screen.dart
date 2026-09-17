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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final profileVm = context.watch<ProfileViewModel>();
    final dietType = profileVm.preferences.dietType;
    
    final recommendedDishes = viewModel.getRecommendedDishes(dietType);
    final dish = recommendedDishes.isNotEmpty 
        ? recommendedDishes[viewModel.currentDishIndex % recommendedDishes.length]
        : viewModel.currentDish;

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
                      icon: const Icon(Icons.tune, color: AppTheme.textDark),
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
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: AppTheme.textDark),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: Center(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! < 0) {
                        // Kéo sang trái (vận tốc âm) -> Quay lại món trước
                        viewModel.previousDish();
                      } else if (details.primaryVelocity! > 0) {
                        // Kéo sang phải (vận tốc dương) -> Sang món mới
                        viewModel.nextDish();
                      }
                    },
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(dish: dish)));
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
                                  imageUrl: dish.imageUrl,
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
                  ),
                ),
              ),

              Padding(
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
                        dish.isLiked ? Icons.favorite : Icons.favorite_border,
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
