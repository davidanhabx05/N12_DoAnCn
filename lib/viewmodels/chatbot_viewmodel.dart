import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
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

  ChatMessage({
    required this.text,
    required this.isUser,
    this.type = ChatMessageType.text,
    this.dishes,
    this.recipeDetail,
  });
}

class ChatbotViewModel extends ChangeNotifier {
  final List<ChatMessage> _history = [];
  bool _isLoading = false;
  String? _activeModelName;
  
  // Ngữ context ứng dụng
  List<Dish> _availableDishes = [];
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
        text: 'Xin chào! Tôi là Trợ lý AI Ẩm thực. Tôi có thể lắng nghe chia sẻ, phân tích tâm trạng & ngân sách của bạn để gợi ý các món ăn ngon và chỉ đường đến quán ăn lân cận ở Hà Nội. Bạn muốn tìm món gì hôm nay?',
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
    
    String dishContext = "";
    Dish? foundDish;
    RecipeDetail? foundDetail;
    
    final lowerText = text.toLowerCase();
    
    // Tìm kiếm món cụ thể
    for (var dish in _availableDishes) {
      if (lowerText.contains(dish.title.toLowerCase())) {
        foundDish = dish;
        foundDetail = RecipeService.getRecipeDetail(dish);
        dishContext += "\nTHÔNG TIN MÓN '${dish.title}':\n"
            "- Giá trung bình tại quán: ${foundDetail.priceVnd} VNĐ\n"
            "- Giá trị dinh dưỡng: ${dish.calories} kcal\n"
            "- Danh mục: ${dish.category}\n";
        break; 
      }
    }

    // 2. TÌM KIẾM DỮ LIỆU TÍNH NĂNG
    String featureContext = "";
    if (lowerText.contains('lọc') || lowerText.contains('tìm kiếm')) {
      featureContext = "\nỨng dụng có các bộ lọc thông minh: Vùng miền, Thời tiết, Tâm trạng, Ngân sách.";
    }

    // 3. TÌM KIẾM DỮ LIỆU NHÀ HÀNG
    String restaurantContext = "";
    if (lowerText.contains('quán') || lowerText.contains('nhà hàng') || lowerText.contains('ở đâu')) {
      restaurantContext = "\nDanh sách nhà hàng đề xuất tại Hà Nội: ${_restaurantNames.take(5).join(", ")}.";
    }

    // 4. THÔNG TIN SỞ THÍCH CÁ NHÂN
    String prefContext = "";
    if (_userPrefs != null) {
      prefContext = "\nSỞ THÍCH NGƯỜI DÙNG: Chế độ ăn ${_userPrefs!.dietType}, Khẩu vị ${_userPrefs!.favoriteFlavors.join(", ")}, Ngân sách ${_userPrefs!.budgetLevel}.\n";
    }

    final systemContext = 
        "Hệ thống: Bạn là 'Trợ lý AI Ẩm thực' của ứng dụng 'Hôm Nay Ăn Gì'. \n"
        "Nhiệm vụ: Tư vấn món ăn ngoài và gợi ý quán ăn cho người dùng dựa trên tâm trạng & ngân sách. \n"
        "QUY TẮC BẮT BUỘC: CHỈ gợi ý món ăn ngoài và chỉ đường đến quán ăn. KHÔNG hướng dẫn nấu ăn hay cung cấp công thức chế biến. \n"
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
      if (foundDish != null) {
        _history.add(ChatMessage(
          text: response,
          isUser: false,
          type: ChatMessageType.restaurantSuggestion,
          recipeDetail: foundDetail,
        ));
      } else if (lowerText.contains('gợi ý') || lowerText.contains('ăn gì') || lowerText.contains('đói')) {
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
