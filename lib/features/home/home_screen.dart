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
import 'package:n12_doan_cn/viewmodels/language_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final profileVm = context.watch<ProfileViewModel>();
    final notificationVm = context.watch<NotificationViewModel>();
    final langVm = context.watch<LanguageViewModel>();
    final filterVm = context.watch<FilterViewModel>();
    final dietType = profileVm.preferences.dietType;
    
    final recommendedDishes = viewModel.getRecommendedDishes(dietType);
    final hasDishes = recommendedDishes.isNotEmpty;
    final isFiltering = viewModel.isFilterActive;

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
                          color: isFiltering 
                              ? AppTheme.primaryOrange.withOpacity(0.1) 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.tune, 
                          color: isFiltering 
                              ? AppTheme.primaryOrange 
                              : AppTheme.textDark
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen()));
                      },
                    ),
                    Column(
                      children: [
                        Text(
                          isFiltering ? 'DANH SÁCH GỢI Ý LỌC' : langVm.t('what_to_eat'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          isFiltering ? '${recommendedDishes.length} món phù hợp' : langVm.t('swipe_more'),
                          style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
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
              if (filterVm.activeFilters.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: filterVm.activeFilters.map((f) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text(f['label']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange)),
                          backgroundColor: AppTheme.primaryOrange.withOpacity(0.1),
                          deleteIcon: const Icon(Icons.close, size: 14, color: AppTheme.primaryOrange),
                          onDeleted: () {
                            filterVm.removeFilter(f['type']!);
                            viewModel.applyFilter(filterVm, dietType);
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              
              const SizedBox(height: 10),

              // BODY: If filtering is active, show GridView of list of dishes. Otherwise, show single swipe card.
              Expanded(
                child: isFiltering
                    ? (hasDishes
                        ? GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: recommendedDishes.length,
                            itemBuilder: (context, index) {
                              final dish = recommendedDishes[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(dish: dish)));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        child: CachedNetworkImage(
                                          imageUrl: dish.imageUrl,
                                          height: 120,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            height: 120,
                                            color: Colors.grey[200],
                                            child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange, strokeWidth: 2)),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            height: 120,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.restaurant, size: 30, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                dish.title,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                dish.description,
                                                style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const Spacer(),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.local_fire_department, size: 12, color: Colors.orange),
                                                      const SizedBox(width: 2),
                                                      Text('${dish.calories} kcal', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.access_time, size: 12, color: Colors.blue),
                                                      const SizedBox(width: 2),
                                                      Text('${dish.prepTimeMinutes}p', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 80, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(langVm.currentLocale.languageCode == 'vi' ? 'Không tìm thấy món ăn nào phù hợp!' : 'No dishes found!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(langVm.currentLocale.languageCode == 'vi' ? 'Hãy thử chọn vùng miền hoặc thời tiết khác nhé.' : 'Try adjusting your region or weather filters.', style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen()));
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
                                child: Text(langVm.t('apply'), style: const TextStyle(color: Colors.white)),
                              ),
                            ],
                          ))
                    : (hasDishes ? Center(
                        child: GestureDetector(
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity! < 0) {
                              viewModel.previousDish();
                            } else if (details.primaryVelocity! > 0) {
                              viewModel.nextDish();
                            }
                          },
                          onTap: () {
                            final dish = recommendedDishes[viewModel.currentDishIndex % recommendedDishes.length];
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
                                        imageUrl: recommendedDishes[viewModel.currentDishIndex % recommendedDishes.length].imageUrl,
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
                                                recommendedDishes[viewModel.currentDishIndex % recommendedDishes.length].category,
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
                                                  recommendedDishes[viewModel.currentDishIndex % recommendedDishes.length].title,
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
                                                    '${recommendedDishes[viewModel.currentDishIndex % recommendedDishes.length].likesCount}',
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    recommendedDishes[viewModel.currentDishIndex % recommendedDishes.length].isLiked ? Icons.favorite : Icons.favorite_border,
                                                    color: Colors.amber,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            recommendedDishes[viewModel.currentDishIndex % recommendedDishes.length].description,
                                            style: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              _buildStatItem(Icons.local_fire_department, '${recommendedDishes[viewModel.currentDishIndex % recommendedDishes.length].calories} ${langVm.t('calories')}', Colors.orange),
                                              _buildStatItem(Icons.access_time, '${recommendedDishes[viewModel.currentDishIndex % recommendedDishes.length].prepTimeMinutes} ${langVm.t('minutes')}', Colors.blue),
                                              _buildStatItem(Icons.restaurant_menu, recommendedDishes[viewModel.currentDishIndex % recommendedDishes.length].difficulty, Colors.green),
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
                      ) : const SizedBox()),
              ),

              if (!isFiltering && hasDishes) Padding(
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
                        recommendedDishes[viewModel.currentDishIndex % recommendedDishes.length].isLiked ? Icons.favorite : Icons.favorite_border,
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
                          MaterialPageRoute(builder: (_) => ChatbotScreen()),
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
