package vn.homnayangi.api.system;

import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import vn.homnayangi.api.chat.GeminiClient;
import vn.homnayangi.api.dish.DishCatalog;
import vn.homnayangi.api.restaurant.OsmClient;
import vn.homnayangi.api.restaurant.PlacesClient;

/** Kiểm tra nhanh backend: mở http://localhost:8080/api/health trên trình duyệt. */
@RestController
public class HealthController {

    private final JdbcTemplate jdbc;
    private final DishCatalog catalog;
    private final GeminiClient gemini;
    private final PlacesClient places;
    private final OsmClient osm;

    public HealthController(JdbcTemplate jdbc, DishCatalog catalog, GeminiClient gemini, PlacesClient places,
                            OsmClient osm) {
        this.jdbc = jdbc;
        this.catalog = catalog;
        this.gemini = gemini;
        this.places = places;
        this.osm = osm;
    }

    @GetMapping("/api/health")
    public Map<String, Object> health() {
        Map<String, Object> body = new LinkedHashMap<>();
        boolean dbOk;
        try {
            jdbc.queryForObject("SELECT 1", Integer.class);
            dbOk = true;
        } catch (Exception e) {
            dbOk = false;
        }
        body.put("status", dbOk ? "UP" : "DATABASE_DOWN");
        body.put("database", dbOk);
        body.put("dishes", catalog.size());
        body.put("gemini", gemini.isConfigured());
        body.put("googlePlaces", places.isConfigured());
        body.put("openStreetMap", osm.isEnabled());
        return body;
    }
}
