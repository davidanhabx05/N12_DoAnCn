import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../viewmodels/language_viewmodel.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationViewModel>();
    final langVm = context.watch<LanguageViewModel>();
    
    final List<Map<String, String>> tabs = [
      {'key': 'Tất cả', 'label': langVm.t('all')},
      {'key': 'Cá nhân', 'label': langVm.t('personal')},
      {'key': 'Khuyến mãi', 'label': langVm.t('promo')},
      {'key': 'Tin mới', 'label': langVm.t('updates')},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(langVm.t('notifications'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppTheme.primaryOrange),
            onPressed: () => vm.markAllAsRead(),
            tooltip: langVm.t('read_all'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryOrange,
          unselectedLabelColor: AppTheme.textGrey,
          indicatorColor: AppTheme.primaryOrange,
          tabs: tabs.map((t) => Tab(text: t['label'])).toList(),
          onTap: (_) => setState(() {}),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((tab) {
          final notifications = vm.getNotifications(tab['key']!);
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(langVm.t('no_notifications'), style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              return _buildNotificationCard(context, n, vm);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem n, NotificationViewModel vm) {
    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => vm.deleteNotification(n.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => vm.markAsRead(n.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Column(
            children: [
              if (n.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: CachedNetworkImage(
                    imageUrl: n.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: n.isRead ? AppTheme.backgroundLight : AppTheme.primaryOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(n.icon, color: n.isRead ? AppTheme.textGrey : AppTheme.primaryOrange, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 15)),
                              ),
                              if (!n.isRead)
                                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primaryOrange, shape: BoxShape.circle)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(n.message, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4)),
                          const SizedBox(height: 8),
                          Text(n.timeAgo, style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
