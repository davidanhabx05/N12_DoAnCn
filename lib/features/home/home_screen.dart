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
import '../../models/dish.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details, HomeViewModel viewModel) {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.25; // Ngưỡng vuốt (25% màn hình)

    if (_dragOffset.dx.abs() > threshold) {
      // Vuốt đủ mạnh -> Bay ra khỏi màn hình
      final flyOutOffset = Offset(
        _dragOffset.dx > 0 ? screenWidth : -screenWidth,
        _dragOffset.dy,
      );

      setState(() {
        _dragOffset = flyOutOffset;
      });

      // Đợi animation bay ra xong thì đổi món và reset
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          viewModel.nextDish();
          setState(() {
            _dragOffset = Offset.zero;
          });
        }
      });
    } else {
      // Vuốt nhẹ -> Trượt về vị trí cũ
      _slideAnimation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));

      _animationController.forward(from: 0).then((_) {
        setState(() {
          _dragOffset = Offset.zero;
        });
      });
    }
  }

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

    // Lấy index hiện tại
    final currentIndex = viewModel.currentDishIndex;

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
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: viewModel.isFilterActive
                              ? AppTheme.primaryOrange.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                            Icons.tune,
                            color: viewModel.isFilterActive
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

              // --- ACTIVE FILTERS ---
              if (context.watch<FilterViewModel>().activeFilters.isNotEmpty)
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

              // --- CARD STACK (CHIA BÀI) ---
              Expanded(
                child: hasDishes
                    ? Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Thẻ thứ 3 (nằm dưới cùng)
                    if (recommendedDishes.length > 2)
                      _buildBackgroundCard(
                        dish: recommendedDishes[(currentIndex + 2) % recommendedDishes.length],
                        scale: 0.85,
                        yOffset: 40,
                      ),

                    // 2. Thẻ thứ 2 (nằm giữa)
                    if (recommendedDishes.length > 1)
                      _buildBackgroundCard(
                        dish: recommendedDishes[(currentIndex + 1) % recommendedDishes.length],
                        scale: 0.92,
                        yOffset: 20,
                      ),

                    // 3. Thẻ trên cùng (có thể vuốt)
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final offset = _animationController.isAnimating
                            ? _slideAnimation.value
                            : _dragOffset;

                        // Tính góc xoay dựa trên vị trí kéo
                        final rotation = offset.dx / MediaQuery.of(context).size.width * 0.2;

                        return Transform.translate(
                          offset: offset,
                          child: Transform.rotate(
                            angle: rotation,
                            child: GestureDetector(
                              onPanUpdate: _onPanUpdate,
                              onPanEnd: (details) => _onPanEnd(details, viewModel),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => RecipeDetailScreen(dish: recommendedDishes[currentIndex % recommendedDishes.length]))
                                );
                              },
                              child: _buildDishCard(recommendedDishes[currentIndex % recommendedDishes.length], langVm),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )
                    : _buildEmptyState(langVm),
              ),

              // --- BOTTOM BUTTONS ---
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
                        recommendedDishes[currentIndex % recommendedDishes.length].isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
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

  // Widget cho các thẻ nằm phía sau (không vuốt được)
  Widget _buildBackgroundCard({required Dish dish, required double scale, required double yOffset}) {
    return Transform.translate(
      offset: Offset(0, yOffset),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: 0.8,
          child: IgnorePointer( // Không cho tương tác với thẻ dưới
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.62,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CachedNetworkImage(
                  imageUrl: dish.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget cho thẻ trên cùng (chứa đầy đủ thông tin)
  Widget _buildDishCard(Dish dish, LanguageViewModel langVm) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.62,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                        _buildStatItem(Icons.local_fire_department, '${dish.calories} ${langVm.t('calories')}', Colors.orange),
                        _buildStatItem(Icons.access_time, '${dish.prepTimeMinutes} ${langVm.t('minutes')}', Colors.blue),
                        // ĐÃ SỬA: Đổi từ độ khó sang giá tiền
                        _buildStatItem(Icons.monetization_on, dish.price, Colors.green),
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
  }

  Widget _buildEmptyState(LanguageViewModel langVm) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search_off, size: 80, color: Colors.grey),
        const SizedBox(height: 16),
        Text(langVm.currentLocale.languageCode == 'vi' ? 'Không tìm thấy món ăn nào!' : 'No dishes found!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(langVm.currentLocale.languageCode == 'vi' ? 'Hãy thử điều chỉnh bộ lọc nhé.' : 'Please try adjusting your filters.', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterScreen()));
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
          child: Text(langVm.t('apply'), style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // ĐÃ SỬA: Chống tràn viền (Overflow)
  Widget _buildStatItem(IconData icon, String label, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}