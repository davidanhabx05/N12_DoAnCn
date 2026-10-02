package vn.homnayangi.api.dish;

import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class DishRepository {

    private final JdbcTemplate jdbc;

    public DishRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<Dish> findAll() {
        return jdbc.query("SELECT * FROM dishes ORDER BY id", (rs, i) -> new Dish(
                rs.getLong("id"),
                rs.getString("title"),
                rs.getString("description"),
                rs.getString("image_url"),
                rs.getInt("calories"),
                rs.getInt("prep_time_minutes"),
                rs.getString("difficulty"),
                rs.getString("category"),
                rs.getInt("likes_count"),
                rs.getBoolean("is_special_of_week"),
                rs.getString("region"),
                rs.getString("weather"),
                rs.getString("mood"),
                rs.getInt("price")));
    }

    /** Tăng/giảm lượt thích; trả về số lượt thích mới. */
    public int addLikes(long dishId, int delta) {
        List<Integer> rows = jdbc.queryForList(
                "UPDATE dishes SET likes_count = GREATEST(likes_count + ?, 0) WHERE id = ? RETURNING likes_count",
                Integer.class, delta, dishId);
        return rows.isEmpty() ? 0 : rows.get(0);
    }
}
