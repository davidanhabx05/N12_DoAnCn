package vn.homnayangi.api.auth;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import vn.homnayangi.api.user.ProfileService;
import vn.homnayangi.api.user.UserRecord;
import vn.homnayangi.api.user.UserRepository;

@Service
public class AuthService {

    private final FirebaseTokenVerifier verifier;
    private final UserRepository users;
    private final SessionRepository sessions;
    private final ProfileService profiles;

    public AuthService(FirebaseTokenVerifier verifier, UserRepository users, SessionRepository sessions,
                       ProfileService profiles) {
        this.verifier = verifier;
        this.users = users;
        this.sessions = sessions;
        this.profiles = profiles;
    }

    /** Đăng nhập Google: lần đầu tạo tài khoản từ thông tin Google, các lần sau giữ hồ sơ đã chỉnh. */
    @Transactional
    public AuthResponse loginWithGoogle(String idToken) {
        GoogleIdentity identity = verifier.verify(idToken);
        long userId = users.findByFirebaseUid(identity.uid())
                .map(existing -> {
                    users.updateEmail(existing.id(), identity.email());
                    return existing.id();
                })
                .orElseGet(() -> users.insert(identity.uid(), identity.email(), identity.name(), null,
                        identity.picture(), false, false));
        return issue(userId);
    }

    /** Dùng thử không cần tài khoản: mỗi lần tạo một người dùng khách riêng. */
    @Transactional
    public AuthResponse loginAsGuest() {
        long userId = users.insert(null, null, null, null, null, true, false);
        return issue(userId);
    }

    /** Tài khoản demo có sẵn dữ liệu (dùng khi máy chưa cấu hình Firebase). */
    @Transactional
    public AuthResponse loginDemo() {
        long userId = users.findDemo()
                .map(UserRecord::id)
                .orElseGet(() -> users.insert(null, "demo@homnayangi.vn", "Nguyễn Tuấn",
                        "Người đam mê công nghệ và ẩm thực đường phố.",
                        "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=800&auto=format&fit=crop",
                        false, true));
        return issue(userId);
    }

    public void logout(String token) {
        sessions.delete(token);
    }

    private AuthResponse issue(long userId) {
        String token = sessions.create(userId);
        return new AuthResponse(token, profiles.getProfile(userId));
    }
}
