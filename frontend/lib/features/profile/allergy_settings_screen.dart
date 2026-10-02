import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/allergy_labels.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/profile_viewmodel.dart';

class AllergySettingsScreen extends StatefulWidget {
  const AllergySettingsScreen({super.key});

  @override
  State<AllergySettingsScreen> createState() => _AllergySettingsScreenState();
}

class _AllergySettingsScreenState extends State<AllergySettingsScreen> {
  final Map<String, bool> _allergies = {
    'Hải sản': false,
    'Đậu phộng': false,
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
    'Ít tinh bột (Low-carb)': false,
    'Không đường': false,
  };

  @override
  void initState() {
    super.initState();
    // Nạp lựa chọn đã lưu trong hồ sơ (đồng bộ với màn "Tùy chọn ăn uống")
    final prefs = context.read<ProfileViewModel>().preferences;
    for (final key in _allergies.keys.toList()) {
      _allergies[key] = prefs.allergies.contains(AllergyLabels.canonical(key));
    }
    for (final key in _dietary.keys.toList()) {
      _dietary[key] = prefs.dietaryRestrictions.contains(key);
    }
    if (prefs.spiciness == 'Không cay') _dietary['Không ăn cay'] = true;
    if (prefs.dietType == 'Chay trường') _dietary['Thuần chay (Vegan)'] = true;
    if (prefs.dietType == 'Chay trứng/sữa') _dietary['Ăn chay (Vegetarian)'] = true;
    if (prefs.dietType == 'Ít tinh bột') _dietary['Ít tinh bột (Low-carb)'] = true;
  }

  void _save() {
    final vm = context.read<ProfileViewModel>();
    final prefs = vm.preferences;

    // Giữ các dị ứng chọn ở màn khác (Tôm, Cua, Vừng...), chỉ thay các mục của màn này
    final managed = _allergies.keys.map(AllergyLabels.canonical).toSet();
    final allergies = prefs.allergies.where((a) => !managed.contains(a)).toList()
      ..addAll(_allergies.entries.where((e) => e.value).map((e) => AllergyLabels.canonical(e.key)));

    final restrictions = _dietary.entries.where((e) => e.value).map((e) => e.key).toList();

    var spiciness = prefs.spiciness;
    if (_dietary['Không ăn cay'] == true) {
      spiciness = 'Không cay';
    } else if (spiciness == 'Không cay') {
      spiciness = 'Cay vừa';
    }

    var dietType = prefs.dietType;
    if (_dietary['Thuần chay (Vegan)'] == true) {
      dietType = 'Chay trường';
    } else if (_dietary['Ăn chay (Vegetarian)'] == true) {
      dietType = 'Chay trứng/sữa';
    } else if (dietType == 'Chay trường' || dietType == 'Chay trứng/sữa') {
      dietType = 'Bình thường';
    }

    vm.updatePreferences(prefs.copyWith(
      allergies: allergies,
      dietaryRestrictions: restrictions,
      spiciness: spiciness,
      dietType: dietType,
    ));

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(const SnackBar(content: Text('Đã cập nhật tùy chọn ăn uống!')));
  }

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
            onPressed: _save,
            child: const Text('LƯU CÀI ĐẶT', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
