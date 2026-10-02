package vn.homnayangi.api.user;

import jakarta.validation.constraints.Size;

public record UpdateProfileRequest(
        @Size(min = 2, max = 100, message = "Tên hiển thị phải từ 2 đến 100 ký tự") String displayName,
        @Size(max = 500, message = "Giới thiệu tối đa 500 ký tự") String bio,
        @Size(max = 3_000_000, message = "Ảnh đại diện quá lớn") String avatarUrl) {
}
