package vn.homnayangi.api.auth;

import java.security.SecureRandom;
import java.util.HexFormat;
import java.util.List;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

/** Bảng auth_sessions: mỗi lần đăng nhập sinh một token ngẫu nhiên. */
@Repository
public class SessionRepository {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final JdbcTemplate jdbc;

    public SessionRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public String create(long userId) {
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String token = HexFormat.of().formatHex(bytes);
        jdbc.update("INSERT INTO auth_sessions (token, user_id) VALUES (?, ?)", token, userId);
        return token;
    }

    /** Trả về user_id của token và cập nhật thời điểm sử dụng gần nhất. */
    public Optional<Long> findUserId(String token) {
        List<Long> ids = jdbc.queryForList(
                "UPDATE auth_sessions SET last_used_at = NOW() WHERE token = ? RETURNING user_id",
                Long.class, token);
        return ids.isEmpty() ? Optional.empty() : Optional.ofNullable(ids.get(0));
    }

    public void delete(String token) {
        jdbc.update("DELETE FROM auth_sessions WHERE token = ?", token);
    }
}
