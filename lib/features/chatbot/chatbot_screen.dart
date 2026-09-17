import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:n12_doan_cn/viewmodels/chatbot_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/home_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/filter_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/restaurant_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/profile_viewmodel.dart';
import 'package:n12_doan_cn/core/theme/app_theme.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatbotViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ lý AI Trực Tuyến'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.resetChat(),
            tooltip: 'Làm mới cuộc trò chuyện',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.history.length,
              itemBuilder: (context, index) {
                final msg = viewModel.history[index];
                final isUser = msg.isUser;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.primaryOrange : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: SelectableText(
                      msg.text,
                      style: TextStyle(
                        color: isUser ? Colors.white : AppTheme.textDark,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: AppTheme.primaryOrange),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập câu hỏi cho trợ lý AI...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (val) {
                      viewModel.sendMessage(val);
                      _controller.clear();
                      _scrollToBottom();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryOrange),
                  onPressed: () {
                    viewModel.sendMessage(_controller.text);
                    _controller.clear();
                    _scrollToBottom();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
