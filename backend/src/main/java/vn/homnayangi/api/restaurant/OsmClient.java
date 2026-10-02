package vn.homnayangi.api.restaurant;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Quán ăn thật quanh một vị trí, lấy từ OpenStreetMap qua Overpass API.
 * Miễn phí, KHÔNG cần API key – dùng khi chưa cấu hình Google Places (hoặc Google không trả kết quả).
 * OpenStreetMap không có điểm đánh giá và ảnh quán; dữ liệu © những người đóng góp OpenStreetMap.
 */
@Component
public class OsmClient {

    private static final Logger log = LoggerFactory.getLogger(OsmClient.class);
    private static final String AMENITIES = "restaurant|fast_food|food_court|cafe|pub|bar|biergarten|ice_cream";
    /** Tìm trong 800 m trước (để không sót quán sát bên), rồi mở rộng ra 3 km. */
    private static final int NEAR_RADIUS = 800;
    private static final int FAR_RADIUS = 3000;
    private static final Duration CACHE_TTL = Duration.ofMinutes(10);
    private static final int CACHE_MAX_ENTRIES = 200;

    /** Một địa điểm ăn uống trên OpenStreetMap. Trường nào thiếu trên bản đồ thì là chuỗi rỗng. */
    public record OsmPlace(String id, String name, String address, double lat, double lng, String amenity,
                           String cuisine, String openingHours, boolean vegetarian) {
    }

    private record CacheEntry(long loadedAt, List<OsmPlace> places) {
    }

    private final boolean enabled;
    private final String endpoint;
    private final HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
    private final ObjectMapper mapper = new ObjectMapper();
    private final Map<String, CacheEntry> cache = new ConcurrentHashMap<>();

    public OsmClient(@Value("${app.osm-enabled:true}") boolean enabled,
                     @Value("${app.overpass-url:https://overpass-api.de/api/interpreter}") String endpoint) {
        this.enabled = enabled;
        this.endpoint = endpoint == null ? "" : endpoint.trim();
    }

    public boolean isEnabled() {
        return enabled && !endpoint.isEmpty();
    }

    /**
     * Các quán có tên trong bán kính 3 km. Kết quả được nhớ 10 phút theo ô ~100 m
     * để không gọi Overpass liên tục khi người dùng gõ tìm kiếm.
     * Lỗi mạng / máy chủ bận -> trả về danh sách rỗng.
     */
    public List<OsmPlace> nearby(double lat, double lng) {
        if (!isEnabled()) {
            return List.of();
        }
        String key = String.format(Locale.US, "%.3f,%.3f", lat, lng);
        long now = System.currentTimeMillis();
        CacheEntry cached = cache.get(key);
        if (cached != null && now - cached.loadedAt() < CACHE_TTL.toMillis()) {
            return cached.places();
        }
        try {
            HttpRequest request = HttpRequest.newBuilder(URI.create(endpoint))
                    .timeout(Duration.ofSeconds(20))
                    .header("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8")
                    .header("Accept", "application/json")
                    .header("User-Agent", "HomNayAnGi/1.0 (do an sinh vien; Spring Boot)")
                    .POST(HttpRequest.BodyPublishers.ofString(
                            "data=" + URLEncoder.encode(buildQuery(lat, lng), StandardCharsets.UTF_8)))
                    .build();
            HttpResponse<String> response = http.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
            if (response.statusCode() != 200) {
                log.warn("Overpass (OpenStreetMap) trả về HTTP {}", response.statusCode());
                return List.of();
            }
            List<OsmPlace> places = parse(mapper.readTree(response.body()));
            if (cache.size() >= CACHE_MAX_ENTRIES) {
                cache.clear();
            }
            cache.put(key, new CacheEntry(now, places));
            return places;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return List.of();
        } catch (Exception e) {
            log.warn("Gọi Overpass (OpenStreetMap) thất bại: {}", e.getMessage());
            return List.of();
        }
    }

    /** Câu truy vấn Overpass QL: điểm / đường / quan hệ có amenity ăn uống và có tên, quanh (lat, lng). */
    static String buildQuery(double lat, double lng) {
        String filter = "[\"amenity\"~\"^(" + AMENITIES + ")$\"][\"name\"]";
        String at = String.format(Locale.US, "%.6f,%.6f", lat, lng);
        return "[out:json][timeout:15];"
                + "nwr" + filter + "(around:" + NEAR_RADIUS + "," + at + ");out tags center 200;"
                + "nwr" + filter + "(around:" + FAR_RADIUS + "," + at + ");out tags center 400;";
    }

    /** Đọc JSON của Overpass: {"elements":[{type,id,lat,lon | center:{lat,lon},tags:{...}}]}. */
    static List<OsmPlace> parse(JsonNode root) {
        Map<String, OsmPlace> byId = new LinkedHashMap<>();
        if (root == null) {
            return List.of();
        }
        for (JsonNode e : root.path("elements")) {
            JsonNode tags = e.path("tags");
            String name = firstTag(tags, "name:vi", "name");
            JsonNode position = e.hasNonNull("lat") ? e : e.path("center");
            if (name.isEmpty() || !position.hasNonNull("lat") || !position.hasNonNull("lon")) {
                continue;
            }
            String id = "osm_" + e.path("type").asText("node") + "_" + e.path("id").asText();
            String diet = tags.path("diet:vegetarian").asText("") + " " + tags.path("diet:vegan").asText("");
            byId.putIfAbsent(id, new OsmPlace(
                    id,
                    name,
                    address(tags),
                    position.get("lat").asDouble(),
                    position.get("lon").asDouble(),
                    tags.path("amenity").asText(""),
                    tags.path("cuisine").asText(""),
                    tags.path("opening_hours").asText(""),
                    diet.contains("only")));
        }
        return List.copyOf(new ArrayList<>(byId.values()));
    }

    private static String address(JsonNode tags) {
        String full = tags.path("addr:full").asText("").trim();
        if (!full.isEmpty()) {
            return full;
        }
        List<String> parts = new ArrayList<>();
        String street = (tags.path("addr:housenumber").asText("") + " " + tags.path("addr:street").asText("")).trim();
        if (!street.isEmpty()) {
            parts.add(street);
        }
        for (String key : List.of("addr:subdistrict", "addr:suburb", "addr:quarter", "addr:district", "addr:city",
                "addr:province")) {
            String value = tags.path(key).asText("").trim();
            if (!value.isEmpty() && !parts.contains(value)) {
                parts.add(value);
            }
        }
        return String.join(", ", parts);
    }

    private static String firstTag(JsonNode tags, String... keys) {
        for (String key : keys) {
            String value = tags.path(key).asText("").trim();
            if (!value.isEmpty()) {
                return value;
            }
        }
        return "";
    }
}
