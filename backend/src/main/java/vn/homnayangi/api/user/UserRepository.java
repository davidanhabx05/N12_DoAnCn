package vn.homnayangi.api.user;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

@Repository
public class UserRepository {

    private static final String COLUMNS =
            "id, firebase_uid, email, display_name, bio, avatar_url, is_guest, is_demo";

    private static final RowMapper<UserRecord> MAPPER = (ResultSet rs, int i) -> new UserRecord(
            rs.getLong("id"),
            rs.getString("firebase_uid"),
            rs.getString("email"),
            rs.getString("display_name"),
            rs.getString("bio"),
            rs.getString("avatar_url"),
            rs.getBoolean("is_guest"),
            rs.getBoolean("is_demo"));

    private final JdbcTemplate jdbc;

    public UserRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public Optional<UserRecord> findById(long id) {
        return first(jdbc.query("SELECT " + COLUMNS + " FROM users WHERE id = ?", MAPPER, id));
    }

    public Optional<UserRecord> findByFirebaseUid(String uid) {
        return first(jdbc.query("SELECT " + COLUMNS + " FROM users WHERE firebase_uid = ?", MAPPER, uid));
    }

    public Optional<UserRecord> findDemo() {
        return first(jdbc.query("SELECT " + COLUMNS + " FROM users WHERE is_demo ORDER BY id LIMIT 1", MAPPER));
    }

    /** Tạo người dùng mới và hồ sơ ăn uống mặc định; trả về id. */
    public long insert(String firebaseUid, String email, String displayName, String bio, String avatarUrl,
                       boolean guest, boolean demo) {
        Long id = jdbc.queryForObject(
                "INSERT INTO users (firebase_uid, email, display_name, bio, avatar_url, is_guest, is_demo) "
                        + "VALUES (?, ?, COALESCE(?, 'Người dùng Foodie'), "
                        + "COALESCE(?, 'Yêu thích nấu ăn và khám phá ẩm thực Việt Nam.'), ?, ?, ?) RETURNING id",
                Long.class, firebaseUid, email, displayName, bio, avatarUrl, guest, demo);
        if (id == null) {
            throw new IllegalStateException("Không tạo được người dùng");
        }
        jdbc.update("INSERT INTO user_preferences (user_id) VALUES (?) ON CONFLICT DO NOTHING", id);
        return id;
    }

    public void updateProfile(long id, String displayName, String bio, String avatarUrl) {
        jdbc.update("UPDATE users SET display_name = COALESCE(?, display_name), bio = COALESCE(?, bio), "
                        + "avatar_url = COALESCE(?, avatar_url), updated_at = NOW() WHERE id = ?",
                displayName, bio, avatarUrl, id);
    }

    public void updateEmail(long id, String email) {
        jdbc.update("UPDATE users SET email = COALESCE(?, email), updated_at = NOW() WHERE id = ?", email, id);
    }

    public void delete(long id) {
        jdbc.update("DELETE FROM users WHERE id = ?", id);
    }

    private static <T> Optional<T> first(List<T> list) {
        return list.isEmpty() ? Optional.empty() : Optional.of(list.get(0));
    }

    static String[] toArray(List<String> list) {
        return list == null ? new String[0] : list.toArray(new String[0]);
    }

    static List<String> fromArray(java.sql.Array array) throws SQLException {
        if (array == null) {
            return List.of();
        }
        Object raw = array.getArray();
        if (raw instanceof String[] values) {
            return List.of(values);
        }
        return List.of();
    }
}
