import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/feed_viewmodel.dart';
import '../../core/theme/app_theme.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FeedViewModel>();

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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                    ),
                    child: Row(
                      children: const [
                        Text('Khám phá', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        Icon(Icons.keyboard_arrow_down, color: AppTheme.textDark),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: AppTheme.textDark),
                        onPressed: () {},
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tính năng đăng bài sẽ sớm ra mắt!')),
                            );
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
                        // Author Header
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: CachedNetworkImageProvider(post.authorAvatarUrl),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  Text(post.timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                              const Spacer(),
                              IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
                            ],
                          ),
                        ),

                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(0),
                          child: CachedNetworkImage(
                            imageUrl: post.imageUrl,
                            height: 350,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey[100]),
                            errorWidget: (context, url, error) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                          ),
                        ),

                        // Actions
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
                              IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
                              IconButton(icon: const Icon(Icons.send_outlined), onPressed: () {}),
                              const Spacer(),
                              IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
                            ],
                          ),
                        ),

                        // Caption & Likes
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${post.likesCount} lượt thích', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                              const SizedBox(height: 8),
                              const Text('Xem tất cả bình luận', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
