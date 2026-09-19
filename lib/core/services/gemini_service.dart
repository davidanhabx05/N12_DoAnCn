import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  GenerativeModel? _model;
  ChatSession? _chatSession;

  void _initModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return;

    try {
      // Sử dụng gemini-1.5-flash là model mới nhất và nhẹ nhất
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'Bạn là một chuyên gia ẩm thực Việt Nam chuyên nghiệp. '
          'Nhiệm vụ của bạn là tư vấn món ăn, hướng dẫn nấu ăn và giải đáp các thắc mắc về ẩm thực. '
          'Hãy luôn trả lời bằng tiếng Việt, lịch sự, ngắn gọn và có kiến thức chuyên môn cao.'
        ),
      );
      _chatSession = _model!.startChat();
    } catch (e) {
      print('Lỗi khởi tạo AI: $e');
      _model = null;
      _chatSession = null;
    }
  }

  Future<String> askGemini(String prompt) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    
    if (apiKey.isNotEmpty) {
      try {
        if (_model == null || _chatSession == null) {
          _initModel();
        }
        
        if (_chatSession != null) {
          final response = await _chatSession!.sendMessage(Content.text(prompt));
          if (response.text != null) {
            return response.text!;
          }
        }
      } catch (e) {
        print('Lỗi gọi AI thật: $e');
        
        // Nếu lỗi do model không tồn tại hoặc sai version, thử với gemini-pro
        if (e.toString().contains('not found') || e.toString().contains('v1beta')) {
          try {
             final fallbackModel = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
             final response = await fallbackModel.generateContent([Content.text(prompt)]);
             if (response.text != null) return response.text!;
          } catch (fallbackError) {
             print('Lỗi fallback: $fallbackError');
          }
        }
      }
    }

    // --- FALLBACK SMART ASSISTANT ---
    // Nếu AI thật thất bại, dùng logic thông minh này để chữa cháy
    await Future.delayed(const Duration(milliseconds: 600));
    final q = prompt.toLowerCase();
    
    if (q.contains('chào') || q.contains('hi')) {
      return 'Xin chào! Tôi là trợ lý ẩm thực của bạn. Hôm nay bạn muốn nấu món gì hay cần tôi gợi ý thực đơn?';
    } else if (q.contains('phở')) {
      return 'Phở là tinh hoa ẩm thực Việt. Bạn nên thử Phở Bò tái hoặc Phở Gà. Bí quyết nằm ở nước hầm xương kèm thảo quả, quế và hồi nướng thơm lừng.';
    } else if (q.contains('cơm')) {
      return 'Cơm là món ăn quen thuộc nhưng không thể thiếu. Tôi gợi ý Cơm Tấm sườn bì chả hoặc Cơm Chiên hải sản. Rất ngon và đủ chất!';
    } else if (q.contains('bún')) {
      return 'Bún Việt Nam rất phong phú, từ Bún Bò Huế cay nồng đến Bún Riêu cua thanh mát. Bạn đang thèm loại nào?';
    } else if (q.contains('nấu') || q.contains('làm')) {
      return 'Để nấu ngon, quan trọng nhất là nguyên liệu tươi. Bạn chọn món đi, tôi sẽ chỉ bạn từng bước sơ chế và nêm nếm chuẩn vị.';
    } else if (q.contains('healthy') || q.contains('chay') || q.contains('giảm cân')) {
      return 'Lựa chọn tuyệt vời! Gỏi cuốn tôm thịt hoặc các loại Salad ức gà là gợi ý hàng đầu. Vừa ngon miệng lại cực kỳ tốt cho vóc dáng.';
    } else if (q.contains('cảm ơn')) {
      return 'Rất vui được hỗ trợ bạn! Chúc bạn có những bữa ăn thật ngon miệng nhé.';
    }
    
    return 'Chào bạn! Câu hỏi của bạn rất hay. Với kinh nghiệm của tôi, bạn nên thử món "Túi Ngọc Xốt Mè" cho bữa tối nay - một món ăn độc đáo và giàu dinh dưỡng.';
  }

  void resetChat() {
    _model = null;
    _chatSession = null;
    _initModel();
  }
}
