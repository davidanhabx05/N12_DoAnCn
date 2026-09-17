import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HealthStatsScreen extends StatelessWidget {
  const HealthStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉ số BMI & Sức khỏe'), backgroundColor: Colors.white, foregroundColor: AppTheme.textDark, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // BMI Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('Chỉ số BMI của bạn', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('22.5', style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  const Text('Cân đối', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.6,
                      child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('THÔNG SỐ CHI TIẾT', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 12),
            
            Row(
              children: [
                _buildStatBox('Cân nặng', '65 kg', Icons.monitor_weight_outlined, Colors.blue),
                const SizedBox(width: 16),
                _buildStatBox('Chiều cao', '170 cm', Icons.height, Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatBox('Mục tiêu', 'Giảm cân', Icons.flag_outlined, Colors.red),
                const SizedBox(width: 16),
                _buildStatBox('Nước uống', '1.5 / 2L', Icons.water_drop_outlined, Colors.cyan),
              ],
            ),
            
            const SizedBox(height: 30),
            const Text('NHẬT KÝ DINH DƯỠNG TUẦN NÀY', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 16),
            
            // Simple Chart Mockup
            Container(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(0.4, 'T2'),
                  _buildBar(0.7, 'T3'),
                  _buildBar(0.5, 'T4'),
                  _buildBar(0.9, 'T5'),
                  _buildBar(0.6, 'T6'),
                  _buildBar(0.3, 'T7'),
                  _buildBar(0.8, 'CN'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double factor, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 12,
          height: 100 * factor,
          decoration: BoxDecoration(color: AppTheme.primaryOrange.withOpacity(factor), borderRadius: BorderRadius.circular(6)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
