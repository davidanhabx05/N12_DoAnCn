import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/menu_plan.dart';
import '../../models/dish.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/language_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import '../recipe/recipe_detail_screen.dart';

class MenuDetailScreen extends StatelessWidget {
  final MenuPlan plan;

  const MenuDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final homeVm = context.read<HomeViewModel>();
    final menuVm = context.read<MenuViewModel>();
    final langVm = context.watch<LanguageViewModel>();
    
    final List<Dish> dishes = plan.dishIds.map((id) {
      return homeVm.dishes.firstWhere((d) => d.id == id, orElse: () => homeVm.dishes[0]);
    }).toList();

    int totalCalories = 0;
    for (var d in dishes) {
      totalCalories += d.calories;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(plan.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: dishes.isNotEmpty ? dishes[0].imageUrl : 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg',
                    fit: BoxFit.cover,
                  ),
                  Container(color: Colors.black.withOpacity(0.3)),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () => _confirmDelete(context, menuVm, langVm),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        _buildStatItem(langVm.t('total_calories'), '$totalCalories', Icons.local_fire_department, Colors.orange),
                        _buildVerticalDivider(),
                        _buildStatItem(langVm.t('dishes_count'), '${dishes.length}', Icons.restaurant_menu, Colors.blue),
                        _buildVerticalDivider(),
                        _buildStatItem(langVm.t('status'), _getStatusLabel(plan.status, langVm), Icons.info_outline, Colors.green),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(langVm.t('dish_list'), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final dish = dishes[index];
                return _buildDishItem(context, dish, langVm);
              },
              childCount: dishes.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Row(
          children: [
            if (plan.status != 'active')
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    menuVm.updatePlanStatus(plan.id, 'active');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(langVm.currentLocale.languageCode == 'vi' ? 'Đã áp dụng thực đơn!' : 'Meal plan applied!')));
                  },
                  child: Text(langVm.t('apply_now'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            if (plan.status == 'active')
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: AppTheme.primaryOrange),
                  ),
                  onPressed: () {
                    menuVm.updatePlanStatus(plan.id, 'history');
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(langVm.currentLocale.languageCode == 'vi' ? 'Đã lưu vào lịch sử.' : 'Saved to history.')));
                  },
                  child: Text(langVm.t('complete'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryOrange)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textGrey)),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey[200]);
  }

  String _getStatusLabel(String status, LanguageViewModel langVm) {
    switch (status) {
      case 'active': return langVm.t('active');
      case 'draft': return langVm.t('draft');
      case 'history': return langVm.t('history');
      default: return status;
    }
  }

  Widget _buildDishItem(BuildContext context, Dish dish, LanguageViewModel langVm) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(dish: dish))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(imageUrl: dish.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dish.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  Text('${dish.calories} ${langVm.t('calories')} • ${dish.prepTimeMinutes} ${langVm.t('minutes')}', style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text('${dish.likesCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MenuViewModel vm, LanguageViewModel langVm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(langVm.t('delete_plan')),
        content: Text(langVm.t('confirm_delete')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(langVm.t('cancel'))),
          TextButton(
            onPressed: () {
              vm.deletePlan(plan.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
            },
            child: Text(langVm.t('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
