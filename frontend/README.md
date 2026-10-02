# Hôm Nay Ăn Gì – Frontend (Flutter)

App gợi ý món ăn theo tâm trạng, thời tiết, ngân sách và tìm quán ăn gần bạn ở Hà Nội.
Toàn bộ dữ liệu và logic nằm ở backend Spring Boot (`../backend`), app chỉ hiển thị và gọi API.

- Địa chỉ backend: file `.env` (`API_BASE_URL`) – xem hướng dẫn trong `../README.md`.
- Lớp gọi API: `lib/core/network/api_client.dart`, cấu hình địa chỉ: `lib/core/network/api_config.dart`.
- Chạy: `flutter pub get` rồi `flutter run`. Kiểm thử: `flutter test`.
