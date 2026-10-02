# Hôm Nay Ăn Gì

Ứng dụng gợi ý món ăn theo vùng miền, thời tiết, tâm trạng và ngân sách, kèm tìm quán ăn quanh vị trí người dùng.

## Chức năng chính

- Gợi ý món ăn và lọc theo vùng miền, thời tiết, tâm trạng, thời gian chuẩn bị
- Tìm kiếm món không dấu, thích và lưu món
- Tìm quán ăn gần vị trí hiện tại, mở chỉ đường trên Google Maps
- Chatbot tư vấn món ăn (Gemini)
- Hồ sơ ăn uống: chế độ ăn, dị ứng, ngân sách
- Đăng nhập bằng Google hoặc dùng tài khoản khách

## Công nghệ

| Phần | Công nghệ |
|---|---|
| Ứng dụng | Flutter |
| Backend | Spring Boot (Java 17) |
| Cơ sở dữ liệu | PostgreSQL (chạy bằng Docker) |
| Dịch vụ ngoài | Firebase Auth, Gemini API, Google Places / OpenStreetMap |

## Cấu trúc thư mục

```
frontend/   Ứng dụng Flutter
backend/    API Spring Boot
database/   Script SQL tạo bảng và dữ liệu 60 món ăn
```

## Cách chạy

**1. Tạo file cấu hình** (các file chứa key không có trên GitHub)

- Copy `backend/.env.example` thành `backend/.env`, điền `GEMINI_API_KEY`
- Copy `frontend/.env.example` thành `frontend/.env`
- Đặt file `google-services.json` của Firebase vào `frontend/android/app/`

**2. Chạy cơ sở dữ liệu**

```
docker compose up -d
```

**3. Chạy backend**

```
cd backend
./mvnw spring-boot:run
```

Kiểm tra tại http://localhost:8080/api/health

**4. Chạy ứng dụng**

```
cd frontend
flutter pub get
flutter run
```
