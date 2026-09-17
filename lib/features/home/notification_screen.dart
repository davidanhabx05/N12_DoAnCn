import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thông báo', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Đọc tất cả', style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications, color: AppTheme.primaryOrange, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Chào mừng bạn đến với FoodChoice!',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                          ),
                          Text('4d trước', style: TextStyle(color: AppTheme.textGrey, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Hãy sẵn sàng khám phá những công thức nấu ăn ngon và để AI tạo ra những menu với đầy đủ dinh dưỡng theo chế độ sức khoẻ của bạn. Giúp bữa ăn không còn nhàm chán và tuyệt vời hơn!',
                        style: TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
