import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/filter_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/language_viewmodel.dart';
import '../../core/theme/app_theme.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FilterViewModel>();
    final homeVm = context.read<HomeViewModel>();
    final profileVm = context.read<ProfileViewModel>();
    final langVm = context.watch<LanguageViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(langVm.t('filter'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    langVm.currentLocale.languageCode == 'vi'
                        ? 'Bộ lọc này đã bao gồm các cài đặt trong hồ sơ của bạn như Kỹ năng vào bếp và Tùy chọn ăn uống'
                        : 'These filters include your profile settings like Cooking Skills and Diet Preferences.',
                    style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bộ lọc đã lưu
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(langVm.t('saved_filters'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                Text(
                  langVm.currentLocale.languageCode == 'vi'
                      ? 'Lưu bộ lọc hiện tại để dùng lại lần sau. Chỉ lưu trên máy này.'
                      : 'Save the current filter for future use. Local only.',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: langVm.currentLocale.languageCode == 'vi' ? 'Đặt tên cho bộ lọc' : 'Enter filter name',
                          filled: true,
                          fillColor: AppTheme.backgroundLight,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (val) => vm.savedFilterName = val,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange.withOpacity(0.2),
                        foregroundColor: AppTheme.primaryOrange,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(langVm.t('save'))),
                        );
                      },
                      child: Text(langVm.t('save'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Thời gian
          _buildSectionCard(langVm.t('cooking_time'), langVm.t('cooking_time'), [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vm.timeOptions.map((time) {
                final isSelected = vm.selectedTime == time;
                // Translate time options if needed
                String label = time;
                if (langVm.currentLocale.languageCode == 'en') {
                  label = time.replaceAll('phút', 'mins').replaceAll('Bất kỳ', 'Any');
                }
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryOrange,
                  backgroundColor: AppTheme.backgroundLight,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.bold),
                  onSelected: (_) => vm.setTime(time),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(langVm.currentLocale.languageCode == 'vi' ? 'TỐI THIỂU · 0 PHÚT' : 'MIN · 0 MINS', style: const TextStyle(fontSize: 11, color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
                Text('${langVm.currentLocale.languageCode == 'vi' ? 'TỐI ĐA' : 'MAX'} · ${vm.maxTimeSlider.toInt()} ${langVm.t('minutes').toUpperCase()}', style: const TextStyle(fontSize: 11, color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: vm.maxTimeSlider,
              min: 0,
              max: 180,
              activeColor: AppTheme.primaryOrange,
              onChanged: (val) => vm.setTimeSlider(val),
            ),
          ]),
          const SizedBox(height: 16),

          // Vùng miền
          _buildSectionCard(langVm.t('region'), langVm.t('region'), [
            Wrap(
              spacing: 8,
              children: vm.regionOptions.map((region) {
                final isSelected = vm.selectedRegion == region;
                String label = region;
                if (langVm.currentLocale.languageCode == 'en') {
                   if (region == 'Miền bắc') label = 'North';
                   else if (region == 'Miền trung') label = 'Central';
                   else if (region == 'Miền nam') label = 'South';
                }
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryOrange,
                  backgroundColor: AppTheme.backgroundLight,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.bold),
                  onSelected: (_) => vm.setRegion(isSelected ? null : region),
                );
              }).toList(),
            ),
          ]),
          const SizedBox(height: 16),

          // Thời tiết
          _buildSectionCard(langVm.t('weather'), langVm.t('weather'), [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vm.weatherOptions.map((weather) {
                final isSelected = vm.selectedWeather == weather;
                String label = weather;
                if (langVm.currentLocale.languageCode == 'en') {
                   if (weather == 'Nắng') label = 'Sunny';
                   else if (weather == 'Mưa') label = 'Rainy';
                   else if (weather == 'Mát mẻ') label = 'Cool';
                   else if (weather == 'Se lạnh') label = 'Chilly';
                   else if (weather == 'Lạnh') label = 'Cold';
                }
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryOrange,
                  backgroundColor: AppTheme.backgroundLight,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.bold),
                  onSelected: (_) => vm.setWeather(isSelected ? null : weather),
                );
              }).toList(),
            ),
          ]),
          const SizedBox(height: 16),

          // Tâm trạng
          _buildSectionCard(langVm.t('mood'), langVm.t('mood'), [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vm.moodOptions.map((mood) {
                final isSelected = vm.selectedMood == mood;
                String label = mood;
                if (langVm.currentLocale.languageCode == 'en') {
                   if (mood == 'Vui vẻ') label = 'Happy';
                   else if (mood == 'Buồn') label = 'Sad';
                   else if (mood == 'Bực bội') label = 'Angry';
                   else if (mood == 'Phấn khích') label = 'Excited';
                   else if (mood == 'Chán nản') label = 'Bored';
                }
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryOrange,
                  backgroundColor: AppTheme.backgroundLight,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.bold),
                  onSelected: (_) => vm.setMood(isSelected ? null : mood),
                );
              }).toList(),
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide.none,
                  backgroundColor: AppTheme.backgroundLight,
                ),
                onPressed: () {
                  vm.clearAll();
                  homeVm.applyFilter(vm, profileVm.preferences.dietType);
                },
                child: Text(langVm.t('clear_all'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  homeVm.applyFilter(vm, profileVm.preferences.dietType);
                  Navigator.pop(context);
                },
                child: Text(langVm.t('apply'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, String subtitle, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                ],
              ),
              const Icon(Icons.keyboard_arrow_down, color: AppTheme.textGrey),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
