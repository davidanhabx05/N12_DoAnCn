import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:n12_doan_cn/viewmodels/chatbot_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/home_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/filter_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/restaurant_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/profile_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/language_viewmodel.dart';
import 'package:n12_doan_cn/core/theme/app_theme.dart';
import 'package:n12_doan_cn/features/restaurant/restaurant_screen.dart';
import 'package:n12_doan_cn/models/dish.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeVm = context.read<HomeViewModel>();
      final filterVm = context.read<FilterViewModel>();
      final restaurantVm = context.read<RestaurantViewModel>();
      final chatbotVm = context.read<ChatbotViewModel>();
      final profileVm = context.read<ProfileViewModel>();

      chatbotVm.updateAppContext(
        dishes: homeVm.dishes,
        regions: filterVm.regionOptions,
        weathers: filterVm.weatherOptions,
        moods: filterVm.moodOptions,
        restaurants: restaurantVm.filteredRestaurants.map((r) => r.name).toList(),
        prefs: profileVm.preferences,
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _findRestaurantForDish(String dishTitle) {
    final restaurantVm = context.read<RestaurantViewModel>();
    restaurantVm.setSearchQuery(dishTitle);
    restaurantVm.fetchNearbyFromPlaces();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RestaurantScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatbotViewModel>();
    final langVm = context.watch<LanguageViewModel>();

    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.backgroundLight.withOpacity(0.5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, viewModel, langVm),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.history.length,
                  itemBuilder: (context, index) {
                    final msg = viewModel.history[index];
                    return _buildMessage(msg, index, viewModel, langVm);
                  },
                ),
              ),
              if (viewModel.isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: AppTheme.primaryOrange),
                ),
              _buildInputBar(viewModel, langVm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatbotViewModel viewModel, LanguageViewModel langVm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppTheme.primaryOrange, shape: BoxShape.circle),
                    child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    langVm.t('ai_assistant_title'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('Sẵn sàng tư vấn quán', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.history, size: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppTheme.primaryOrange, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: () => viewModel.resetChat(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg, int index, ChatbotViewModel viewModel, LanguageViewModel langVm) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, left: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.primaryOrange, Color(0xFFFF8E71)]),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 15)),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppTheme.primaryOrange.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.restaurant_menu, color: AppTheme.primaryOrange, size: 16),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(msg.text, style: const TextStyle(color: AppTheme.textDark, fontSize: 15)),
                      if (msg.type == ChatMessageType.recipeList && msg.dishes != null)
                        _buildDishList(msg.dishes!),
                      if (msg.type == ChatMessageType.restaurantSuggestion && msg.recipeDetail != null)
                        _buildRestaurantCard(msg),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDishList(List<Dish> dishes) {
    return Column(
      children: [
        const SizedBox(height: 12),
        ...dishes.map((dish) => GestureDetector(
          onTap: () => _findRestaurantForDish(dish.title),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(imageUrl: dish.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dish.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: AppTheme.primaryOrange),
                          const SizedBox(width: 2),
                          const Text('Tìm quán gần đây', style: TextStyle(fontSize: 11, color: AppTheme.primaryOrange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.primaryOrange),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildRestaurantCard(ChatMessage msg) {
    final detail = msg.recipeDetail!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Món: ${detail.dish.title}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
              ),
            ),
            Text(
              '~${(detail.priceVnd / 1000).round()}k đ',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryOrange, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.map, size: 18),
            label: const Text('Tìm quán bán món này', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            onPressed: () => _findRestaurantForDish(detail.dish.title),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar(ChatbotViewModel viewModel, LanguageViewModel langVm) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.primaryOrange), onPressed: () {}),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: langVm.t('chat_hint'),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) {
                  viewModel.sendMessage(val);
                  _controller.clear();
                  _scrollToBottom();
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_none, color: AppTheme.primaryOrange),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
