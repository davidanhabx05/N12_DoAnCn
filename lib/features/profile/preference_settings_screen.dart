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
      appBar: AppBar(
        title: const Text('Sở thích cá nhân', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Chế độ ăn uống'),
          _buildDietOptions(context, viewModel, prefs),
          const SizedBox(height: 24),
          
          _buildSectionTitle('Khẩu vị yêu thích'),
          _buildFlavorOptions(context, viewModel, prefs),
          const SizedBox(height: 24),

          _buildSectionTitle('Mức ngân sách'),
          _buildBudgetOptions(context, viewModel, prefs),
          
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Lưu thiết lập', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
    );
  }

  Widget _buildDietOptions(BuildContext context, ProfileViewModel vm, UserPreferences prefs) {
    final options = ['Bình thường', 'Healthy', 'Món Chay', 'Ăn nhẹ'];
    return Wrap(
      spacing: 10,
      children: options.map((opt) {
        final isSelected = prefs.dietType == opt;
        return ChoiceChip(
          label: Text(opt),
          selected: isSelected,
          onSelected: (val) {
            if (val) vm.updatePreferences(prefs.copyWith(dietType: opt));
          },
          selectedColor: AppTheme.primaryOrange,
          labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textDark),
        );
      }).toList(),
    );
  }

  Widget _buildFlavorOptions(BuildContext context, ProfileViewModel vm, UserPreferences prefs) {
    final options = ['Cay', 'Ngọt', 'Chua', 'Đậm đà', 'Thanh đạm'];
    return Wrap(
      spacing: 10,
      children: options.map((opt) {
        final isSelected = prefs.favoriteFlavors.contains(opt);
        return FilterChip(
          label: Text(opt),
          selected: isSelected,
          onSelected: (val) {
            final newList = List<String>.from(prefs.favoriteFlavors);
            val ? newList.add(opt) : newList.remove(opt);
            vm.updatePreferences(prefs.copyWith(favoriteFlavors: newList));
          },
          selectedColor: AppTheme.primaryOrange.withOpacity(0.3),
          checkmarkColor: AppTheme.primaryOrange,
        );
      }).toList(),
    );
  }

  Widget _buildBudgetOptions(BuildContext context, ProfileViewModel vm, UserPreferences prefs) {
    final options = ['Bình dân', 'Trung lưu', 'Sang trọng'];
    return Column(
      children: options.map((opt) {
        return RadioListTile<String>(
          title: Text(opt),
          value: opt,
          groupValue: prefs.budgetLevel,
          activeColor: AppTheme.primaryOrange,
          onChanged: (val) {
            if (val != null) vm.updatePreferences(prefs.copyWith(budgetLevel: val));
          },
        );
      }).toList(),
    );
  }
}
