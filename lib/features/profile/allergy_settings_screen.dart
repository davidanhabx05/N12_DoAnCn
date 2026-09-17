import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AllergySettingsScreen extends StatefulWidget {
  const AllergySettingsScreen({super.key});

  @override
  State<AllergySettingsScreen> createState() => _AllergySettingsScreenState();
}

class _AllergySettingsScreenState extends State<AllergySettingsScreen> {
  final Map<String, bool> _allergies = {
    'Hải sản': false,
    'Đậu phộng': true,
    'Sữa & Sản phẩm từ sữa': false,
    'Trứng': false,
    'Đậu nành': false,
    'Bột mì (Gluten)': false,
    'Hạt cây': false,
  };

  final Map<String, bool> _dietary = {
    'Không ăn cay': false,
    'Ăn chay (Vegetarian)': false,
    'Thuần chay (Vegan)': false,
    'Ít tinh bột (Low-carb)': true,
    'Không đường': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dị ứng & Kiêng khem'), backgroundColor: Colors.white, foregroundColor: AppTheme.textDark, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('THỰC PHẨM DỊ ỨNG', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: _allergies.keys.map((key) {
                return CheckboxListTile(
                  title: Text(key, style: const TextStyle(fontSize: 15)),
                  value: _allergies[key],
                  activeColor: AppTheme.primaryOrange,
                  onChanged: (val) => setState(() => _allergies[key] = val!),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('CHẾ ĐỘ KIÊNG KHEM', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: _dietary.keys.map((key) {
                return SwitchListTile(
                  title: Text(key, style: const TextStyle(fontSize: 15)),
                  value: _dietary[key]!,
                  activeColor: AppTheme.primaryOrange,
                  onChanged: (val) => setState(() => _dietary[key] = val),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật tùy chọn ăn uống!')));
            },
            child: const Text('LƯU CÀI ĐẶT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
