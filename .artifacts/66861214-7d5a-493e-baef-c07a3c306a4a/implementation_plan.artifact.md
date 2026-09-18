# Kế hoạch Nâng cấp: Đa ngôn ngữ, Chỉnh sửa Hồ sơ & Hoàn thiện Thực đơn

Tôi sẽ thực hiện một bản nâng cấp toàn diện để ứng dụng đạt tiêu chuẩn chuyên nghiệp, hỗ trợ đa quốc gia và cho phép người dùng cá nhân hóa sâu sắc hơn.

## User Review Required

> [!IMPORTANT]
> **Hệ thống Ngôn ngữ**: Tôi sẽ sử dụng `LanguageViewModel` để quản lý việc dịch thuật. Các văn bản chính trong app (Trang chủ, Tìm kiếm, Thực đơn, Hồ sơ) sẽ được chuyển sang dạng biến động để có thể đổi giữa Tiếng Việt và Tiếng Anh tức thì.
>
> **Chỉnh sửa Hồ sơ**: Tính năng này sẽ bao gồm việc thay đổi ảnh đại diện (sử dụng máy ảnh/thư viện), đổi tên và tiểu sử. Dữ liệu sẽ được đồng bộ ngay lập tức.
>
> **Logic Thực đơn**: Sửa lỗi nút "+" để khi bạn đang ở tab nào, thực đơn mới sẽ được mặc định tạo ở tab đó (Active/Draft/History).

## Proposed Changes

### [Component] Đa ngôn ngữ (Localization)

#### [NEW] [language_viewmodel.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/viewmodels/language_viewmodel.dart)
- Quản lý `currentLocale`.
- Chứa bản đồ dịch thuật cho các màn hình chính.
- Cung cấp hàm `t(String key)` để lấy nội dung dịch.

#### [MODIFY] [main.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/main.dart)
- Đăng ký `LanguageViewModel` vào danh sách Provider.

### [Component] Chỉnh sửa Hồ sơ (Edit Profile)

#### [MODIFY] [profile_viewmodel.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/viewmodels/profile_viewmodel.dart)
- Thêm các thuộc tính: `displayName`, `bio`, `avatarUrl`.
- Thêm hàm `updateProfile(String name, String bio, String avatar)`.

#### [NEW] [edit_profile_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/profile/edit_profile_screen.dart)
- Giao diện nhập liệu chuyên nghiệp.
- Cho phép chọn ảnh mới.

#### [MODIFY] [profile_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/profile/profile_screen.dart)
- Cập nhật hiển thị tên và bio động từ ViewModel.
- Kết nối icon bút chì để mở màn hình chỉnh sửa.

### [Component] Hoàn thiện Thực đơn (Menu Logic)

#### [MODIFY] [menu_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/menu/menu_screen.dart)
- Sử dụng `TabController` để biết người dùng đang ở tab nào khi nhấn nút thêm.

#### [MODIFY] [menu_viewmodel.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/viewmodels/menu_viewmodel.dart)
- Cập nhật hàm `addMenuPlan` để nhận tham số `status`.

## Verification Plan

### Manual Verification
1. **Kiểm tra Thực đơn**: Mở tab "Lịch sử" -> Nhấn "+" -> Lưu. Kiểm tra xem thực đơn mới có nằm ở tab "Lịch sử" không.
2. **Kiểm tra Ngôn ngữ**: Vào Cài đặt -> Chọn "English" -> Quay lại Trang chủ kiểm tra xem các tiêu đề đã chuyển sang tiếng Anh chưa.
3. **Kiểm tra Chỉnh sửa Hồ sơ**: Thay đổi tên thành "Pro Foodie" -> Lưu -> Kiểm tra hiển thị tại màn hình chính Hồ sơ.
