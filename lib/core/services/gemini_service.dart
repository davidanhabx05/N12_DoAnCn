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
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'Bạn là Quản gia AI ẩm thực chuyên tư vấn món ăn và gợi ý quán ăn lân cận cho người dùng. '
          'Hãy giúp người dùng chọn món ăn phù hợp dựa trên tâm trạng, ngân sách và sở thích của họ. '
          'QUY TẮC BẮT BUỘC: Bạn CHỈ gợi ý món ăn ngoài và chỉ đường đến quán ăn. '
          'KHÔNG hướng dẫn nấu ăn, KHÔNG cung cấp công thức hay nguyên liệu nấu nướng. '
          'Luôn trả lời bằng tiếng Việt, thân thiện, đồng cảm và ngắn gọn.'
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
    await Future.delayed(const Duration(milliseconds: 600));
    final q = prompt.toLowerCase();
    
    if (q.contains('chào') || q.contains('hi')) {
      return 'Xin chào! Tôi là Trợ lý AI Ẩm thực. Hôm nay bạn thấy thế nào? Muốn ăn món gì nóng hổi hay tìm quán ăn ngon gần đây?';
    } else if (q.contains('phở')) {
      return 'Phở là lựa chọn tuyệt vời! Bạn có thể thử Phở Bò Thìn Lò Đúc hoặc Phở Bát Đàn tại Hà Nội. Rất nóng hổi và đậm đà!';
    } else if (q.contains('cơm')) {
      return 'Bữa ăn chắc bụng với Cơm Niêu Tố Uyên hoặc Cơm Tấm ngon tuyệt. Tôi có thể chỉ đường tới quán gần nhất cho bạn!';
    } else if (q.contains('bún')) {
      return 'Bún Chả Hương Liên (Obama) hay Bún Thang Cầu Gỗ là những gợi ý đỉnh cao cho bữa trưa hôm nay.';
    } else if (q.contains('healthy') || q.contains('chay') || q.contains('giảm cân')) {
      return 'Lựa chọn tuyệt vời! Bạn nên thử món Chay Aummee Châu Long hoặc Salad Station Tô Ngọc Vân. Vừa ngon miệng lại tốt cho vóc dáng!';
    } else if (q.contains('cảm ơn')) {
      return 'Rất vui được hỗ trợ bạn! Chúc bạn có một bữa ăn ngon miệng nhé.';
    }
    
    return 'Gợi ý tuyệt vời cho bạn hôm nay là món Phở Bò Thìn Lò Đúc hoặc Bún Chả Hương Liên. Bạn có muốn xem danh sách các quán gần đây không?';
  }

  void resetChat() {
    _model = null;
    _chatSession = null;
    _initModel();
  }
}
