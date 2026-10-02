import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:n12_doan_cn/viewmodels/search_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/language_viewmodel.dart';
import 'package:n12_doan_cn/core/theme/app_theme.dart';
import 'package:n12_doan_cn/features/recipe/recipe_detail_screen.dart';

class AllDishesScreen extends StatelessWidget {
  const AllDishesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchVm = context.watch<SearchViewModel>();
    final langVm = context.watch<LanguageViewModel>();
    final allDishes = searchVm.filteredDishes;

    return Scaffold(
      appBar: AppBar(
        title: Text(langVm.currentLocale.languageCode == 'vi' ? 'Tất cả món ăn' : 'All Dishes'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.textDark,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.backgroundLight, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: allDishes.isEmpty
            ? Center(
                child: Text(
                  langVm.currentLocale.languageCode == 'vi' ? 'Không có món ăn nào' : 'No dishes found',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: allDishes.length,
                itemBuilder: (context, index) {
                  final dish = allDishes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RecipeDetailScreen(dish: dish)),
                      );
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
                                          const Icon(Icons.payments_outlined, size: 12, color: Colors.green),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${dish.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')} đ',
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                                          ),
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
              ),
      ),
    );
  }
}
