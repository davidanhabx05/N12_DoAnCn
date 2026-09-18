import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:n12_doan_cn/viewmodels/language_viewmodel.dart';
import 'package:n12_doan_cn/features/home/notification_screen.dart';
import 'package:n12_doan_cn/viewmodels/notification_viewmodel.dart';
import '../../viewmodels/feed_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import '../../models/post.dart';
import 'create_post_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FeedViewModel>();
    final langVm = context.watch<LanguageViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      viewModel.setFilter(value);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'Xu hướng', child: Text('🔥 ${langVm.t('trending')}')),
                      PopupMenuItem(value: 'Mới nhất', child: Text('🕒 ${langVm.t('newest')}')),
                      PopupMenuItem(value: 'Gần bạn', child: Text('📍 ${langVm.t('near_you')}')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                      ),
                      child: Row(
                        children: [
                          Text(
                            viewModel.currentFilter == 'Xu hướng' 
                                ? langVm.t('trending')
                                : (viewModel.currentFilter == 'Mới nhất' 
                                    ? langVm.t('newest') 
                                    : langVm.t('near_you')), 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)
                          ),
                          const Icon(Icons.keyboard_arrow_down, color: AppTheme.textDark),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none, color: AppTheme.textDark),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
                            },
                          ),
                          if (context.watch<NotificationViewModel>().unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                child: Text(
                                  '${context.watch<NotificationViewModel>().unreadCount}',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: viewModel.posts.length,
                itemBuilder: (context, index) {
                  final post = viewModel.posts[index];
                  return _buildPostCard(context, post, viewModel, langVm);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, Post post, FeedViewModel viewModel, LanguageViewModel langVm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.authorAvatarUrl.startsWith('http') 
                      ? CachedNetworkImageProvider(post.authorAvatarUrl)
                      : (kIsWeb 
                          ? NetworkImage(post.authorAvatarUrl)
                          : FileImage(File(post.authorAvatarUrl))) as ImageProvider,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Row(
                      children: [
                        Text(post.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 8),
                        Icon(Icons.location_on, size: 12, color: AppTheme.primaryOrange.withOpacity(0.7)),
                        Text(' ${post.location}', style: TextStyle(color: AppTheme.primaryOrange.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
              ],
            ),
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: post.imageUrl.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: post.imageUrl,
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : (kIsWeb
                    ? Image.network(
                        post.imageUrl,
                        height: 350,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(post.imageUrl),
                        height: 350,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: post.isLiked ? Colors.red : AppTheme.textDark,
                  ),
                  onPressed: () => viewModel.toggleLike(post.id),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => _showComments(context, post, viewModel, langVm),
                ),
                IconButton(
                  icon: const Icon(Icons.send_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã sao chép liên kết bài viết!')),
                    );
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: post.isSaved ? AppTheme.primaryOrange : AppTheme.textDark,
                  ),
                  onPressed: () => viewModel.toggleSave(post.id),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${post.likesCount} ${langVm.t('likes')}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
                    children: [
                      TextSpan(text: post.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: '  '),
                      TextSpan(text: post.caption),
                    ],
                  ),
                ),
                if (post.comments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: GestureDetector(
                      onTap: () => _showComments(context, post, viewModel, langVm),
                      child: Text(
                        '${langVm.t('view_all')} ${post.comments.length} ${langVm.t('comments').toLowerCase()}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showComments(BuildContext context, Post post, FeedViewModel viewModel, LanguageViewModel langVm) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(langVm.t('comments'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(),
              Expanded(
                child: post.comments.isEmpty
                    ? Center(child: Text(langVm.t('no_notifications'), style: const TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: post.comments.length,
                        itemBuilder: (context, idx) {
                          final c = post.comments[idx];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(c.authorAvatarUrl)),
                            title: Text(c.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.content, style: const TextStyle(color: AppTheme.textDark, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(c.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(hintText: '${langVm.t('comments')}...', border: InputBorder.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(color: AppTheme.primaryOrange, shape: BoxShape.circle),
                    child: IconButton(
                      onPressed: () {
                        if (commentController.text.isNotEmpty) {
                          viewModel.addComment(post.id, commentController.text);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(langVm.t('post'))));
                        }
                      },
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['❤️', '🙌', '🔥', '😋', '🥘', '👍'].map((emoji) {
                  return GestureDetector(
                    onTap: () => commentController.text += emoji,
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
