package vn.homnayangi.api.restaurant;

import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class RestaurantRepository {

    private final JdbcTemplate jdbc;

    public RestaurantRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<Restaurant> findAll() {
        return jdbc.query("SELECT * FROM restaurants ORDER BY id", (rs, i) -> new Restaurant(
                rs.getLong("id"),
                rs.getString("name"),
                rs.getString("address"),
                rs.getDouble("rating"),
                rs.getString("image_url"),
                rs.getString("category"),
                rs.getDouble("latitude"),
                rs.getDouble("longitude"),
                rs.getInt("open_minute"),
                rs.getInt("close_minute")));
    }

    public List<String> findNames(int limit) {
        return jdbc.queryForList("SELECT name FROM restaurants ORDER BY rating DESC, id LIMIT ?", String.class, limit);
    }
}
