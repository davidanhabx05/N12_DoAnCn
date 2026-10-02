/// Nhãn dị ứng ở màn "Dị ứng & Kiêng khem" -> tên chuẩn dùng chung với
/// màn "Tùy chọn ăn uống" (backend cũng dùng đúng các tên chuẩn này).
class AllergyLabels {
  AllergyLabels._();

  static const Map<String, String> _aliases = {
    'Sữa & Sản phẩm từ sữa': 'Sữa',
    'Bột mì (Gluten)': 'Gluten',
  };

  static String canonical(String label) => _aliases[label] ?? label;
}
