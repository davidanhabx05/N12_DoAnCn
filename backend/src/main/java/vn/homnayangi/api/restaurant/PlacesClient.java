package vn.homnayangi.api.restaurant;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;

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

    private static final String NEW_API = "https://places.googleapis.com/v1/";
    /** Các trường cần lấy ở Places API (New) – bắt buộc phải khai báo, nếu thiếu Google trả lỗi. */
    private static final String FIELD_MASK = "places.id,places.displayName,places.formattedAddress,places.rating,"
            + "places.location,places.photos,places.currentOpeningHours.openNow,places.types";

    private final String apiKey;
    private final RestClient http;
    private final HttpClient newApiHttp = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(5)).build();
    private final ObjectMapper mapper = new ObjectMapper();
    /**
     * Project Google Cloud tạo gần đây không bật được Places API bản cũ (legacy). Lần đầu bản cũ bị
     * từ chối (REQUEST_DENIED) thì đặt cờ này và từ đó chỉ gọi Places API (New).
     */
    private volatile boolean legacyDenied = false;

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
            if (!legacyDenied) {
                List<Place> found = fetch(b.encode().build().toUri());
                if (!legacyDenied) {
                    return found;
                }
            }
            return newTextSearch(lat != null ? query : query + " Hà Nội", lat, lng, 5000);
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
            if (!legacyDenied) {
                List<Place> found = fetch(b.encode().build().toUri());
                if (!legacyDenied) {
                    return found;
                }
            }
            // Nearby Search bản mới không nhận từ khoá -> có từ khoá thì dùng Text Search quanh vị trí
            return keyword == null || keyword.isBlank()
                    ? newNearbySearch(lat, lng, radiusMeters)
                    : newTextSearch(keyword.trim(), lat, lng, radiusMeters);
        } catch (Exception e) {
            log.warn("Gọi Google Places (nearby search) thất bại: {}", e.getMessage());
            return List.of();
        }
    }

    private List<Place> fetch(URI uri) {
        JsonNode data = http.get().uri(uri).retrieve().body(JsonNode.class);
        if (data != null && "REQUEST_DENIED".equals(data.path("status").asText())) {
            legacyDenied = true;
            log.info("Places API bản cũ bị từ chối ({}). Chuyển sang Places API (New).",
                    data.path("error_message").asText(""));
            return List.of();
        }
        return parse(data);
    }

    // ------------------------------------------------------- Places API (New)
    private List<Place> newTextSearch(String query, Double lat, Double lng, int radiusMeters) throws Exception {
        ObjectNode body = mapper.createObjectNode();
        body.put("textQuery", query);
        body.put("languageCode", "vi");
        body.put("regionCode", "VN");
        body.put("pageSize", 20);
        if (lat != null && lng != null) {
            body.set("locationBias", circle(lat, lng, radiusMeters));
        }
        return postNewApi("places:searchText", body);
    }

    private List<Place> newNearbySearch(double lat, double lng, int radiusMeters) throws Exception {
        ObjectNode body = mapper.createObjectNode();
        body.putArray("includedTypes").add("restaurant");
        body.put("maxResultCount", 20);
        body.put("languageCode", "vi");
        body.set("locationRestriction", circle(lat, lng, radiusMeters));
        return postNewApi("places:searchNearby", body);
    }

    private ObjectNode circle(double lat, double lng, int radiusMeters) {
        ObjectNode wrapper = mapper.createObjectNode();
        ObjectNode circle = wrapper.putObject("circle");
        circle.putObject("center").put("latitude", lat).put("longitude", lng);
        circle.put("radius", (double) radiusMeters);
        return wrapper;
    }

    private List<Place> postNewApi(String method, ObjectNode body) throws Exception {
        HttpRequest request = HttpRequest.newBuilder(URI.create(NEW_API + method))
                .timeout(Duration.ofSeconds(10))
                .header("Content-Type", "application/json; charset=UTF-8")
                .header("X-Goog-Api-Key", apiKey)
                .header("X-Goog-FieldMask", FIELD_MASK)
                .POST(HttpRequest.BodyPublishers.ofString(mapper.writeValueAsString(body), StandardCharsets.UTF_8))
                .build();
        HttpResponse<String> response = newApiHttp.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
        JsonNode data = mapper.readTree(response.body());
        if (response.statusCode() != 200) {
            // Thường gặp: API chưa bật, key bị giới hạn sai, chưa bật thanh toán
            log.warn("Google Places (New) trả về HTTP {}: {}", response.statusCode(),
                    data.path("error").path("message").asText(""));
            return List.of();
        }
        return parseNew(data);
    }

    /** Đọc JSON của Places API (New): {"places":[{id, displayName:{text}, formattedAddress, location, ...}]}. */
    static List<Place> parseNew(JsonNode data) {
        List<Place> places = new ArrayList<>();
        if (data == null) {
            return places;
        }
        for (JsonNode p : data.path("places")) {
            JsonNode photos = p.path("photos");
            String photoName = photos.isArray() && !photos.isEmpty() ? photos.get(0).path("name").asText(null) : null;
            JsonNode open = p.path("currentOpeningHours").path("openNow");
            JsonNode loc = p.path("location");
            List<String> types = new ArrayList<>();
            for (JsonNode t : p.path("types")) {
                types.add(t.asText());
            }
            places.add(new Place(
                    p.path("id").asText(null),
                    p.path("displayName").path("text").asText("Quán ăn"),
                    p.path("formattedAddress").asText(""),
                    p.path("rating").asDouble(0),
                    photoName,
                    open.isBoolean() ? open.asBoolean() : null,
                    loc.hasNonNull("latitude") ? loc.get("latitude").asDouble() : null,
                    loc.hasNonNull("longitude") ? loc.get("longitude").asDouble() : null,
                    types));
        }
        return places;
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
        // Ảnh của Places API (New) có dạng "places/<id>/photos/<id>"
        if (reference != null && reference.startsWith("places/") && !reference.contains("..")) {
            URI newUri = UriComponentsBuilder.fromHttpUrl(NEW_API + reference + "/media")
                    .queryParam("maxWidthPx", 800)
                    .queryParam("key", apiKey)
                    .build().toUri();
            return http.get().uri(newUri).retrieve().toEntity(byte[].class);
        }
        URI uri = UriComponentsBuilder
                .fromHttpUrl("https://maps.googleapis.com/maps/api/place/photo")
                .queryParam("maxwidth", 800)
                .queryParam("photoreference", reference)
                .queryParam("key", apiKey)
                .encode().build().toUri();
        return http.get().uri(uri).retrieve().toEntity(byte[].class);
    }
}
