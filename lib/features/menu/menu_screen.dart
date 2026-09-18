import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../viewmodels/language_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import 'menu_detail_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langVm = context.watch<LanguageViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          langVm.t('menu'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryOrange,
          unselectedLabelColor: AppTheme.textGrey,
          indicatorColor: AppTheme.primaryOrange,
          tabs: [
            Tab(text: langVm.t('active')),
            Tab(text: langVm.t('draft')),
            Tab(text: langVm.t('history')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MenuListView(status: 'active'),
          _MenuListView(status: 'draft'),
          _MenuListView(status: 'history'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryOrange,
        onPressed: () => _showAddMenuDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddMenuDialog(BuildContext context) {
    final viewModel = context.read<MenuViewModel>();
    final langVm = context.read<LanguageViewModel>();
    final titleController = TextEditingController();
    
    // Xác định status dựa trên tab hiện tại
    String status = 'draft';
    if (_tabController.index == 0) status = 'active';
    else if (_tabController.index == 2) status = 'history';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${langVm.t('save')} ${_getStatusLabel(status, langVm)}'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Tên thực đơn (vd: Tuần 4 tháng 9)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(langVm.t('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                viewModel.addMenuPlan(titleController.text, status);
                Navigator.pop(context);
              }
            },
            child: Text(langVm.t('save'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status, LanguageViewModel langVm) {
    if (status == 'active') return langVm.t('active');
    if (status == 'history') return langVm.t('history');
    return langVm.t('draft');
  }
}

class _MenuListView extends StatelessWidget {
  final String status;
  const _MenuListView({required this.status});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MenuViewModel>();
    final plans = viewModel.allMenuPlans.where((p) => p.status == status).toList();

    if (plans.isEmpty) {
      return const _EmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant, color: AppTheme.primaryOrange),
            ),
            title: Text(plan.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text('Ngày tạo: ${plan.date.day}/${plan.date.month}/${plan.date.year}'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MenuDetailScreen(plan: plan)),
              );
            },
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final langVm = context.watch<LanguageViewModel>();
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Text(
          langVm.currentLocale.languageCode == 'vi' ? 'Chưa có thực đơn nào' : 'No meal plans yet',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        Text(
          langVm.currentLocale.languageCode == 'vi' ? 'Hãy nhấn nút + để tạo thực đơn mới!' : 'Tap + to create a new plan!',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
        ),
      ],
    );
  }
}
