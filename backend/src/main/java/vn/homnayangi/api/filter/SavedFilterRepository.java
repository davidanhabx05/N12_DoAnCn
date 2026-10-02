package vn.homnayangi.api.filter;

import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

@Repository
public class SavedFilterRepository {

    private static final RowMapper<SavedFilterDto> MAPPER = (rs, i) -> new SavedFilterDto(
            String.valueOf(rs.getLong("id")),
            rs.getString("name"),
            rs.getString("time_option"),
            (double) rs.getInt("max_time"),
            rs.getString("region"),
            rs.getString("weather"),
            rs.getString("mood"));

    private final JdbcTemplate jdbc;

    public SavedFilterRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<SavedFilterDto> findByUser(long userId) {
        return jdbc.query("SELECT * FROM saved_filters WHERE user_id = ? ORDER BY created_at DESC, id DESC",
                MAPPER, userId);
    }

    /** Trùng tên (không phân biệt hoa thường) -> ghi đè bộ lọc cũ. */
    public SavedFilterDto upsert(long userId, SavedFilterDto f) {
        jdbc.update("DELETE FROM saved_filters WHERE user_id = ? AND LOWER(name) = LOWER(?)", userId, f.name());
        return jdbc.queryForObject("""
                        INSERT INTO saved_filters (user_id, name, time_option, max_time, region, weather, mood)
                        VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING *
                        """, MAPPER,
                userId, f.name(), f.time(), (int) Math.round(f.maxTime()), f.region(), f.weather(), f.mood());
    }

    public boolean delete(long userId, long id) {
        return jdbc.update("DELETE FROM saved_filters WHERE user_id = ? AND id = ?", userId, id) > 0;
    }
}
