package vn.homnayangi.api.dish;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

/** Món đã thích (liked_dishes) và món đã lưu (bookmarks) của người dùng. */
@Repository
public class UserDishRepository {

    public enum Kind {
        LIKE("liked_dishes"),
        BOOKMARK("bookmarks");

        private final String table;

        Kind(String table) {
            this.table = table;
        }
    }

    private final JdbcTemplate jdbc;

    public UserDishRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /** Id món, mới nhất trước. */
    public List<Long> findDishIds(Kind kind, long userId) {
        return jdbc.queryForList(
                "SELECT dish_id FROM " + kind.table + " WHERE user_id = ? ORDER BY created_at DESC",
                Long.class, userId);
    }

    public Set<Long> findDishIdSet(Kind kind, long userId) {
        return new HashSet<>(findDishIds(kind, userId));
    }

    /** true nếu vừa thêm mới (chưa có trước đó). */
    public boolean add(Kind kind, long userId, long dishId) {
        return jdbc.update("INSERT INTO " + kind.table + " (user_id, dish_id) VALUES (?, ?) ON CONFLICT DO NOTHING",
                userId, dishId) > 0;
    }

    /** true nếu thực sự có dòng bị xoá. */
    public boolean remove(Kind kind, long userId, long dishId) {
        return jdbc.update("DELETE FROM " + kind.table + " WHERE user_id = ? AND dish_id = ?", userId, dishId) > 0;
    }
}
