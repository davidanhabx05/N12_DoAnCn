import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/filter_viewmodel.dart';
import '../../core/theme/app_theme.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FilterViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bộ lọc', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
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
              children: const [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Bộ lọc này đã bao gồm các cài đặt trong hồ sơ của bạn như Kỹ năng vào bếp và Tùy chọn ăn uống',
                    style: TextStyle(fontSize: 12, color: Colors.blueAccent),
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
                const Text('Bộ lọc đã lưu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                const SizedBox(height: 4),
                const Text('Lưu bộ lọc hiện tại để dùng lại lần sau. Chỉ lưu trên máy này.', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Đặt tên cho bộ lọc',
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
                      onPressed: () {},
                      child: const Text('Lưu', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Thời gian
          _buildSectionCard('Thời gian', 'Thời gian nấu', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vm.timeOptions.map((time) {
                final isSelected = vm.selectedTime == time;
                return ChoiceChip(
                  label: Text(time),
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
              children: const [
                Text('TỐI THIỂU · 0 PHÚT', style: TextStyle(fontSize: 11, color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
                Text('TỐI ĐA · 180 PHÚT', style: TextStyle(fontSize: 11, color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
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
          _buildSectionCard('Vùng miền', 'Ẩm thực vùng miền', [
            Wrap(
              spacing: 8,
              children: vm.regionOptions.map((region) {
                final isSelected = vm.selectedRegion == region;
                return ChoiceChip(
                  label: Text(region),
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
          _buildSectionCard('Thời tiết', 'Phù hợp với thời tiết', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vm.weatherOptions.map((weather) {
                final isSelected = vm.selectedWeather == weather;
                return ChoiceChip(
                  label: Text(weather),
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
          _buildSectionCard('Tâm trạng', 'Phù hợp khi bạn đang...', [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vm.moodOptions.map((mood) {
                final isSelected = vm.selectedMood == mood;
                return ChoiceChip(
                  label: Text(mood),
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
                onPressed: () => vm.clearAll(),
                child: const Text('Xóa tất cả', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
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
                onPressed: () => Navigator.pop(context),
                child: const Text('Áp dụng', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
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
