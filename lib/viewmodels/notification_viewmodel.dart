import 'package:flutter/material.dart';

enum NotificationType { promo, personal, update }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final IconData icon;
  final NotificationType type;
  final String? imageUrl;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.icon,
    required this.type,
    this.imageUrl,
  });
// ... (giữ nguyên timeAgo)

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }
}

class NotificationViewModel extends ChangeNotifier {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Chào mừng bạn đến với FoodChoice!',
      message: 'Hãy sẵn sàng khám phá những công thức nấu ăn ngon và để AI tạo ra những menu tuyệt vời cho bạn.',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      icon: Icons.celebration,
      isRead: true,
      type: NotificationType.update,
      imageUrl: 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    NotificationItem(
      id: '2',
      title: 'Món mới: Phở Thìn Lò Đúc',
      message: 'Bạn đã thử nấu món Phở chuẩn vị Hà Nội theo công thức mới chưa? Xem ngay nhé!',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      icon: Icons.restaurant,
      type: NotificationType.personal,
      imageUrl: 'https://images.pexels.com/photos/2641886/pexels-photo-2641886.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    NotificationItem(
      id: '4',
      title: 'Ưu đãi: Giảm 20% tại Bún Chả Sinh Từ',
      message: 'Dành riêng cho thành viên FoodChoice, giảm ngay 20% khi dùng bữa tại cửa hàng.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.local_offer,
      type: NotificationType.promo,
      imageUrl: 'https://images.pexels.com/photos/2410602/pexels-photo-2410602.jpeg?auto=compress&cs=tinysrgb&w=400',
    ),
    NotificationItem(
      id: '5',
      title: 'Thử thách: 7 ngày ăn uống Healthy',
      message: 'Tham gia thử thách ăn xanh cùng cộng đồng để nhận huy hiệu "Sống khỏe" ngay hôm nay!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.fitness_center,
      type: NotificationType.update,
    ),
    NotificationItem(
      id: '8',
      title: 'AI gợi ý: Món canh cho ngày nắng',
      message: 'Dựa trên thời tiết hôm nay, AI gợi ý bạn nên nấu món Canh Chua Cá Lóc để thanh nhiệt.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      icon: Icons.auto_awesome,
      type: NotificationType.personal,
    ),
  ];

  NotificationType _selectedTab = NotificationType.update; // Default to 'Tất cả' logic will be in UI
  
  List<NotificationItem> getNotifications(String tab) {
    if (tab == 'Tất cả') return _notifications;
    if (tab == 'Khuyến mãi') return _notifications.where((n) => n.type == NotificationType.promo).toList();
    if (tab == 'Tin mới') return _notifications.where((n) => n.type == NotificationType.update).toList();
    if (tab == 'Cá nhân') return _notifications.where((n) => n.type == NotificationType.personal).toList();
    return _notifications;
  }

  List<NotificationItem> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
