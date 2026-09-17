import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/menu_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import '../../models/menu_plan.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Thực đơn của tôi',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppTheme.primaryOrange,
            unselectedLabelColor: AppTheme.textGrey,
            indicatorColor: AppTheme.primaryOrange,
            tabs: [
              Tab(text: 'Đang áp dụng'),
              Tab(text: 'Nháp'),
              Tab(text: 'Lịch sử'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
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
      ),
    );
  }

  void _showAddMenuDialog(BuildContext context) {
    final viewModel = context.read<MenuViewModel>();
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo thực đơn mới'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Tên thực đơn (vd: Tuần 4 tháng 9)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                viewModel.addMenuPlan(titleController.text, '');
                Navigator.pop(context);
              }
            },
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
      return _buildEmptyState();
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
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
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
        const Text(
          'Chưa có thực đơn nào',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hãy nhấn nút + để tạo thực đơn mới!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
        ),
      ],
    );
  }
}
