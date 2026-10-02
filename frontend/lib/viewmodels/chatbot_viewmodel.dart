import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/services/local_storage_service.dart';
import '../core/services/recipe_service.dart';
import '../models/dish.dart';
import '../models/recipe_detail.dart';
import '../models/user_preferences.dart';

enum ChatMessageType { text, recipeList, restaurantSuggestion }

class ChatMessage {
  final String text;
  final bool isUser;
  final ChatMessageType type;
  final List<Dish>? dishes;
  final RecipeDetail? recipeDetail;

  /// Ảnh người dùng vừa gửi (chỉ giữ trong phiên hiện tại, server không lưu ảnh).
  final Uint8List? imageBytes;
  final String? imageMimeType;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.type = ChatMessageType.text,
    this.dishes,
    this.recipeDetail,
    this.imageBytes,
    this.imageMimeType,
  });

  /// Đọc tin nhắn từ JSON của backend (MessageDto).
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final type = ChatMessageType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => ChatMessageType.text,
    );
    final dishes = Dish.listFromJson(json['dishes']);
    final recipeJson = json['recipeDish'];
    final recipeDish = recipeJson is Map<String, dynamic> ? Dish.fromJson(recipeJson) : null;
    final isUser = json['isUser'] == true;
    var text = json['text']?.toString() ?? '';
    if (isUser && json['hadImage'] == true) text = text.isEmpty ? '📷 Ảnh món ăn' : '📷 $text';
    return ChatMessage(
      text: text,
      isUser: isUser,
      type: type,
      dishes: dishes.isEmpty ? null : dishes,
      recipeDetail: recipeDish != null ? RecipeService.getRecipeDetail(recipeDish) : null,
    );
  }
}

/// Một cuộc trò chuyện đã lưu trên server (hiển thị trong nút Lịch sử).
class ChatSessionRecord {
  final String id;
  final String title;
  final DateTime createdAt;

  ChatSessionRecord({required this.id, required this.title, required this.createdAt});

  factory ChatSessionRecord.fromJson(Map<String, dynamic> json) => ChatSessionRecord(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Cuộc trò chuyện',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      );
}

/// Chatbot: backend hiểu câu hỏi, chọn món, gọi Gemini và lưu lịch sử (POST /api/chat/messages).
class ChatbotViewModel extends ChangeNotifier {
  final ApiClient _api = ApiClient.instance;

  final List<ChatMessage> _history = [];
  List<ChatSessionRecord> _sessions = [];
  String? _sessionId;
  bool _isLoading = false;
  bool _disposed = false;

  List<ChatMessage> get history => _history;
  bool get isLoading => _isLoading;
  List<ChatSessionRecord> get sessions => List.unmodifiable(_sessions);

  ChatbotViewModel() {
    _api.sessionVersion.addListener(_onSessionChanged);
    _addWelcomeMessage();
    _sessionId = LocalStorage.getString(StorageKeys.chatSessionId);
    if (_api.hasSession) {
      if (_sessionId != null) _loadHistory(_sessionId!);
      loadSessions();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _api.sessionVersion.removeListener(_onSessionChanged);
    super.dispose();
  }

  /// Giữ để tương thích màn Chatbot: ngữ cảnh (món, quán, hồ sơ) giờ do backend tự lấy từ DB.
  void updateAppContext({
    required List<Dish> dishes,
    required List<String> regions,
    required List<String> weathers,
    required List<String> moods,
    required List<String> restaurants,
    UserPreferences? prefs,
  }) {}

  static ChatMessage _welcome() => ChatMessage(
        text: 'Xin chào! Tôi là Trợ lý AI Ẩm thực. Tôi có thể lắng nghe chia sẻ, phân tích tâm trạng & ngân sách của bạn để gợi ý các món ăn ngon và chỉ đường đến quán ăn lân cận ở Hà Nội. Bạn muốn tìm món gì hôm nay?',
        isUser: false,
      );

  void _addWelcomeMessage() {
    if (_history.isEmpty) _history.add(_welcome());
  }

  /// Đổi tài khoản -> xoá cuộc trò chuyện đang hiển thị và tải lịch sử của người mới.
  void _onSessionChanged() {
    _history.clear();
    _sessions = [];
    _setSessionId(null);
    _addWelcomeMessage();
    if (!_disposed) notifyListeners();
    if (_api.hasSession) loadSessions();
  }

  void _setSessionId(String? id) {
    _sessionId = id;
    if (id == null) {
      LocalStorage.remove(StorageKeys.chatSessionId);
    } else {
      LocalStorage.setString(StorageKeys.chatSessionId, id);
    }
  }

  // =============================================================== Gửi tin
  Future<void> sendMessage(String text, {Uint8List? imageBytes, String? imageMimeType}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && imageBytes == null) return;
    if (_isLoading) return;

    _history.add(ChatMessage(
      text: trimmed,
      isUser: true,
      imageBytes: imageBytes,
      imageMimeType: imageMimeType,
    ));
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _api.post(
        '/api/chat/messages',
        body: {
          'sessionId': _sessionId,
          'text': trimmed,
          if (imageBytes != null) 'imageBase64': base64Encode(imageBytes),
          if (imageBytes != null) 'imageMimeType': imageMimeType ?? 'image/jpeg',
        },
        timeout: const Duration(seconds: 90),
      );
      if (_disposed) return;
      if (data is Map<String, dynamic>) {
        final newId = data['sessionId']?.toString();
        final isNewSession = newId != null && newId != _sessionId;
        _setSessionId(newId);
        final reply = data['reply'];
        if (reply is Map<String, dynamic>) _history.add(ChatMessage.fromJson(reply));
        if (isNewSession && newId != null) {
          _sessions.insert(
            0,
            ChatSessionRecord(id: newId, title: data['title']?.toString() ?? 'Cuộc trò chuyện', createdAt: DateTime.now()),
          );
        }
      }
    } on ApiException catch (e) {
      _history.add(ChatMessage(
        text: e.isUnauthorized
            ? 'Phiên đăng nhập đã hết hạn. Bạn hãy đăng nhập lại (hoặc chọn "Bỏ qua") để trò chuyện nhé.'
            : '⚠️ ${e.message}',
        isUser: false,
      ));
    } catch (e) {
      _history.add(ChatMessage(text: '⚠️ Có lỗi xảy ra: $e', isUser: false));
    }

    _isLoading = false;
    if (!_disposed) notifyListeners();
  }

  // =============================================================== Lịch sử
  Future<void> loadSessions() async {
    try {
      final data = await _api.get('/api/chat/sessions');
      if (_disposed) return;
      if (data is List) {
        _sessions = data.whereType<Map<String, dynamic>>().map(ChatSessionRecord.fromJson).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _loadHistory(String id) async {
    try {
      final data = await _api.get('/api/chat/sessions/$id');
      if (_disposed) return;
      final messages = data is Map<String, dynamic> ? data['messages'] : null;
      if (messages is List) {
        _history
          ..clear()
          ..add(_welcome())
          ..addAll(messages.whereType<Map<String, dynamic>>().map(ChatMessage.fromJson));
        _setSessionId(id);
        notifyListeners();
      }
    } on ApiException catch (e) {
      if (e.statusCode == 404) _setSessionId(null); // cuộc trò chuyện đã bị xoá
    } catch (_) {}
  }

  /// Bắt đầu cuộc trò chuyện mới (cuộc cũ vẫn nằm trong Lịch sử trên server).
  void resetChat() {
    _history.clear();
    _setSessionId(null);
    _addWelcomeMessage();
    notifyListeners();
    loadSessions();
  }

  /// Mở lại một cuộc trò chuyện cũ.
  void loadSession(String id) {
    _loadHistory(id);
  }

  void deleteSession(String id) {
    _sessions.removeWhere((s) => s.id == id);
    if (id == _sessionId) {
      _history.clear();
      _setSessionId(null);
      _addWelcomeMessage();
    }
    notifyListeners();
    _api.delete('/api/chat/sessions/$id').catchError((Object e) {
      debugPrint('Xoá cuộc trò chuyện lỗi: $e');
    });
  }

  void reset() {
    _sessions = [];
    _history.clear();
    _setSessionId(null);
    _addWelcomeMessage();
    notifyListeners();
  }
}
