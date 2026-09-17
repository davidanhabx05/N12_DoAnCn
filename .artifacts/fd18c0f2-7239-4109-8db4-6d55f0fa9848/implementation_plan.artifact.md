# Kế hoạch Xây dựng Hệ thống Gợi ý Cá nhân hóa (Món ăn & Quán ăn)

Chào bạn, tôi sẽ nâng cấp ứng dụng từ việc hiển thị danh sách chung thành một hệ thống thông minh, tự động gợi ý món ăn và quán ăn dựa trên sở thích và thói quen cá nhân của bạn.

## Các thay đổi chính đề xuất

### 1. Xây dựng Hồ sơ Sở thích (User Preferences)
- **Dữ liệu**: Tạo cấu trúc lưu trữ sở thích bao gồm:
    - **Chế độ ăn**: Chay, Eat Clean, Keto, Bình thường.
    - **Khẩu vị**: Cay, Ngọt, Thanh đạm.
    - **Món ăn yêu thích**: Tự động học từ các món bạn đã nhấn "Thích".
    - **Ngân sách**: Bình dân, Trung lưu, Sang trọng.

### 2. Công cụ Gợi ý Thông minh (Recommendation Engine)
- **Gợi ý Món ăn**: Trong 500+ món hiện có, hệ thống sẽ lọc ra các món khớp với "Chế độ ăn" và "Khẩu vị" của bạn để đưa lên đầu trang chủ.
- **Gợi ý Quán ăn**: Tự động xếp hạng các nhà hàng dựa trên sở thích cá nhân (vd: Nếu bạn thích đồ Chay, các quán Chay sẽ luôn hiện lên đầu).

### 3. Cải thiện Giao diện (UI/UX)
- **Màn hình chính**: Thêm phần "Dành riêng cho bạn" (For You).
- **Màn hình Profile**: Hoàn thiện các mục "Kỹ năng vào bếp", "Tùy chọn ăn uống" để bạn có thể tự tay thiết lập bộ lọc cá nhân.

### 4. Nâng cấp Quản gia AI
- AI sẽ đọc hồ sơ của bạn để đưa ra lời khuyên "chạm" đúng nhu cầu.
- Ví dụ: AI sẽ nói "Tôi thấy bạn đang ăn chế độ Eat Clean, món Salad ức gà trong app rất hợp với bạn đấy!"

## Các tệp sẽ chỉnh sửa/tạo mới

### [Component] Models & ViewModels
#### [NEW] [user_preferences.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/models/user_preferences.dart)
#### [MODIFY] [profile_viewmodel.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/viewmodels/profile_viewmodel.dart)
#### [MODIFY] [home_viewmodel.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/viewmodels/home_viewmodel.dart)
#### [MODIFY] [restaurant_viewmodel.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/viewmodels/restaurant_viewmodel.dart)

### [Component] Features UI
#### [NEW] [preference_settings_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/profile/preference_settings_screen.dart)
#### [MODIFY] [home_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/home/home_screen.dart)
#### [MODIFY] [restaurant_screen.dart](file:///E:/AndroiStudio/N12_DoAnCn/lib/features/restaurant/restaurant_screen.dart)

## Kế hoạch xác minh (Verification Plan)
### Kiểm tra thủ công
1. Vào Profile thiết lập chế độ ăn là "Chay".
2. Quay lại Trang chủ xem các món Chay có xuất hiện nhiều hơn không.
3. Vào tab Quán ăn xem các nhà hàng Chay có được ưu tiên không.
4. Hỏi AI: "Tôi nên ăn gì?" xem nó có gợi ý đúng chế độ ăn đã thiết lập không.

Bạn có đồng ý với kế hoạch nâng cấp "Sở thích cá nhân" toàn diện này không?
