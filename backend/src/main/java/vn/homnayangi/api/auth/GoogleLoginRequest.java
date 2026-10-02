package vn.homnayangi.api.auth;

/** idToken: Firebase ID token lấy bằng user.getIdToken() sau khi đăng nhập Google. */
public record GoogleLoginRequest(String idToken) {
}
