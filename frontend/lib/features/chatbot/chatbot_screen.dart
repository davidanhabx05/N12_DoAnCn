import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:n12_doan_cn/core/utils/image_utils.dart';
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
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechReady = false;
  bool _isListening = false;
  int _lastMessageCount = 0;

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
    context.read<RestaurantViewModel>().searchForDish(dishTitle);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RestaurantScreen()),
    );
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;
    context.read<ChatbotViewModel>().sendMessage(text);
    _controller.clear();
    _scrollToBottom();
  }

  /// Chọn ảnh món ăn để AI nhận diện & gợi ý quán.
  Future<void> _pickImage() async {
    final vm = context.read<ChatbotViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final caption = _controller.text;
      _controller.clear();
      vm.sendMessage(
        caption,
        imageBytes: bytes,
        imageMimeType: picked.mimeType ?? ImageUtils.guessMimeType(picked.name),
      );
      _scrollToBottom();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Không thể mở thư viện ảnh.')));
    }
  }

  /// Nhập bằng giọng nói: nói xong sẽ tự gửi câu hỏi.
  Future<void> _toggleListening(LanguageViewModel langVm) async {
    final messenger = ScaffoldMessenger.of(context);
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    try {
      if (!_speechReady) {
        _speechReady = await _speech.initialize(
          onStatus: (status) {
            if ((status == 'done' || status == 'notListening') && mounted) {
              setState(() => _isListening = false);
            }
          },
          onError: (_) {
            if (mounted) setState(() => _isListening = false);
          },
        );
      }
    } catch (_) {
      _speechReady = false;
    }

    if (!_speechReady) {
      messenger.showSnackBar(const SnackBar(
        content: Text('Thiết bị chưa hỗ trợ hoặc chưa cấp quyền micro cho nhận dạng giọng nói.'),
      ));
      return;
    }

    setState(() => _isListening = true);
    await _speech.listen(
      localeId: langVm.currentLocale.languageCode == 'vi' ? 'vi_VN' : 'en_US',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        _controller.text = result.recognizedWords;
        _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
        if (result.finalResult) {
          if (mounted) setState(() => _isListening = false);
          _submit(result.recognizedWords);
        }
      },
    );
  }

  void _showHistorySheet(ChatbotViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return SafeArea(
          child: Consumer<ChatbotViewModel>(
            builder: (context, vm, _) {
              final sessions = vm.sessions;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text('Lịch sử trò chuyện', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    ),
                    const SizedBox(height: 8),
                    if (sessions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Chưa có cuộc trò chuyện nào được lưu.', style: TextStyle(color: AppTheme.textGrey)),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: sessions.length,
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            return ListTile(
                              leading: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryOrange),
                              title: Text(session.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(session.createdAt), style: const TextStyle(fontSize: 12)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                onPressed: () => vm.deleteSession(session.id),
                              ),
                              onTap: () {
                                vm.loadSession(session.id);
                                Navigator.pop(sheetContext);
                                _scrollToBottom();
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _speech.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatbotViewModel>();
    final langVm = context.watch<LanguageViewModel>();

    // Tự cuộn xuống khi có tin nhắn mới (kể cả khi AI trả lời xong)
    if (viewModel.history.length != _lastMessageCount) {
      _lastMessageCount = viewModel.history.length;
      _scrollToBottom();
    }

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
            onPressed: () => _showHistorySheet(viewModel),
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
          child: msg.imageBytes == null
              ? Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 15))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(msg.imageBytes!, width: 180, fit: BoxFit.cover),
                    ),
                    if (msg.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 15)),
                    ],
                  ],
                ),
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
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined, color: AppTheme.primaryOrange),
            onPressed: viewModel.isLoading ? null : _pickImage,
          ),
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
                textInputAction: TextInputAction.send,
                onSubmitted: _submit,
              ),
            ),
          ),
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : AppTheme.primaryOrange),
            onPressed: () => _toggleListening(langVm),
          ),
        ],
      ),
    );
  }
}
