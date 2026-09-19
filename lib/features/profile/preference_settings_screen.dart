import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:n12_doan_cn/viewmodels/profile_viewmodel.dart';
import 'package:n12_doan_cn/models/user_preferences.dart';
import 'package:n12_doan_cn/core/theme/app_theme.dart';

class PreferenceSettingsScreen extends StatelessWidget {
  const PreferenceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final prefs = viewModel.preferences;

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.backgroundLight.withOpacity(0.5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildSectionTitle('Trình độ nấu nướng'),
                    _buildChoiceRow(['Dễ nấu', 'Trung bình', 'Hơi khó', 'Khó nấu'], prefs.cookingLevel, (val) {
                      viewModel.updatePreferences(prefs.copyWith(cookingLevel: val));
                    }),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Sở thích ăn uống'),
                    _buildChoiceRow(['Tự nấu', 'Mua ngoài', 'Cả hai'], prefs.kitchenPreference, (val) {
                      viewModel.updatePreferences(prefs.copyWith(kitchenPreference: val));
                    }),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Ngân sách thường dùng'),
                    _buildBudgetRow(viewModel, prefs),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Số người ăn mặc định'),
                    _buildNumberInput(prefs.defaultEaters, (val) {
                      viewModel.updatePreferences(prefs.copyWith(defaultEaters: val));
                    }),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Bữa ăn thường dùng app'),
                    _buildMultiChoiceRow(['Bữa sáng', 'Bữa trưa', 'Bữa tối', 'Ăn nhẹ'], prefs.mealTimes, (val) {
                      final newList = List<String>.from(prefs.mealTimes);
                      newList.contains(val) ? newList.remove(val) : newList.add(val);
                      viewModel.updatePreferences(prefs.copyWith(mealTimes: newList));
                    }),
                    const SizedBox(height: 40),

                    _buildSectionTitle('Chế độ Ăn'),
                    _buildDietGrid(viewModel, prefs),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Dị Ứng'),
                    _buildMultiChoiceRow([
                      'Gluten', 'Trứng', 'Sữa', 'Hải sản', 'Tôm', 'Cua', 'Ghe', 'Sò', 'Ốc', 'Mực', 'Cá biển', 'Cá sông', 'Đậu', 'Đậu phộng', 'Vừng', 'Hạnh nhân'
                    ], prefs.allergies, (val) {
                      final newList = List<String>.from(prefs.allergies);
                      newList.contains(val) ? newList.remove(val) : newList.add(val);
                      viewModel.updatePreferences(prefs.copyWith(allergies: newList));
                    }),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Món Không Thích'),
                    _buildMultiChoiceRow(['Hành', 'Sầu riêng', 'Mắm tôm', 'Rau mùi'], prefs.dislikedIngredients, (val) {
                      final newList = List<String>.from(prefs.dislikedIngredients);
                      newList.contains(val) ? newList.remove(val) : newList.add(val);
                      viewModel.updatePreferences(prefs.copyWith(dislikedIngredients: newList));
                    }),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Ẩm Thực Yêu Thích'),
                    _buildMultiChoiceRow(['Việt Nam', 'Trung Quốc', 'Thái Lan', 'Hàn Quốc', 'Nhật Bản'], prefs.cuisines, (val) {
                      final newList = List<String>.from(prefs.cuisines);
                      newList.contains(val) ? newList.remove(val) : newList.add(val);
                      viewModel.updatePreferences(prefs.copyWith(cuisines: newList));
                    }),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Độ Cay'),
                    _buildChoiceRow(['Không cay', 'Ít cay', 'Cay vừa', 'Cay', 'Rất cay'], prefs.spiciness, (val) {
                      viewModel.updatePreferences(prefs.copyWith(spiciness: val));
                    }),
                    const SizedBox(height: 40),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Lưu Cài Đặt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
              child: const Icon(Icons.close),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Text('Tùy Chọn Ăn Uống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
              child: const Icon(Icons.save),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
    );
  }

  Widget _buildChoiceRow(List<String> options, String selected, Function(String) onSelected) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final isSelected = opt == selected;
          return GestureDetector(
            onTap: () => onSelected(opt),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? Border.all(color: AppTheme.primaryOrange.withOpacity(0.5)) : null,
                boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)] : null,
              ),
              child: Text(opt, style: TextStyle(color: isSelected ? AppTheme.textDark : Colors.grey, fontWeight: FontWeight.bold)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMultiChoiceRow(List<String> options, List<String> selected, Function(String) onSelected) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return GestureDetector(
          onTap: () => onSelected(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryOrange : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(opt, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBudgetRow(ProfileViewModel vm, UserPreferences prefs) {
    final budgets = [
      {'label': 'Rẻ', 'sub': '<30k', 'icon': '💰', 'val': 'Rẻ'},
      {'label': 'Vừa', 'sub': '30-100k', 'icon': '💵', 'val': 'Vừa'},
      {'label': 'Sang', 'sub': '>100k', 'icon': '💎', 'val': 'Sang'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: budgets.map((b) {
        final isSelected = prefs.budgetLevel == b['val'];
        return GestureDetector(
          onTap: () => vm.updatePreferences(prefs.copyWith(budgetLevel: b['val'] as String)),
          child: Container(
            width: 100,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryOrange : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Text(b['icon']!, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 4),
                Text(b['label']!, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppTheme.textDark)),
                Text(b['sub']!, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : Colors.grey)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberInput(int current, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(child: Text('$current', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          const Text('người', style: TextStyle(color: Colors.grey)),
          const SizedBox(width: 12),
          IconButton(icon: const Icon(Icons.remove), onPressed: () => onChanged(current > 1 ? current - 1 : 1)),
          IconButton(icon: const Icon(Icons.add), onPressed: () => onChanged(current + 1)),
        ],
      ),
    );
  }

  Widget _buildDietGrid(ProfileViewModel vm, UserPreferences prefs) {
    final diets = [
      {'label': 'Bình thường', 'icon': '🍱'},
      {'label': 'Ketogenic(Ít tinh bột, nhiều chất béo)', 'icon': '🥑'},
      {'label': 'Ít tinh bột', 'icon': '🌽'},
      {'label': 'Thực phẩm sạch, nguyên bản', 'icon': '🥩'},
      {'label': 'Chay trứng/sữa', 'icon': '🥗'},
      {'label': 'Chay trường', 'icon': '🌱'},
      {'label': 'Chế độ ăn Địa Trung Hải', 'icon': '🥘'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2),
      itemCount: diets.length,
      itemBuilder: (context, index) {
        final d = diets[index];
        final isSelected = prefs.dietType == d['label'];
        return GestureDetector(
          onTap: () => vm.updatePreferences(prefs.copyWith(dietType: d['label']!)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryOrange.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: AppTheme.primaryOrange) : null,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
            ),
            child: Row(
              children: [
                Text(d['icon']!, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(child: Text(d['label']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        );
      },
    );
  }
}
