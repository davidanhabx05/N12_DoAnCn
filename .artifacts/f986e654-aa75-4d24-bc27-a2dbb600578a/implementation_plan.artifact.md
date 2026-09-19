# Hoàn thiện chức năng Thực đơn và Hồ sơ

Người dùng yêu cầu phân tách rõ ràng các mục "Nháp", "Lịch sử" trong tab Thực đơn thành các trang/view riêng biệt và hoàn thiện các tính năng còn trống trong trang Hồ sơ.

## Proposed Changes

### 1. Thực đơn (Menu/Meal Plan)

#### [MODIFY] [menu_viewmodel.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/viewmodels/menu_viewmodel.dart)
- Cập nhật logic lọc danh sách thực đơn theo trạng thái (Active, Draft, History).
- Bổ sung dữ liệu mẫu cho mỗi trạng thái để người dùng thấy rõ sự khác biệt ngay lập tức.

#### [MODIFY] [menu_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/menu/menu_screen.dart)
- Cập nhật giao diện để hiển thị danh sách đã được lọc tương ứng với mỗi tab.
- Mỗi tab ("Đang áp dụng", "Nháp", "Lịch sử") sẽ hoạt động như một trang con độc lập.

### 2. Hồ sơ (Profile)

#### [NEW] [random_dish_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/profile/random_dish_screen.dart)
- Tạo trang "Ăn Theo Ý Trời" (Xúc xắc): Hiển thị một món ăn ngẫu nhiên từ kho dữ liệu để gợi ý cho người dùng.

#### [NEW] [health_stats_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/profile/health_stats_screen.dart)
- Tạo trang "Chỉ số BMI & Sức khỏe": Hiển thị các thông số sức khỏe mô phỏng.

#### [NEW] [allergy_settings_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/profile/allergy_settings_screen.dart)
- Tạo trang "Dị ứng & Kiêng khem": Cho phép người dùng chọn các loại thực phẩm cần tránh.

#### [MODIFY] [profile_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/profile/profile_screen.dart)
- Kết nối tất cả các mục menu mới tạo vào giao diện chính của trang Hồ sơ.

## Verification Plan

### Manual Verification
- Mở **Thực đơn**: Chuyển đổi giữa 3 tab và kiểm tra xem danh sách các món ăn có thay đổi đúng theo trạng thái không.
- Mở **Hồ sơ**:
    - Nhấn "Ăn Theo Ý Trời" -> Phải hiện trang quay số/gợi ý món.
    - Nhấn "Dị ứng & Kiêng khem" -> Phải hiện trang cài đặt dị ứng.
    - Nhấn "Chỉ số BMI" -> Phải hiện trang biểu đồ/thông số sức khỏe.
