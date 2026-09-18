import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../viewmodels/home_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import '../../models/dish.dart';
import '../recipe/recipe_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RandomDishScreen extends StatefulWidget {
  const RandomDishScreen({super.key});

  @override
  State<RandomDishScreen> createState() => _RandomDishScreenState();
}

class _RandomDishScreenState extends State<RandomDishScreen> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  Dish? _selectedDish;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _pickDish() async {
    setState(() {
      _isPicking = true;
      _selectedDish = null;
    });
    
    await _shakeController.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 1));
    _shakeController.stop();

    if (!mounted) return;
    
    final dishes = context.read<HomeViewModel>().dishes;
    if (dishes.isNotEmpty) {
      setState(() {
        _selectedDish = dishes[Random().nextInt(dishes.length)];
        _isPicking = false;
      });
    } else {
      setState(() {
        _isPicking = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy món ăn nào phù hợp với bộ lọc hiện tại!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.4), Colors.black.withOpacity(0.1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              const Spacer(),
              _selectedDish == null ? _buildInitialState() : _buildResultState(),
              const Spacer(),
              _buildBottomButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Column(
            children: [
              const Text('ĂN THEO Ý TRỜI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2)),
              Text('Đừng giận nhau vì: Em ăn gì cũng được!', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
            ],
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.tune, color: Colors.white),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Column(
      children: [
        Text(_isPicking ? 'AI ĐANG TÌM KIẾM...' : 'AI ĐÃ SẴN SÀNG', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          _isPicking ? 'Đang chuẩn bị món ăn ngon nhất cho bạn...' : 'Gợi ý ngẫu nhiên món ăn theo nhu cầu của bạn!', 
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)
        ),
        const SizedBox(height: 60),
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final double offset = _shakeController.value * 10 - 5;
            return Transform.translate(
              offset: Offset(offset, 0),
              child: Icon(
                _isPicking ? Icons.restaurant_menu : Icons.restaurant, 
                size: 120, 
                color: _isPicking ? AppTheme.primaryOrange : Colors.white.withOpacity(0.3)
              ),
            );
          },
        ),
        const SizedBox(height: 40),
        if (!_isPicking) ...[
          const Text('Nhấn nút hoặc lắc điện thoại!', style: TextStyle(color: Colors.white, fontSize: 16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lightbulb, color: Colors.amber, size: 14),
              Text(' Mẹo: Lắc điện thoại để AI gợi ý liền!', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
            ],
          ),
        ] else 
          const CircularProgressIndicator(color: Colors.white),
      ],
    );
  }

  Widget _buildResultState() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
            Text(' KẾT QUẢ! ', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
          ],
        ),
        Text('Món ăn hoàn hảo cho bạn!', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(dish: _selectedDish!))),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: _selectedDish!.imageUrl,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Row(
                          children: [
                            _buildTag('Healthy', Colors.green),
                            const SizedBox(width: 8),
                            _buildTag(_selectedDish!.category, Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(_selectedDish!.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                          Row(
                            children: [
                              const Text('4', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(width: 4),
                              const Icon(Icons.favorite, color: Colors.amber, size: 18),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedDish!.description,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(Icons.local_fire_department, '${_selectedDish!.calories} Calo', Colors.orange),
                          _buildStat(Icons.access_time, '${_selectedDish!.prepTimeMinutes} phút', Colors.blue),
                          _buildStat(Icons.restaurant_menu, _selectedDish!.difficulty, Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStat(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomButton() {
    return FloatingActionButton(
      onPressed: _isPicking ? null : _pickDish,
      backgroundColor: Colors.white,
      child: Icon(Icons.refresh, color: AppTheme.primaryOrange, size: 30),
    );
  }
}
