package vn.homnayangi.api.restaurant;

import java.net.URI;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.databind.JsonNode;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.util.UriComponentsBuilder;

/**
 * Gọi Google Places (Text Search khi có từ khoá, Nearby Search khi chỉ có vị trí).
 * Key nằm ở backend nên app (kể cả bản Web) không bị lộ key và không bị chặn CORS.
 */
@Component
public class PlacesClient {

    private static final Logger log = LoggerFactory.getLogger(PlacesClient.class);

    /** rating = 0 nghĩa là Google chưa có điểm đánh giá cho quán này. */
    public record Place(String placeId, String name, String address, double rating, String photoReference,
                        Boolean openNow, Double lat, Double lng, List<String> types) {
    }

    private final String apiKey;
    private final RestClient http;

    public PlacesClient(@Value("${app.places-api-key:}") String apiKey) {
        this.apiKey = apiKey == null ? "" : apiKey.trim();
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout((int) Duration.ofSeconds(5).toMillis());
        factory.setReadTimeout((int) Duration.ofSeconds(10).toMillis());
        this.http = RestClient.builder().requestFactory(factory).build();
    }

    public boolean isConfigured() {
        return !apiKey.isEmpty();
    }

    /** Tìm theo từ khoá ("bún chả", "quán chay"...). Có vị trí thì ưu tiên quán trong bán kính 5 km. */
    public List<Place> textSearch(String query, Double lat, Double lng) {
        if (!isConfigured()) {
            return List.of();
        }
        try {
            UriComponentsBuilder b = UriComponentsBuilder
                    .fromHttpUrl("https://maps.googleapis.com/maps/api/place/textsearch/json")
                    .queryParam("query", lat != null ? query : query + " Hà Nội")
                    .queryParam("language", "vi")
                    .queryParam("region", "vn")
                    .queryParam("key", apiKey);
            if (lat != null && lng != null) {
                b.queryParam("location", lat + "," + lng).queryParam("radius", 5000);
            }
            return fetch(b.encode().build().toUri());
        } catch (Exception e) {
            log.warn("Gọi Google Places (text search) thất bại: {}", e.getMessage());
            return List.of();
        }
    }

    /**
     * Quán ăn quanh một vị trí (không cần từ khoá) – dùng khi người dùng vừa mở mục Quán ăn.
     *
     * @param keyword từ khoá thu hẹp (vd "quán chay"), null/rỗng = mọi nhà hàng
     * @param radiusMeters bán kính tìm, tính bằng mét
     */
    public List<Place> nearbySearch(double lat, double lng, String keyword, int radiusMeters) {
        if (!isConfigured()) {
            return List.of();
        }
        try {
            UriComponentsBuilder b = UriComponentsBuilder
                    .fromHttpUrl("https://maps.googleapis.com/maps/api/place/nearbysearch/json")
                    .queryParam("location", lat + "," + lng)
                    .queryParam("radius", radiusMeters)
                    .queryParam("language", "vi")
                    .queryParam("key", apiKey);
            if (keyword == null || keyword.isBlank()) {
                b.queryParam("type", "restaurant");
            } else {
                b.queryParam("keyword", keyword.trim());
            }
            return fetch(b.encode().build().toUri());
        } catch (Exception e) {
            log.warn("Gọi Google Places (nearby search) thất bại: {}", e.getMessage());
            return List.of();
        }
    }

    private List<Place> fetch(URI uri) {
        JsonNode data = http.get().uri(uri).retrieve().body(JsonNode.class);
        return parse(data);
    }

    /** Đọc JSON trả về của Text Search / Nearby Search (hai API dùng chung cấu trúc "results"). */
    static List<Place> parse(JsonNode data) {
        if (data == null) {
            return List.of();
        }
        String status = data.path("status").asText();
        if (!"OK".equals(status)) {
            if (!"ZERO_RESULTS".equals(status)) {
                // REQUEST_DENIED: key sai / chưa bật Places API / chưa bật thanh toán. OVER_QUERY_LIMIT: hết hạn mức.
                log.warn("Google Places trả về {}: {}", status, data.path("error_message").asText(""));
            }
            return List.of();
        }
        List<Place> places = new ArrayList<>();
        for (JsonNode p : data.path("results")) {
            JsonNode photos = p.path("photos");
            String photoRef = photos.isArray() && !photos.isEmpty()
                    ? photos.get(0).path("photo_reference").asText(null) : null;
            JsonNode open = p.path("opening_hours").path("open_now");
            JsonNode loc = p.path("geometry").path("location");
            String address = p.hasNonNull("formatted_address") ? p.get("formatted_address").asText()
                    : p.path("vicinity").asText("");
            List<String> types = new ArrayList<>();
            for (JsonNode t : p.path("types")) {
                types.add(t.asText());
            }
            places.add(new Place(
                    p.path("place_id").asText(null),
                    p.path("name").asText("Quán ăn"),
                    address,
                    p.path("rating").asDouble(0),
                    photoRef,
                    open.isBoolean() ? open.asBoolean() : null,
                    loc.hasNonNull("lat") ? loc.get("lat").asDouble() : null,
                    loc.hasNonNull("lng") ? loc.get("lng").asDouble() : null,
                    types));
        }
        return places;
    }

    /** Tải ảnh quán từ Google (backend làm trung gian để không lộ key). */
    public ResponseEntity<byte[]> photo(String reference) {
        URI uri = UriComponentsBuilder
                .fromHttpUrl("https://maps.googleapis.com/maps/api/place/photo")
                .queryParam("maxwidth", 800)
                .queryParam("photoreference", reference)
                .queryParam("key", apiKey)
                .encode().build().toUri();
        return http.get().uri(uri).retrieve().toEntity(byte[].class);
    }
}
