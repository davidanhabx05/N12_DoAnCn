import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../core/services/recipe_service.dart';
import '../models/dish.dart';
import '../models/recipe_detail.dart';
import '../models/user_preferences.dart';

enum ChatMessageType { text, recipeList, recipeStep }

class ChatMessage {
  final String text;
  final bool isUser;
  final ChatMessageType type;
  final List<Dish>? dishes;
  final RecipeDetail? recipeDetail;
  final int? currentStepIndex;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.type = ChatMessageType.text,
    this.dishes,
    this.recipeDetail,
    this.currentStepIndex,
  });
}

class ChatbotViewModel extends ChangeNotifier {
  final List<ChatMessage> _history = [];
  bool _isLoading = false;
  String? _activeModelName;
  
  // Ngữ context ứng dụng
  List<Dish> _availableDishes = [];
  List<String> _regions = [];
  List<String> _weathers = [];
  List<String> _moods = [];
  List<String> _restaurantNames = [];
  UserPreferences? _userPrefs;

  List<ChatMessage> get history => _history;
  bool get isLoading => _isLoading;

  void updateAppContext({
    required List<Dish> dishes,
    required List<String> regions,
    required List<String> weathers,
    required List<String> moods,
    required List<String> restaurants,
    UserPreferences? prefs,
  }) {
    _availableDishes = dishes;
    _regions = regions;
    _weathers = weathers;
    _moods = moods;
    _restaurantNames = restaurants;
    _userPrefs = prefs;
    notifyListeners();
  }

  ChatbotViewModel() {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    if (_history.isEmpty) {
      _history.add(ChatMessage(
        text: 'Xin chào! Tôi là chuyên gia ẩm thực AI. Tôi biết mọi giá cả và công thức món ăn trong app. Bạn muốn hỏi về món nào?',
        isUser: false,
      ));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _history.add(ChatMessage(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    final apiKey = (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
    if (apiKey.isEmpty) {
      _addErrorMessage('Chưa tìm thấy API Key trong file .env');
      _isLoading = false;
      notifyListeners();
      return;
    }

    final currentTime = DateFormat('EEEE, dd/MM/yyyy HH:mm').format(DateTime.now());
    
    // 1. TÌM KIẾM DỮ LIỆU MÓN ĂN (RECIPES & PRICES)
    String dishContext = "";
    Dish? foundDish;
    RecipeDetail? foundDetail;
    
    final lowerText = text.toLowerCase();
    
    // Tìm kiếm món cụ thể
    for (var dish in _availableDishes) {
      if (lowerText.contains(dish.title.toLowerCase())) {
        foundDish = dish;
        foundDetail = RecipeService.getRecipeDetail(dish);
        dishContext += "\nTHÔNG TIN CHI TIẾT MÓN '${dish.title}':\n"
            "- Giá bán: ${foundDetail.priceVnd} VNĐ\n"
            "- Giá trị dinh dưỡng: ${dish.calories} kcal, ${foundDetail.nutritionInfo}\n"
            "- Thời gian chuẩn bị: ${dish.prepTimeMinutes} phút\n"
            "- Độ khó: ${dish.difficulty}\n"
            "- NGUYÊN LIỆU: ${foundDetail.ingredients.map((i) => "${i.name} (${i.amount})").join(", ")}\n"
            "- CÔNG THỨC CÁC BƯỚC NẤU: ${foundDetail.steps.asMap().entries.map((e) => "Bước ${e.key + 1}: ${e.value}").join(". ")}\n";
        break; 
      }
    }

    // 2. TÌM KIẾM DỮ LIỆU TÍNH NĂNG
    String featureContext = "";
    if (lowerText.contains('lọc') || lowerText.contains('tìm kiếm')) {
      featureContext = "\nỨng dụng có các bộ lọc thông minh sau: Vùng miền, Thời tiết, Tâm trạng.";
    }

    // 3. TÌM KIẾM DỮ LIỆU NHÀ HÀNG
    String restaurantContext = "";
    if (lowerText.contains('quán') || lowerText.contains('nhà hàng')) {
      restaurantContext = "\nDanh sách nhà hàng đề xuất: ${_restaurantNames.take(5).join(", ")}.";
    }

    // 4. THÔNG TIN SỞ THÍCH CÁ NHÂN
    String prefContext = "";
    if (_userPrefs != null) {
      prefContext = "\nSỞ THÍCH CỦA NGƯỜI DÙNG: Chế độ ăn ${_userPrefs!.dietType}, Khẩu vị ${_userPrefs!.favoriteFlavors.join(", ")}, Ngân sách ${_userPrefs!.budgetLevel}.\n";
    }

    final systemContext = 
        "Hệ thống: Bạn là 'Quản gia AI' của ứng dụng 'Hôm Nay Ăn Gì'. \n"
        "Thời gian hiện tại: $currentTime. \n"
        "DỮ LIỆU ỨNG DỤNG CUNG CẤP:\n"
        "$dishContext $featureContext $restaurantContext $prefContext \n\n"
        "Người dùng: $text";

    String? response;
    if (_activeModelName != null) {
      response = await _trySpecificModel(apiKey, _activeModelName!, systemContext);
    }
    
    if (response == null) {
      final availableModels = await _listAvailableModels(apiKey);
      if (availableModels.isNotEmpty) {
        for (var modelName in availableModels) {
          response = await _trySpecificModel(apiKey, modelName, systemContext);
          if (response != null) {
            _activeModelName = modelName;
            break;
          }
        }
      }
    }

    if (response != null) {
      if (foundDish != null && (lowerText.contains('nấu') || lowerText.contains('công thức') || lowerText.contains('làm sao'))) {
        _history.add(ChatMessage(
          text: response,
          isUser: false,
          type: ChatMessageType.recipeStep,
          recipeDetail: foundDetail,
          currentStepIndex: 0,
        ));
      } else if (lowerText.contains('gợi ý') || lowerText.contains('ăn gì')) {
        _history.add(ChatMessage(
          text: response,
          isUser: false,
          type: ChatMessageType.recipeList,
          dishes: _availableDishes.take(3).toList(),
        ));
      } else {
        _history.add(ChatMessage(text: response, isUser: false));
      }
    } else {
      _addErrorMessage('Không thể kết nối AI. Vui lòng kiểm tra lại cấu hình API.');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<String>> _listAvailableModels(String apiKey) async {
    final List<String> found = [];
    try {
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List? models = data['models'];
        if (models != null) {
          for (var m in models) {
            String name = m['name'] ?? '';
            if (name.contains('gemini')) found.add(name.replaceFirst('models/', ''));
          }
        }
      }
    } catch (_) {}
    return found;
  }

  Future<String?> _trySpecificModel(String apiKey, String modelName, String prompt) async {
    try {
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey');
      final body = jsonEncode({"contents": [{"parts": [{"text": prompt}]}]});
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]['content']?['parts']?[0]['text'];
      }
    } catch (_) {}
    return null;
  }

  void nextStep(int messageIndex) {
    final msg = _history[messageIndex];
    if (msg.recipeDetail != null && msg.currentStepIndex != null) {
      if (msg.currentStepIndex! < msg.recipeDetail!.steps.length - 1) {
        _history[messageIndex] = ChatMessage(
          text: msg.text,
          isUser: false,
          type: ChatMessageType.recipeStep,
          recipeDetail: msg.recipeDetail,
          currentStepIndex: msg.currentStepIndex! + 1,
        );
        notifyListeners();
      }
    }
  }

  void _addErrorMessage(String message) {
    _history.add(ChatMessage(text: message, isUser: false));
  }

  void resetChat() {
    _history.clear();
    _activeModelName = null;
    _addWelcomeMessage();
    notifyListeners();
  }
}
