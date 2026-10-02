/// Tiện ích xử lý chuỗi tiếng Việt: bỏ dấu, tìm kiếm không phân biệt dấu,
/// định dạng tiền và đọc ngân sách từ câu nói tự nhiên.
class TextUtils {
  TextUtils._();

  static const Map<String, String> _groups = {
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };

  static final Map<int, String> _lookup = () {
    final map = <int, String>{};
    _groups.forEach((plain, accented) {
      for (final rune in accented.runes) {
        map[rune] = plain;
      }
    });
    return map;
  }();

  /// Chuyển về chữ thường, bỏ dấu tiếng Việt, gộp khoảng trắng.
  static String normalize(String input) {
    final lower = input.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      // Bỏ các dấu kết hợp (Unicode tổ hợp - một số bàn phím gõ ra dạng này)
      if (rune >= 0x0300 && rune <= 0x036F) continue;
      buffer.write(_lookup[rune] ?? String.fromCharCode(rune));
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// true nếu [haystack] chứa [needle] (không phân biệt hoa thường & dấu).
  static bool containsIgnoreAccents(String haystack, String needle) {
    if (needle.trim().isEmpty) return true;
    return normalize(haystack).contains(normalize(needle));
  }

  /// Kiểm tra một cụm từ (đã bỏ dấu) có xuất hiện như một từ/cụm từ độc lập.
  static bool hasPhrase(String normalizedText, String normalizedPhrase) {
    final pattern = RegExp('(^|[^a-z0-9])${RegExp.escape(normalizedPhrase)}(?=\$|[^a-z0-9])');
    return pattern.hasMatch(normalizedText);
  }

  /// 45000 -> "45.000"
  static String formatVnd(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  /// Đọc số tiền trong câu: "50k", "50 nghìn", "100.000đ", "1 triệu", "tầm 30-50k"...
  /// Trả về số VNĐ (lấy mức cao nhất nếu có khoảng) hoặc null nếu không có.
  static int? parseBudget(String text) {
    final t = normalize(text);
    final hasMoneyContext = t.contains('tien') ||
        t.contains('ngan sach') ||
        t.contains('budget') ||
        t.contains('gia ') ||
        t.contains('tui');
    final matches = RegExp(
      r'(\d+(?:[.,]\d+)*)\s*(k|nghin|ngan|trieu|tr|dong|vnd|d)?(?![a-z])',
    ).allMatches(t);

    int? best;
    int? bareCandidate;
    for (final m in matches) {
      final raw = m.group(1)!;
      final unit = m.group(2);
      int? value;
      if (unit == 'trieu' || unit == 'tr') {
        final v = double.tryParse(raw.replaceAll(',', '.'));
        if (v != null) value = (v * 1000000).round();
      } else if (unit == 'k' || unit == 'nghin' || unit == 'ngan') {
        final v = double.tryParse(raw.replaceAll(',', '.'));
        if (v != null) value = (v * 1000).round();
      } else if (unit != null) {
        final v = int.tryParse(raw.replaceAll('.', '').replaceAll(',', ''));
        if (v != null) value = v < 1000 ? v * 1000 : v;
      } else {
        final v = int.tryParse(raw.replaceAll('.', '').replaceAll(',', ''));
        if (v != null) {
          if (v >= 1000) {
            bareCandidate ??= v;
          } else if (v >= 10) {
            bareCandidate ??= v * 1000;
          }
        }
        continue;
      }
      if (value != null && (best == null || value > best)) best = value;
    }
    if (best != null) return best;
    if (hasMoneyContext) return bareCandidate;
    return null;
  }
}
