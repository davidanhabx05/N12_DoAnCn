import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../core/services/recipe_service.dart';
import '../models/dish.dart';
import '../models/user_preferences.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
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

  void updateAvailableDishes(List<Dish> dishes) {
    _availableDishes = dishes;
  }

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
    final lowerText = text.toLowerCase();
    for (var dish in _availableDishes) {
      if (lowerText.contains(dish.title.toLowerCase())) {
        final detail = RecipeService.getRecipeDetail(dish);
        dishContext += "\nTHÔNG TIN CHI TIẾT MÓN '${dish.title}':\n"
            "- Giá bán: ${detail.priceVnd} VNĐ\n"
            "- Giá trị dinh dưỡng: ${dish.calories} kcal, ${detail.nutritionInfo}\n"
            "- Thời gian chuẩn bị: ${dish.prepTimeMinutes} phút\n"
            "- Độ khó: ${dish.difficulty}\n"
            "- NGUYÊN LIỆU: ${detail.ingredients.map((i) => "${i.name} (${i.amount})").join(", ")}\n"
            "- CÔNG THỨC CÁC BƯỚC NẤU: ${detail.steps.asMap().entries.map((e) => "Bước ${e.key + 1}: ${e.value}").join(". ")}\n";
        break; 
      }
    }

    // 2. TÌM KIẾM DỮ LIỆU TÍNH NĂNG (FILTERS)
    String featureContext = "";
    if (lowerText.contains('lọc') || lowerText.contains('tìm kiếm')) {
      featureContext = "\nỨng dụng có các bộ lọc thông minh sau:\n"
          "- Vùng miền: ${_regions.join(", ")}\n"
          "- Thời tiết: ${_weathers.join(", ")}\n"
          "- Tâm trạng: ${_moods.join(", ")}\n"
          "Hướng dẫn: Bạn có thể nhấn vào biểu tượng 'Bộ lọc' ở góc trái màn hình Trang chủ hoặc Tìm kiếm.";
    }

    // 3. TÌM KIẾM DỮ LIỆU NHÀ HÀNG
    String restaurantContext = "";
    if (lowerText.contains('quán') || lowerText.contains('nhà hàng') || lowerText.contains('địa điểm')) {
      restaurantContext = "\nDanh sách nhà hàng đề xuất trong app:\n${_restaurantNames.take(5).join(", ")}...\n"
          "Hướng dẫn: Bạn có thể vào tab 'Gợi ý quán' để xem bản đồ chi tiết và chỉ đường qua Google Maps.";
    }

    // 4. THÔNG TIN SỞ THÍCH CÁ NHÂN
    String prefContext = "";
    if (_userPrefs != null) {
      prefContext = "\nSỞ THÍCH CỦA NGƯỜI DÙNG HIỆN TẠI:\n"
          "- Chế độ ăn: ${_userPrefs!.dietType}\n"
          "- Khẩu vị: ${_userPrefs!.favoriteFlavors.join(", ")}\n"
          "- Ngân sách: ${_userPrefs!.budgetLevel}\n";
    }

    // 5. TỔNG HỢP DANH SÁCH MÓN
    String listContext = "";
    if (dishContext.isEmpty) {
      final dishSummary = _availableDishes.take(15).map((d) => d.title).join(", ");
      listContext = "\nDanh sách thực đơn hiện có trong app: $dishSummary.";
    }
    
    final systemContext = 
        "Hệ thống: Bạn là 'Quản gia AI' của ứng dụng 'Hôm Nay Ăn Gì'. \n"
        "Thời gian hiện tại: $currentTime. \n"
        "QUY TẮC TRẢ LỜI:\n"
        "1. ƯU TIÊN TUYỆT ĐỐI dữ liệu từ ứng dụng và SỞ THÍCH NGƯỜI DÙNG dưới đây.\n"
        "2. Nếu người dùng hỏi về món, hãy gợi ý món khớp với chế độ ăn '${_userPrefs?.dietType ?? 'Bình thường'}' của họ.\n"
        "3. Luôn tỏ ra am hiểu và quan tâm đến sức khỏe người dùng dựa trên hồ sơ của họ.\n\n"
        "DỮ LIỆU ỨNG DỤNG CUNG CẤP:\n"
        "$dishContext $featureContext $restaurantContext $prefContext $listContext \n\n"
        "Người dùng: $text";

    // BƯỚC 1: DÙNG MÔ HÌNH HOẠT ĐỘNG TRƯỚC ĐÓ
    if (_activeModelName != null) {
      final response = await _trySpecificModel(apiKey, _activeModelName!, systemContext);
      if (response != null) {
        _history.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
        notifyListeners();
        return;
      }
      _activeModelName = null;
    }

    // BƯỚC 2: QUY TRÌNH CHẨN ĐOÁN & KẾT NỐI
    final availableModels = await _listAvailableModels(apiKey);
    if (availableModels.isNotEmpty) {
      availableModels.sort((a, b) => a.contains('1.5-flash') ? -1 : 1);
      for (var modelName in availableModels) {
        final response = await _trySpecificModel(apiKey, modelName, systemContext);
        if (response != null) {
          _activeModelName = modelName;
          _history.add(ChatMessage(text: response, isUser: false));
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
    }

    _addErrorMessage('Không thể kết nối AI. Vui lòng kiểm tra lại cấu hình API.');
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
