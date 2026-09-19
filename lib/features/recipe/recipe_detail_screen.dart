import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/recipe_detail.dart';
import '../../models/dish.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/recipe_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Dish? dish;
  const RecipeDetailScreen({super.key, this.dish});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.bookmark_border, color: AppTheme.textDark, size: 18),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.favorite_border, color: Colors.red, size: 18),
                  ),
                  onPressed: () {},
                ),
              ],
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
          child: Column(
            children: [
              // Recipe Info Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
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
                          '${recipe.priceVnd.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe.description,
                      style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetaItem(Icons.favorite, '${recipe.likesCount}', Colors.red),
                        _buildMetaItem(Icons.access_time, '${recipe.prepTimeMinutes} phút', Colors.blue),
                        _buildMetaItem(Icons.restaurant_menu, recipe.difficulty, Colors.orange),
                        _buildMetaItem(Icons.people_outline, '${recipe.servings} người', Colors.green),
                      ],
                    ),
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryOrange,
                unselectedLabelColor: AppTheme.textGrey,
                indicatorColor: AppTheme.primaryOrange,
                tabs: const [
                  Tab(text: 'Nguyên liệu'),
                  Tab(text: 'Các bước'),
                  Tab(text: 'Dinh dưỡng'),
                  Tab(text: 'Thông tin'),
                ],
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Nguyên liệu Tab
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: recipe.ingredients.length,
                      itemBuilder: (context, index) {
                        final ing = recipe.ingredients[index];
                        return CheckboxListTile(
                          title: Text(ing.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                          subtitle: Text(ing.amount, style: const TextStyle(color: AppTheme.textGrey)),
                          value: ing.isChecked,
                          activeColor: AppTheme.primaryOrange,
                          onChanged: (val) {
                            setState(() {
                              ing.isChecked = val ?? false;
                            });
                          },
                        );
                      },
                    ),

                    // Các bước Tab
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: recipe.steps.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppTheme.primaryOrange,
                                child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  recipe.steps[index],
                                  style: const TextStyle(fontSize: 14, color: AppTheme.textDark, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Dinh dưỡng Tab
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(recipe.nutritionInfo, style: const TextStyle(fontSize: 15, color: AppTheme.textDark)),
                    ),

                    // Thông tin Tab
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(recipe.extraInfo, style: const TextStyle(fontSize: 15, color: AppTheme.textDark)),
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

  Widget _buildMetaItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textDark)),
      ],
    );
  }
}
