import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../../viewmodels/feed_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import '../chatbot/chatbot_screen.dart';
import '../restaurant/restaurant_screen.dart';
import '../feed/create_post_screen.dart';
import 'settings_screen.dart';
import 'preference_settings_screen.dart';
import 'random_dish_screen.dart';
import 'allergy_settings_screen.dart';
import 'health_stats_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Text(
                  'Trang Cá Nhân',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: AppTheme.textDark),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tính năng chỉnh sửa hồ sơ sẽ sớm ra mắt!')),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppTheme.primaryOrange.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: AppTheme.primaryOrange, size: 18),
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primaryOrange.withOpacity(0.2),
                    child: const Icon(Icons.person, size: 40, color: AppTheme.primaryOrange),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    viewModel.isLoggedIn ? 'Người dùng Foodie' : 'Khách hàng',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  Text(
                    viewModel.isLoggedIn ? (viewModel.userEmail ?? 'user@domain.com') : 'Đăng nhập để lưu công thức',
                    style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(title: 'Bài viết', count: viewModel.postCount.toString()),
                      _StatColumn(title: 'Đã follow', count: viewModel.followingCount.toString()),
                      _StatColumn(title: 'Follower', count: viewModel.followerCount.toString()),
                      _StatColumn(title: 'Thích', count: viewModel.totalLikes.toString()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Prompt Card
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppTheme.primaryOrange.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.restaurant_menu, color: AppTheme.primaryOrange),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Hôm nay bạn nấu món gì?', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined, color: AppTheme.primaryOrange),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen(openCamera: true)));
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section: TÁC VỤ
            const Text('TÁC VỤ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildMenuItem(Icons.auto_awesome, 'Trợ lý AI Gemini', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen()));
                  }),
                  _buildMenuItem(Icons.map_outlined, 'Gợi Ý Quán Ăn (Google Maps)', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RestaurantScreen()));
                  }),
                  _buildMenuItem(Icons.calendar_today, 'Thực Đơn Của Tôi', onTap: () {
                    Provider.of<AppViewModel>(context, listen: false).setIndex(3);
                  }),
                  _buildMenuItem(Icons.bookmark_outline, 'Công Thức Đã Lưu', onTap: () {
                    Provider.of<AppViewModel>(context, listen: false).setIndex(1);
                  }),
                  _buildMenuItem(Icons.style_outlined, 'Ăn Theo Ý Trời (Xúc xắc)', isLast: true, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RandomDishScreen()));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section: CÁ NHÂN HOÁ
            const Text('CÁ NHÂN HOÁ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildMenuItem(Icons.restaurant, 'Chế độ ăn của tôi', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PreferenceSettingsScreen()));
                  }),
                  _buildMenuItem(Icons.local_dining, 'Dị ứng & Kiêng khem', onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AllergySettingsScreen()));
                  }),
                  _buildMenuItem(Icons.favorite_outline, 'Chỉ số BMI & Sức khỏe', isLast: true, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthStatsScreen()));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section: TÀI KHOẢN
            const Text('TÀI KHOẢN', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildMenuItem(Icons.info_outline, 'Về Chúng Tôi', isLast: true, onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Hôm Nay Ăn Gì?',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.restaurant_menu, color: AppTheme.primaryOrange, size: 40),
                      children: [
                        const Text('Ứng dụng gợi ý món ăn và quản lý thực đơn hàng đầu dành cho người Việt.'),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section: ẢNH CỦA BẠN
            if (viewModel.isLoggedIn) ...[
              const Text('ẢNH CỦA BẠN', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              _buildPhotoGrid(context),
            ],

            const SizedBox(height: 24),

            // Login / Logout Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: viewModel.isLoggedIn ? Colors.red.withOpacity(0.1) : AppTheme.primaryOrange.withOpacity(0.1),
                foregroundColor: viewModel.isLoggedIn ? Colors.red : AppTheme.primaryOrange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              onPressed: () {
                if (viewModel.isLoggedIn) {
                  viewModel.logout();
                } else {
                  viewModel.login('admin@doancn.com', 'password123');
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(viewModel.isLoggedIn ? Icons.logout : Icons.login),
                  const SizedBox(width: 8),
                  Text(
                    viewModel.isLoggedIn ? 'Đăng xuất' : 'Đăng nhập ngay',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(BuildContext context) {
    final feedVm = context.watch<FeedViewModel>();
    final userPosts = feedVm.posts.where((p) => p.authorName == 'Bạn (Foodie)').toList();

    if (userPosts.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Text('Bạn chưa có bài đăng nào.', style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        final post = userPosts[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: post.imageUrl.startsWith('http')
              ? CachedNetworkImage(imageUrl: post.imageUrl, fit: BoxFit.cover)
              : (kIsWeb 
                  ? Image.network(post.imageUrl, fit: BoxFit.cover)
                  : Image.file(File(post.imageUrl), fit: BoxFit.cover)),
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isLast = false, VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.backgroundLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppTheme.primaryOrange, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 14)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          onTap: onTap ?? () {},
        ),
        if (!isLast) const Divider(height: 1, indent: 56, endIndent: 16, color: AppTheme.backgroundLight),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String title;
  final String count;

  const _StatColumn({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
      ],
    );
  }
}
