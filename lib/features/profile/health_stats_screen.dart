import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import 'health_profile_form_screen.dart';

class HealthStatsScreen extends StatelessWidget {
  const HealthStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final hasData = vm.preferences.height != null && vm.preferences.weight != null;

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
                child: hasData ? _buildStatsView(context, vm) : _buildEmptyState(context),
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
          const Text('Chỉ Số Sức Khỏe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 24),
          const Text('Chưa có dữ liệu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Vui lòng cập nhật hồ sơ sức khỏe của bạn để xem các chỉ số',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text('Cập Nhật Hồ Sơ Sức Khoẻ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthProfileFormScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsView(BuildContext context, ProfileViewModel vm) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildStatCard(
          'Chỉ số BMI',
          vm.bmi?.toStringAsFixed(1) ?? '---',
          vm.bmiCategory,
          [Colors.green, Colors.teal],
          vm.bmi != null ? (vm.bmi! / 40).clamp(0, 1) : 0,
        ),
        const SizedBox(height: 24),
        
        const Text('THÔNG SỐ CHI TIẾT', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 16),
        
        Row(
          children: [
            _buildInfoBox('Cân nặng', '${vm.preferences.weight} kg', Icons.monitor_weight_outlined, Colors.blue),
            const SizedBox(width: 16),
            _buildInfoBox('Chiều cao', '${vm.preferences.height} cm', Icons.height, Colors.orange),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildInfoBox('Nhu cầu Calo', vm.tdee != null ? '${vm.tdee} kcal' : '---', Icons.local_fire_department, Colors.red),
            const SizedBox(width: 16),
            _buildInfoBox('Giới tính', vm.preferences.gender ?? '---', Icons.person_outline, Colors.purple),
          ],
        ),
        
        const SizedBox(height: 40),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthProfileFormScreen()));
          },
          child: const Text('Chỉnh sửa hồ sơ'),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String sub, List<Color> colors, double progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
          Text(sub, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
