package vn.homnayangi.api.chat;

import java.sql.Array;
import java.sql.SQLException;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

/** Bảng chat_sessions và chat_messages. */
@Repository
public class ChatRepository {

    public record SessionRow(long id, long userId, String title, OffsetDateTime createdAt, OffsetDateTime updatedAt) {
    }

    public record MessageRow(long id, long sessionId, boolean user, String content, String type, List<Long> dishIds,
                             Long recipeDishId, boolean hadImage, OffsetDateTime createdAt) {
    }

    private final JdbcTemplate jdbc;

    public ChatRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public Optional<SessionRow> findSession(long userId, long sessionId) {
        List<SessionRow> rows = jdbc.query("SELECT * FROM chat_sessions WHERE id = ? AND user_id = ?",
                (rs, i) -> new SessionRow(rs.getLong("id"), rs.getLong("user_id"), rs.getString("title"),
                        rs.getObject("created_at", OffsetDateTime.class),
                        rs.getObject("updated_at", OffsetDateTime.class)),
                sessionId, userId);
        return rows.isEmpty() ? Optional.empty() : Optional.of(rows.get(0));
    }

    public List<SessionRow> findSessions(long userId, int limit) {
        return jdbc.query("SELECT * FROM chat_sessions WHERE user_id = ? ORDER BY updated_at DESC LIMIT ?",
                (rs, i) -> new SessionRow(rs.getLong("id"), rs.getLong("user_id"), rs.getString("title"),
                        rs.getObject("created_at", OffsetDateTime.class),
                        rs.getObject("updated_at", OffsetDateTime.class)),
                userId, limit);
    }

    public long createSession(long userId, String title) {
        Long id = jdbc.queryForObject("INSERT INTO chat_sessions (user_id, title) VALUES (?, ?) RETURNING id",
                Long.class, userId, title);
        if (id == null) {
            throw new IllegalStateException("Không tạo được cuộc trò chuyện");
        }
        return id;
    }

    public void touchSession(long sessionId) {
        jdbc.update("UPDATE chat_sessions SET updated_at = NOW() WHERE id = ?", sessionId);
    }

    public boolean deleteSession(long userId, long sessionId) {
        return jdbc.update("DELETE FROM chat_sessions WHERE id = ? AND user_id = ?", sessionId, userId) > 0;
    }

    /** Giữ lại tối đa [keep] cuộc trò chuyện gần nhất. */
    public void pruneSessions(long userId, int keep) {
        jdbc.update("""
                DELETE FROM chat_sessions WHERE user_id = ? AND id NOT IN (
                    SELECT id FROM chat_sessions WHERE user_id = ? ORDER BY updated_at DESC LIMIT ?)
                """, userId, userId, keep);
    }

    public MessageRow insertMessage(long sessionId, boolean user, String content, String type, List<Long> dishIds,
                                    Long recipeDishId, boolean hadImage) {
        return jdbc.queryForObject("""
                        INSERT INTO chat_messages (session_id, is_user, content, message_type, dish_ids, recipe_dish_id, had_image)
                        VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING *
                        """,
                (rs, i) -> mapMessage(rs),
                sessionId, user, content, type, dishIds.toArray(new Long[0]), recipeDishId, hadImage);
    }

    public List<MessageRow> findMessages(long sessionId) {
        return jdbc.query("SELECT * FROM chat_messages WHERE session_id = ? ORDER BY id", (rs, i) -> mapMessage(rs),
                sessionId);
    }

    /** [limit] tin nhắn gần nhất (theo thứ tự thời gian) – làm ngữ cảnh cho Gemini. */
    public List<MessageRow> findRecentMessages(long sessionId, int limit) {
        List<MessageRow> rows = new ArrayList<>(jdbc.query(
                "SELECT * FROM chat_messages WHERE session_id = ? ORDER BY id DESC LIMIT ?",
                (rs, i) -> mapMessage(rs), sessionId, limit));
        java.util.Collections.reverse(rows);
        return rows;
    }

    private static MessageRow mapMessage(java.sql.ResultSet rs) throws SQLException {
        long recipe = rs.getLong("recipe_dish_id");
        Long recipeId = rs.wasNull() ? null : recipe;
        return new MessageRow(rs.getLong("id"), rs.getLong("session_id"), rs.getBoolean("is_user"),
                rs.getString("content"), rs.getString("message_type"), toLongList(rs.getArray("dish_ids")),
                recipeId, rs.getBoolean("had_image"), rs.getObject("created_at", OffsetDateTime.class));
    }

    private static List<Long> toLongList(Array array) throws SQLException {
        List<Long> out = new ArrayList<>();
        if (array == null) {
            return out;
        }
        Object raw = array.getArray();
        if (raw instanceof Object[] values) {
            for (Object v : values) {
                if (v instanceof Number n) {
                    out.add(n.longValue());
                }
            }
        }
        return out;
    }
}
