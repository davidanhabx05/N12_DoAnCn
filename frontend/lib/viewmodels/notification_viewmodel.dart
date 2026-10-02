import 'package:flutter/material.dart';

import '../core/network/api_client.dart';

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

  /// Đọc thông báo từ JSON của backend (NotificationDto).
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final type = NotificationType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => NotificationType.update,
    );
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      isRead: json['isRead'] == true,
      icon: _iconFor(json['icon']?.toString()),
      type: type,
      imageUrl: (json['imageUrl']?.toString().isEmpty ?? true) ? null : json['imageUrl'].toString(),
    );
  }

  /// Tên icon lưu trong DB -> IconData.
  static IconData _iconFor(String? name) {
    switch (name) {
      case 'celebration':
        return Icons.celebration;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_offer':
        return Icons.local_offer;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'auto_awesome':
        return Icons.auto_awesome;
      default:
        return Icons.notifications;
    }
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }
}

class NotificationViewModel extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;
  List<NotificationItem> _notifications = [];
  bool _disposed = false;

  NotificationViewModel() {
    _api.sessionVersion.addListener(load);
    load();
  }

  @override
  void dispose() {
    _disposed = true;
    _api.sessionVersion.removeListener(load);
    super.dispose();
  }

  /// GET /api/notifications (thông báo chung + riêng, trừ cái đã xoá).
  Future<void> load() async {
    if (!_api.hasSession) {
      _notifications = [];
      if (!_disposed) notifyListeners();
      return;
    }
    try {
      final data = await _api.get('/api/notifications');
      if (_disposed) return;
      if (data is List) {
        _notifications = data.whereType<Map<String, dynamic>>().map(NotificationItem.fromJson).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Tải thông báo lỗi: $e');
    }
  }

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
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
      _api.post('/api/notifications/$id/read').catchError((Object e) {
        debugPrint('Đánh dấu đã đọc lỗi: $e');
      });
    }
  }

  void markAllAsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
    _api.post('/api/notifications/read-all').catchError((Object e) {
      debugPrint('Đánh dấu tất cả đã đọc lỗi: $e');
    });
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    _api.delete('/api/notifications/$id').catchError((Object e) {
      debugPrint('Xoá thông báo lỗi: $e');
    });
  }
}
