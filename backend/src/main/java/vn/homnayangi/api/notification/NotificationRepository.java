package vn.homnayangi.api.notification;

import java.time.OffsetDateTime;
import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class NotificationRepository {

    private final JdbcTemplate jdbc;

    public NotificationRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /** Thông báo chung (user_id NULL) + thông báo riêng, trừ những cái người dùng đã xoá. */
    public List<NotificationDto> findVisible(long userId) {
        return jdbc.query("""
                        SELECT n.*, COALESCE(s.is_read, FALSE) AS read_flag
                        FROM notifications n
                        LEFT JOIN notification_states s ON s.notification_id = n.id AND s.user_id = ?
                        WHERE (n.user_id IS NULL OR n.user_id = ?) AND COALESCE(s.is_deleted, FALSE) = FALSE
                        ORDER BY n.created_at DESC
                        """,
                (rs, i) -> new NotificationDto(
                        String.valueOf(rs.getLong("id")),
                        rs.getString("title"),
                        rs.getString("message"),
                        rs.getObject("created_at", OffsetDateTime.class),
                        rs.getBoolean("read_flag"),
                        rs.getString("type"),
                        rs.getString("icon"),
                        rs.getString("image_url")),
                userId, userId);
    }

    public void markRead(long userId, long notificationId) {
        jdbc.update("""
                INSERT INTO notification_states (user_id, notification_id, is_read)
                SELECT ?, id, TRUE FROM notifications WHERE id = ? AND (user_id IS NULL OR user_id = ?)
                ON CONFLICT (user_id, notification_id) DO UPDATE SET is_read = TRUE
                """, userId, notificationId, userId);
    }

    public void markAllRead(long userId) {
        jdbc.update("""
                INSERT INTO notification_states (user_id, notification_id, is_read)
                SELECT ?, id, TRUE FROM notifications WHERE user_id IS NULL OR user_id = ?
                ON CONFLICT (user_id, notification_id) DO UPDATE SET is_read = TRUE
                """, userId, userId);
    }

    public void hide(long userId, long notificationId) {
        jdbc.update("""
                INSERT INTO notification_states (user_id, notification_id, is_read, is_deleted)
                SELECT ?, id, TRUE, TRUE FROM notifications WHERE id = ? AND (user_id IS NULL OR user_id = ?)
                ON CONFLICT (user_id, notification_id) DO UPDATE SET is_deleted = TRUE, is_read = TRUE
                """, userId, notificationId, userId);
    }
}
