package vn.homnayangi.api.auth;

/** Thông tin người dùng lấy từ token đăng nhập Google (Firebase). */
public record GoogleIdentity(String uid, String email, String name, String picture) {
}
