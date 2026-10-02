import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../models/dish.dart';
import '../../viewmodels/language_viewmodel.dart';
import '../recipe/recipe_detail_screen.dart';

/// Loại danh sách hiển thị ở màn này.
enum FavoriteKind { liked, saved }

/// Danh sách bài viết (món ăn) người dùng đã thích hoặc đã lưu.
/// Dữ liệu lấy từ backend: GET /api/me/likes và GET /api/me/bookmarks.
class FavoriteDishesScreen extends StatefulWidget {
  final FavoriteKind kind;
  const FavoriteDishesScreen({super.key, required this.kind});

  @override
  State<FavoriteDishesScreen> createState() => _FavoriteDishesScreenState();
}

class _FavoriteDishesScreenState extends State<FavoriteDishesScreen> {
  final ApiClient _api = ApiClient.instance;
  List<Dish> _dishes = [];
  bool _isLoading = true;
  String? _error;

  bool get _isLiked => widget.kind == FavoriteKind.liked;
  String get _path => _isLiked ? '/api/me/likes' : '/api/me/bookmarks';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _api.get(_path);
      if (!mounted) return;
      setState(() {
        _dishes = Dish.listFromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Bỏ thích / bỏ lưu: xoá khỏi danh sách ngay, lỗi thì hoàn tác.
  Future<void> _remove(Dish dish) async {
    final previous = _dishes;
    setState(() => _dishes = _dishes.where((d) => d.id != dish.id).toList());
    try {
      await _api.delete('$_path/${dish.id}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _dishes = previous);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final langVm = context.watch<LanguageViewModel>();
    final isVi = langVm.currentLocale.languageCode == 'vi';
    final title = _isLiked
        ? (isVi ? 'Bài viết đã thích' : 'Liked posts')
        : (isVi ? 'Bài viết đã lưu' : 'Saved posts');

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryOrange,
        onRefresh: _load,
        child: _buildBody(isVi, langVm),
      ),
    );
  }

  Widget _buildBody(bool isVi, LanguageViewModel langVm) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
    }
    if (_error != null) {
      return _buildMessage(
        Icons.wifi_off,
        isVi ? 'Không tải được danh sách. Kéo xuống để thử lại.' : 'Could not load the list. Pull down to retry.',
      );
    }
    if (_dishes.isEmpty) {
      return _buildMessage(
        _isLiked ? Icons.favorite_border : Icons.bookmark_border,
        _isLiked
            ? (isVi ? 'Bạn chưa thích bài viết nào.' : 'You have not liked any posts yet.')
            : (isVi ? 'Bạn chưa lưu bài viết nào.' : 'You have not saved any posts yet.'),
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _dishes.length,
      itemBuilder: (context, index) => _buildItem(_dishes[index], isVi, langVm),
    );
  }

  /// Dùng ListView để vẫn kéo xuống tải lại được khi danh sách trống.
  Widget _buildMessage(IconData icon, String text) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(icon, size: 56, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textGrey, fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildItem(Dish dish, bool isVi, LanguageViewModel langVm) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(dish: dish)));
        if (mounted) _load();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: dish.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[100]),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.grey[200], child: const Icon(Icons.restaurant, size: 30, color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dish.category, style: const TextStyle(color: AppTheme.primaryOrange, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    dish.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dish.prepTimeMinutes} ${langVm.t('minutes')} · ${dish.calories} ${langVm.t('calories')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: _isLiked ? (isVi ? 'Bỏ thích' : 'Unlike') : (isVi ? 'Bỏ lưu' : 'Remove'),
              icon: Icon(_isLiked ? Icons.favorite : Icons.bookmark, color: _isLiked ? Colors.redAccent : AppTheme.primaryOrange),
              onPressed: () => _remove(dish),
            ),
          ],
        ),
      ),
    );
  }
}
