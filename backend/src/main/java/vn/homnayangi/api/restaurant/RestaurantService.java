package vn.homnayangi.api.restaurant;

import java.time.LocalTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.springframework.stereotype.Service;
import org.springframework.web.util.UriComponentsBuilder;

import vn.homnayangi.api.common.TextUtils;
import vn.homnayangi.api.dish.MainDishes;

/**
 * Tìm quán THẬT quanh vị trí người dùng. Thứ tự nguồn dữ liệu:
 * <ol>
 *   <li>Google Places – khi đã cấu hình GOOGLE_PLACES_API_KEY (có điểm đánh giá, ảnh, giờ mở cửa);</li>
 *   <li>OpenStreetMap – miễn phí, không cần key, dùng khi chưa có key hoặc Google không trả kết quả;</li>
 *   <li>Bảng restaurants trong DB – quán bạn tự thêm (mặc định để trống), luôn được trộn vào.</li>
 * </ol>
 * Không gõ từ khoá vẫn có kết quả: liệt kê quán gần nhất. Không còn quán "giả" khi không tìm thấy.
 */
@Service
public class RestaurantService {

    public static final ZoneId VIETNAM = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final double HANOI_LAT = 21.028511;
    private static final double HANOI_LNG = 105.804817;
    private static final Set<String> WEAK_WORDS = Set.of("banh", "mon", "quan", "nha", "hang", "an", "com");
    private static final String FALLBACK_IMAGE =
            "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?q=80&w=1000&auto=format&fit=crop";
    private static final String ALL = "Tất cả";
    /** Bán kính (mét) khi liệt kê quán quanh vị trí bằng Google. */
    private static final int NEARBY_RADIUS_METERS = 3000;
    private static final int MAX_OSM_RESULTS = 40;
    private static final String NO_ADDRESS = "Chưa có địa chỉ, bấm Mở Google Maps để xem vị trí";

    /** Từ khoá gửi Google khi người dùng chọn một nhóm quán. */
    private static final Map<String, String> CATEGORY_KEYWORDS = Map.of(
            "Món Chay", "quán chay",
            "Healthy", "healthy salad eat clean",
            "Nhà hàng", "nhà hàng",
            "Ăn vặt", "ăn vặt",
            "Quán Nhậu", "quán nhậu");

    private final RestaurantRepository repository;
    private final PlacesClient places;
    private final OsmClient osm;

    public RestaurantService(RestaurantRepository repository, PlacesClient places, OsmClient osm) {
        this.repository = repository;
        this.places = places;
        this.osm = osm;
    }

    /**
     * @param usedGooglePlaces true nếu kết quả có quán từ Google Places
     * @param source           "google" | "osm" | "local" (quán tự thêm trong DB) | "none" (không có quán nào)
     * @param hasLocation      false = app không gửi vị trí, đang tìm quanh trung tâm Hà Nội
     */
    public record SearchResult(String query, boolean usedGooglePlaces, String source, boolean hasLocation,
                               List<RestaurantDto> items) {
    }

    /**
     * @param query    từ khoá người dùng gõ (tên quán, món, đường...). Để trống = quán gần nhất
     * @param dish     tên món (từ màn chi tiết món / chatbot) – sẽ rút gọn về món chính
     * @param category "Tất cả" | Món Chay | Healthy | Nhà hàng | Ăn vặt | Quán Nhậu
     * @param dietType chế độ ăn trong hồ sơ – quán hợp chế độ ăn được ưu tiên lên đầu
     * @param live     true: được phép gọi Google Places / OpenStreetMap
     */
    public SearchResult search(String query, String dish, String category, Double lat, Double lng,
                               String dietType, boolean live, String baseUrl) {
        String q = query == null ? "" : query.trim();
        if (dish != null && !dish.isBlank()) {
            String main = MainDishes.detect(dish);
            q = main != null ? main : dish.trim();
        }
        String cat = category == null || category.isBlank() ? ALL : category.trim();
        boolean hasLocation = lat != null && lng != null;
        double originLat = hasLocation ? lat : HANOI_LAT;
        double originLng = hasLocation ? lng : HANOI_LNG;
        LocalTime nowTime = LocalTime.now(VIETNAM);
        int nowMinute = nowTime.getHour() * 60 + nowTime.getMinute();
        String normalizedQuery = TextUtils.normalize(q);

        // 1) Quán tự thêm trong DB: chấm điểm, cùng điểm thì quán gần hơn đứng trước
        record Scored(Restaurant r, int score, double km) {
        }
        List<Scored> scored = new ArrayList<>();
        for (Restaurant r : repository.findAll()) {
            if (!ALL.equals(cat) && !cat.equals(r.category())) {
                continue;
            }
            int score = matchScore(r, q, normalizedQuery);
            if (score > 0) {
                scored.add(new Scored(r, score, distanceKm(originLat, originLng, r.latitude(), r.longitude())));
            }
        }
        scored.sort(Comparator.comparingInt(Scored::score).reversed().thenComparingDouble(Scored::km));
        List<RestaurantDto> local = new ArrayList<>();
        for (Scored s : scored) {
            Restaurant r = s.r();
            local.add(new RestaurantDto("res_" + r.id(), r.name(), r.address(), r.rating(), r.imageUrl(),
                    r.category(), formatKm(s.km()), isOpen(r, nowMinute), r.latitude(), r.longitude(),
                    r.name() + ", " + r.address(), null, true));
        }

        // 2) Quán thật quanh vị trí: Google Places trước, không có thì OpenStreetMap
        List<RestaurantDto> dynamic = new ArrayList<>();
        String source = "none";
        if (live && places.isConfigured()) {
            dynamic = fromGoogle(q, cat, hasLocation, originLat, originLng, baseUrl);
            if (!dynamic.isEmpty()) {
                source = "google";
            }
        }
        if (live && dynamic.isEmpty() && osm.isEnabled()) {
            dynamic = fromOsm(q, normalizedQuery, cat, originLat, originLng, nowTime);
            if (!dynamic.isEmpty()) {
                source = "osm";
            }
        }

        // 3) Gộp: quán thật trước, rồi tới quán tự thêm chưa trùng tên
        List<RestaurantDto> result = new ArrayList<>(dynamic);
        Set<String> names = new HashSet<>();
        for (RestaurantDto d : dynamic) {
            names.add(TextUtils.normalize(d.name()));
        }
        for (RestaurantDto d : local) {
            if (names.add(TextUtils.normalize(d.name()))) {
                result.add(d);
            }
        }
        if (dynamic.isEmpty() && !result.isEmpty()) {
            source = "local";
        }

        // 4) Ưu tiên (không loại bỏ) quán hợp chế độ ăn khi đang xem tất cả
        String preferred = preferredCategoryFor(dietType);
        if (preferred != null && ALL.equals(cat) && q.isEmpty()) {
            List<RestaurantDto> ordered = new ArrayList<>();
            result.stream().filter(r -> preferred.equals(r.category())).forEach(ordered::add);
            result.stream().filter(r -> !preferred.equals(r.category())).forEach(ordered::add);
            result = ordered;
        }
        return new SearchResult(q, "google".equals(source), source, hasLocation, result);
    }

    // ---------------------------------------------------------- Google Places
    private List<RestaurantDto> fromGoogle(String q, String cat, boolean hasLocation, double lat, double lng,
                                           String baseUrl) {
        String keyword = CATEGORY_KEYWORDS.get(cat);   // null khi "Tất cả"
        List<PlacesClient.Place> found;
        if (!q.isEmpty()) {
            String text = keyword == null ? q : q + " " + keyword;
            found = places.textSearch(text, hasLocation ? lat : null, hasLocation ? lng : null);
        } else if (hasLocation) {
            found = places.nearbySearch(lat, lng, keyword, NEARBY_RADIUS_METERS);
        } else {
            // Chưa có vị trí: tìm theo chữ quanh Hà Nội
            found = places.textSearch(keyword == null ? "quán ăn ngon" : keyword, null, null);
        }

        List<RestaurantDto> out = new ArrayList<>();
        for (PlacesClient.Place p : found) {
            if (p.lat() == null || p.lng() == null) {
                continue;   // không có toạ độ thì không tính được khoảng cách / chỉ đường
            }
            String image = p.photoReference() != null
                    ? UriComponentsBuilder.fromHttpUrl(baseUrl).path("/api/restaurants/photo")
                            .queryParam("ref", p.photoReference()).encode().build().toUriString()
                    : FALLBACK_IMAGE;
            String address = p.address() == null || p.address().isBlank() ? NO_ADDRESS : p.address();
            String category = keyword != null ? cat : classify(p.name(), googleAmenity(p.types()), "", false);
            out.add(new RestaurantDto("place_" + (p.placeId() != null ? p.placeId() : p.name().hashCode()),
                    p.name(), address, p.rating(), image, category,
                    hasLocation ? formatKm(distanceKm(lat, lng, p.lat(), p.lng())) : "-- km",
                    p.openNow() == null || p.openNow(), p.lat(), p.lng(),
                    p.address() == null || p.address().isBlank() ? p.name() : p.name() + ", " + p.address(),
                    p.placeId(), p.openNow() != null));
        }
        if (hasLocation) {
            out.sort(Comparator.comparingDouble(d -> distanceKm(lat, lng, d.latitude(), d.longitude())));
        }
        return out;
    }

    /** Quy loại địa điểm của Google về amenity của OpenStreetMap để dùng chung hàm classify(). */
    private static String googleAmenity(List<String> types) {
        if (types == null) {
            return "restaurant";
        }
        if (types.contains("bar") || types.contains("night_club")) {
            return "bar";
        }
        if (types.contains("restaurant")) {
            return "restaurant";
        }
        if (types.contains("cafe") || types.contains("bakery") || types.contains("meal_takeaway")) {
            return "fast_food";
        }
        return "restaurant";
    }

    // ---------------------------------------------------------- OpenStreetMap
    private List<RestaurantDto> fromOsm(String q, String normalizedQuery, String cat, double lat, double lng,
                                        LocalTime now) {
        record Hit(OsmClient.OsmPlace place, String category, int score, double km) {
        }
        List<Hit> hits = new ArrayList<>();
        for (OsmClient.OsmPlace p : osm.nearby(lat, lng)) {
            String category = classify(p.name(), p.amenity(), p.cuisine(), p.vegetarian());
            if (!ALL.equals(cat) && !cat.equals(category)) {
                continue;
            }
            int score = osmScore(p, category, cat, q, normalizedQuery);
            if (score > 0) {
                hits.add(new Hit(p, category, score, distanceKm(lat, lng, p.lat(), p.lng())));
            }
        }
        // Không gõ từ khoá: gần nhất trước. Có từ khoá: khớp tốt nhất trước, rồi tới gần nhất.
        hits.sort(Comparator.comparingInt(Hit::score).reversed().thenComparingDouble(Hit::km));

        List<RestaurantDto> out = new ArrayList<>();
        for (Hit h : hits) {
            if (out.size() >= MAX_OSM_RESULTS) {
                break;
            }
            OsmClient.OsmPlace p = h.place();
            Boolean open = openNow(p.openingHours(), now.getHour() * 60 + now.getMinute());
            boolean hasAddress = !p.address().isBlank();
            out.add(new RestaurantDto(p.id(), p.name(), hasAddress ? p.address() : NO_ADDRESS,
                    0, "", h.category(), formatKm(h.km()), open == null || open, p.lat(), p.lng(),
                    hasAddress ? p.name() + ", " + p.address()
                            : String.format(Locale.US, "%.6f,%.6f", p.lat(), p.lng()),
                    null, open != null));
        }
        return out;
    }

    /**
     * Điểm khớp của một quán OpenStreetMap với từ khoá; 0 = không hiển thị.
     *
     * @param category nhóm của quán (kết quả classify)
     * @param cat      nhóm người dùng đang chọn, "Tất cả" nếu không chọn
     */
    static int osmScore(OsmClient.OsmPlace p, String category, String cat, String rawQuery, String normalizedQuery) {
        if (normalizedQuery.isEmpty()) {
            // Chưa gõ gì: chỉ liệt kê nơi bán đồ ăn.
            // Quán cà phê thuần chỉ hiện khi tìm đúng tên; bar / quán bia chỉ hiện khi chọn nhóm Quán Nhậu.
            if ("cafe".equals(p.amenity()) && !looksLikeSnackShop(p.name(), p.cuisine())) {
                return 0;
            }
            if (ALL.equals(cat) && isBar(p.amenity())) {
                return 0;
            }
            return 1;
        }
        Restaurant asRow = new Restaurant(0, p.name(), p.address(), 0, "", category, p.lat(), p.lng(), 0, 1440);
        int score = matchScore(asRow, rawQuery, normalizedQuery);
        // Thẻ cuisine của OpenStreetMap: "vietnamese;noodle", "pho", "banh_mi"...
        String cuisine = normalizeTag(p.cuisine());
        if (!cuisine.isEmpty() && TextUtils.hasPhrase(cuisine, normalizedQuery)) {
            score = Math.max(score, 60);
        }
        return score;
    }

    private static boolean isBar(String amenity) {
        return "bar".equals(amenity) || "pub".equals(amenity) || "biergarten".equals(amenity);
    }

    private static String normalizeTag(String tag) {
        return TextUtils.normalize(tag == null ? "" : tag.replace('_', ' ').replace(';', ' '));
    }

    /** Tên / ẩm thực cho thấy đây là quán ăn vặt (chè, trà sữa, kem, bánh ngọt...). */
    private static boolean looksLikeSnackShop(String name, String cuisine) {
        String n = TextUtils.normalize(name);
        String c = normalizeTag(cuisine);
        return TextUtils.hasPhrase(n, "an vat") || TextUtils.hasPhrase(n, "che") || n.contains("tra sua")
                || TextUtils.hasPhrase(n, "kem") || TextUtils.hasPhrase(n, "banh") || c.contains("dessert")
                || c.contains("bubble tea") || c.contains("ice cream") || c.contains("cake");
    }

    /**
     * Xếp một quán vào đúng 1 trong 5 nhóm của app dựa trên tên, loại địa điểm và ẩm thực.
     *
     * @param amenity    loại địa điểm kiểu OpenStreetMap: restaurant, fast_food, cafe, bar, pub...
     * @param vegetarian true nếu bản đồ ghi rõ quán chỉ bán đồ chay
     */
    static String classify(String name, String amenity, String cuisine, boolean vegetarian) {
        String n = TextUtils.normalize(name);
        String c = normalizeTag(cuisine);
        String a = amenity == null ? "" : amenity;
        if (vegetarian || TextUtils.hasPhrase(n, "chay") || n.contains("vegetarian") || n.contains("vegan")
                || c.contains("vegetarian") || c.contains("vegan")) {
            return "Món Chay";
        }
        if (n.contains("healthy") || n.contains("salad") || n.contains("eat clean") || c.contains("salad")) {
            return "Healthy";
        }
        if (isBar(a) || TextUtils.hasPhrase(n, "nhau") || n.contains("bia hoi") || n.contains("beer")) {
            return "Quán Nhậu";
        }
        if (a.equals("fast_food") || a.equals("cafe") || a.equals("ice_cream") || a.equals("food_court")
                || looksLikeSnackShop(name, cuisine)) {
            return "Ăn vặt";
        }
        return "Nhà hàng";
    }

    /**
     * Đọc giờ mở cửa kiểu OpenStreetMap ở các dạng phổ biến: "24/7", "06:00-22:00",
     * "Mo-Su 06:00-14:00,17:00-22:00". Dạng phức tạp hơn (khác nhau theo thứ) -> null = không rõ.
     *
     * @param nowMinute phút trong ngày, 0..1439
     */
    static Boolean openNow(String openingHours, int nowMinute) {
        if (openingHours == null) {
            return null;
        }
        String oh = openingHours.trim();
        if (oh.isEmpty()) {
            return null;
        }
        if (oh.equals("24/7")) {
            return true;
        }
        if (oh.startsWith("Mo-Su ")) {
            oh = oh.substring(6).trim();
        }
        boolean open = false;
        for (String range : oh.split(",")) {
            Matcher m = TIME_RANGE.matcher(range.trim());
            if (!m.matches()) {
                return null;
            }
            int from = Integer.parseInt(m.group(1)) * 60 + Integer.parseInt(m.group(2));
            int to = Integer.parseInt(m.group(3)) * 60 + Integer.parseInt(m.group(4));
            if (from > 1440 || to > 1440) {
                return null;
            }
            if (from <= to ? (nowMinute >= from && nowMinute < to) : (nowMinute >= from || nowMinute < to)) {
                open = true;
            }
        }
        return open;
    }

    private static final Pattern TIME_RANGE = Pattern.compile("(\\d{1,2}):(\\d{2})\\s*-\\s*(\\d{1,2}):(\\d{2})");

    public List<String> topNames(int limit) {
        return repository.findNames(limit);
    }

    /** Điểm khớp giữa từ khoá và quán: 0 = không khớp. */
    private static int matchScore(Restaurant r, String rawQuery, String normalizedQuery) {
        if (normalizedQuery.isEmpty()) {
            return 1;
        }
        String name = TextUtils.normalize(r.name());
        if (name.contains(normalizedQuery) || TextUtils.normalize(r.category()).equals(normalizedQuery)) {
            return 100;
        }
        // Địa chỉ: so khớp có dấu để "phở" không bị nhầm với "phố";
        // bỏ dấu chỉ khi từ khoá có từ 2 chữ trở lên ("kim ma", "tay ho").
        String addressLower = r.address().toLowerCase(Locale.ROOT);
        if (addressLower.contains(rawQuery.toLowerCase(Locale.ROOT))
                || (normalizedQuery.contains(" ") && TextUtils.normalize(r.address()).contains(normalizedQuery))) {
            return 80;
        }
        String[] words = normalizedQuery.split(" ");
        // Thử cụm từ dài trước: "bun cha thit bo" -> "bun cha thit" -> "bun cha"
        for (int len = words.length - 1; len >= 2; len--) {
            if (name.contains(String.join(" ", java.util.Arrays.copyOfRange(words, 0, len)))) {
                return 10 * len;
            }
        }
        if (words.length > 0 && words[0].length() >= 3 && !WEAK_WORDS.contains(words[0])
                && TextUtils.hasPhrase(name, words[0])) {
            return 5;
        }
        return 0;
    }

    static boolean isOpen(Restaurant r, int nowMinute) {
        if (r.openMinute() <= r.closeMinute()) {
            return nowMinute >= r.openMinute() && nowMinute < r.closeMinute();
        }
        // Mở qua đêm (vd 18:00 -> 02:00)
        return nowMinute >= r.openMinute() || nowMinute < r.closeMinute();
    }

    static String preferredCategoryFor(String dietType) {
        if (dietType == null || dietType.isBlank() || "Bình thường".equals(dietType)) {
            return null;
        }
        if (dietType.contains("Chay")) {
            return "Món Chay";
        }
        return "Healthy"; // Keto, Ít tinh bột, Eat clean, Địa Trung Hải
    }

    /** Khoảng cách đường chim bay (km) theo công thức Haversine. */
    static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
        double r = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
        return 2 * r * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    private static String formatKm(double km) {
        return String.format(Locale.US, "%.1f km", km);
    }
}
