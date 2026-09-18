import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../core/theme/app_theme.dart';

class HealthProfileFormScreen extends StatefulWidget {
  const HealthProfileFormScreen({super.key});

  @override
  State<HealthProfileFormScreen> createState() => _HealthProfileFormScreenState();
}

class _HealthProfileFormScreenState extends State<HealthProfileFormScreen> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _birthYearController;
  late TextEditingController _calorieGoalController;
  String? _gender;
  String? _activityLevel;

  @override
  void initState() {
    super.initState();
    final prefs = context.read<ProfileViewModel>().preferences;
    _heightController = TextEditingController(text: prefs.height?.toString() ?? '');
    _weightController = TextEditingController(text: prefs.weight?.toString() ?? '');
    _birthYearController = TextEditingController(text: prefs.birthYear?.toString() ?? '');
    _calorieGoalController = TextEditingController(text: prefs.calorieGoal?.toString() ?? '');
    _gender = prefs.gender;
    _activityLevel = prefs.activityLevel;
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _birthYearController.dispose();
    _calorieGoalController.dispose();
    super.dispose();
  }

  void _save() {
    final vm = context.read<ProfileViewModel>();
    final current = vm.preferences;
    vm.updatePreferences(current.copyWith(
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      birthYear: int.tryParse(_birthYearController.text),
      calorieGoal: int.tryParse(_calorieGoalController.text),
      gender: _gender,
      activityLevel: _activityLevel,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

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
                    _buildSectionTitle('Chiều cao'),
                    _buildInputField(_heightController, 'Nhập chiều cao', 'cm'),
                    const SizedBox(height: 20),

                    _buildSectionTitle('Cân nặng'),
                    _buildInputField(_weightController, 'Nhập cân nặng', 'kg'),
                    const SizedBox(height: 20),

                    _buildSectionTitle('Giới tính'),
                    _buildChoiceRow(['Nam', 'Nữ', 'Khác'], _gender, (val) => setState(() => _gender = val)),
                    const SizedBox(height: 20),

                    _buildSectionTitle('Năm sinh'),
                    _buildInputField(_birthYearController, 'Nhập năm sinh', ''),
                    const SizedBox(height: 20),

                    _buildSectionTitle('Mức độ vận động'),
                    _buildMultiChoiceRow(['Ít vận động', 'Vận động nhẹ', 'Vận động vừa phải', 'Năng động', 'Rất năng động'], _activityLevel != null ? [_activityLevel!] : [], (val) => setState(() => _activityLevel = val)),
                    const SizedBox(height: 20),

                    _buildSectionTitle('Mục tiêu calo/ngày (tùy chọn)'),
                    _buildInputField(_calorieGoalController, 'Nhập mục tiêu', 'kcal'),
                    const SizedBox(height: 30),

                    _buildResultCard(vm),
                    const SizedBox(height: 30),

                    _buildInfoBox('Đây là công cụ tin cậy đánh giá tình trạng cơ thể dựa trên cân nặng, chiều cao, độ tuổi và giới tính...'),
                    const SizedBox(height: 16),
                    _buildDisclaimerBox(),
                    const SizedBox(height: 40),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _save,
                      child: const Text('Lưu Hồ Sơ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
          const Text('Hồ Sơ Sức Khoẻ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
              child: const Icon(Icons.save),
            ),
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hint, String suffix) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: hint, border: InputBorder.none),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Text(suffix, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildChoiceRow(List<String> options, String? selected, Function(String) onSelected) {
    return Row(
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onSelected(opt),
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              color: isSelected ? Colors.white : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? Border.all(color: AppTheme.primaryOrange.withOpacity(0.5)) : null,
            ),
            child: Text(opt, style: TextStyle(color: isSelected ? AppTheme.textDark : Colors.grey, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultCard(ProfileViewModel vm) {
    // Temporary recalculation for preview
    final h = double.tryParse(_heightController.text) ?? 0;
    final w = double.tryParse(_weightController.text) ?? 0;
    double? bmi;
    if (h > 0) bmi = w / ((h/100) * (h/100));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.primaryOrange.withOpacity(0.05), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: AppTheme.primaryOrange, size: 24),
              SizedBox(width: 8),
              Text('Chỉ số sức khoẻ của bạn', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryOrange)),
            ],
          ),
          const SizedBox(height: 20),
          _buildResultItem('BMI (chỉ số khối cơ thể)', bmi != null ? '${bmi.toStringAsFixed(1)} kg/m²' : '--- kg/m²'),
          const SizedBox(height: 16),
          _buildResultItem('TDEE (Tổng năng lượng tiêu hao)', vm.tdee != null ? '${vm.tdee} Calo/ngày' : '--- Calo/ngày'),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey),
              Text(' Cần nhập đầy đủ: giới tính, năm sinh, mức vận động', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.2))),
          alignment: Alignment.center,
          child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildInfoBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.blue, height: 1.5)),
    );
  }

  Widget _buildDisclaimerBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tuyên bố miễn trừ trách nhiệm y tế', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange)),
          SizedBox(height: 8),
          Text(
            'FoodieChoice cung cấp các gợi ý món ăn chỉ nhằm mục đích tham khảo và không nhằm thay thế cho tư vấn, chẩn đoán hoặc điều trị y tế chuyên nghiệp.',
            style: TextStyle(fontSize: 11, color: Colors.orange, height: 1.5),
          ),
        ],
      ),
    );
  }
}
