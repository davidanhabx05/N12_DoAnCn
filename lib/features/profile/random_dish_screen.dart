import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../viewmodels/home_viewmodel.dart';
import '../../core/theme/app_theme.dart';
import '../recipe/recipe_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RandomDishScreen extends StatefulWidget {
  const RandomDishScreen({super.key});

  @override
  State<RandomDishScreen> createState() => _RandomDishScreenState();
}

class _RandomDishScreenState extends State<RandomDishScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pickRandomDish() async {
    setState(() => _isSpinning = true);
    await _controller.forward(from: 0);
    
    if (!mounted) return;
    
    final dishes = context.read<HomeViewModel>().dishes;
    final randomDish = dishes[Random().nextInt(dishes.length)];
    
    setState(() => _isSpinning = false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎲 Món ăn dành cho bạn!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: randomDish.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(randomDish.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(dish: randomDish)));
              },
              child: const Text('Xem công thức', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ăn Theo Ý Trời'), backgroundColor: Colors.white, foregroundColor: AppTheme.textDark, elevation: 0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: Icon(Icons.casino, size: 120, color: AppTheme.primaryOrange.withOpacity(_isSpinning ? 1.0 : 0.6)),
            ),
            const SizedBox(height: 40),
            const Text('Bạn đang phân vân không biết ăn gì?', style: TextStyle(fontSize: 16, color: AppTheme.textGrey)),
            const SizedBox(height: 8),
            const Text('Hãy để "Ý Trời" quyết định giúp bạn!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _isSpinning ? null : _pickRandomDish,
              child: const Text('QUAY NGAY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
