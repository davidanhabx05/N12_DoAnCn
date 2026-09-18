import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../viewmodels/language_viewmodel.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final langVm = context.watch<LanguageViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(langVm.t('settings'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('GIAO DIỆN', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: const Icon(Icons.translate, color: AppTheme.primaryOrange),
              title: Text(langVm.t('language'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(langVm.currentLocale.languageCode == 'vi' ? 'Tiếng Việt' : 'English', style: const TextStyle(color: AppTheme.textGrey)),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              onTap: () {
                _showLanguageDialog(context, langVm);
              },
            ),
          ),
// ...
          const SizedBox(height: 20),

          const Text('CHUNG', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_outlined, color: AppTheme.primaryOrange),
              title: const Text('Thông Báo', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              value: vm.notificationsEnabled,
              activeColor: AppTheme.primaryOrange,
              onChanged: (val) => vm.toggleNotifications(val),
            ),
          ),
          const SizedBox(height: 20),

          const Text('QUYỀN RIÊNG TƯ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: const Icon(Icons.person_off_outlined, color: AppTheme.primaryOrange),
              title: const Text('Tài khoản đã chặn và đã ẩn', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 20),

          const Text('DỮ LIỆU', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: const Icon(Icons.delete_outline, color: AppTheme.primaryOrange),
              title: const Text('Xóa Cache', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                vm.clearCache();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa cache thành công!')));
              },
            ),
          ),
          const SizedBox(height: 20),

          const Text('NGUY HIỂM', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: Colors.red),
              title: const Text('Xóa Tài Khoản', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageViewModel langVm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(langVm.t('language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tiếng Việt'),
              trailing: langVm.currentLocale.languageCode == 'vi' ? const Icon(Icons.check, color: AppTheme.primaryOrange) : null,
              onTap: () {
                langVm.setLocale(const Locale('vi'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              trailing: langVm.currentLocale.languageCode == 'en' ? const Icon(Icons.check, color: AppTheme.primaryOrange) : null,
              onTap: () {
                langVm.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
