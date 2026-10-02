package vn.homnayangi.api.restaurant;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.List;

import com.fasterxml.jackson.databind.ObjectMapper;

import org.junit.jupiter.api.Test;

/** Kiểm thử luồng tìm quán thật (không cần mạng, không cần database). Chạy: ./mvnw test */
class RestaurantLogicTest {

    private static final String BASE_URL = "http://localhost:8080";

    private static final String OSM_JSON = """
            {"elements":[
             {"type":"node","id":1,"lat":21.0340,"lon":105.8500,"tags":{"amenity":"restaurant","name":"Phở Thìn",
               "cuisine":"vietnamese;noodle","addr:housenumber":"13","addr:street":"Lò Đúc","addr:city":"Hà Nội",
               "opening_hours":"Mo-Su 06:00-21:00"}},
             {"type":"node","id":2,"lat":21.0300,"lon":105.8520,"tags":{"amenity":"cafe","name":"Cộng Cà Phê"}},
             {"type":"way","id":3,"center":{"lat":21.0290,"lon":105.8510},"tags":{"amenity":"restaurant",
               "name":"Nhà hàng chay An Lạc","diet:vegetarian":"only"}},
             {"type":"node","id":5,"lat":21.0320,"lon":105.8530,"tags":{"amenity":"pub","name":"Bia hơi Hà Nội"}},
             {"type":"node","id":6,"lat":21.0500,"lon":105.8600,"tags":{"amenity":"restaurant",
               "name":"Bún chả Hương Liên","opening_hours":"24/7"}},
             {"type":"node","id":7,"lat":21.0305,"lon":105.8505,"tags":{"amenity":"restaurant"}}
            ]}""";

    /** Service dùng dữ liệu OpenStreetMap mẫu ở trên; Google Places tắt, bảng restaurants trống. */
    private static RestaurantService serviceWithSampleOsm() throws Exception {
        List<OsmClient.OsmPlace> places = OsmClient.parse(new ObjectMapper().readTree(OSM_JSON));
        RestaurantRepository emptyTable = new RestaurantRepository(null) {
            @Override
            public List<Restaurant> findAll() {
                return List.of();
            }
        };
        OsmClient osm = new OsmClient(true, "http://khong-goi-mang") {
            @Override
            public List<OsmPlace> nearby(double lat, double lng) {
                return places;
            }
        };
        return new RestaurantService(emptyTable, new PlacesClient(""), osm);
    }

    @Test
    void osmParserKeepsNamedPlacesAndBuildsAddress() throws Exception {
        List<OsmClient.OsmPlace> places = OsmClient.parse(new ObjectMapper().readTree(OSM_JSON));
        assertEquals(5, places.size()); // quán không có tên bị bỏ
        assertEquals("13 Lò Đúc, Hà Nội", places.get(0).address());
        assertTrue(places.get(2).vegetarian());
        assertEquals(21.0290, places.get(2).lat(), 1e-9); // "way" lấy toạ độ từ center
    }

    @Test
    void nearbyWithoutKeywordListsFoodPlacesNearestFirst() throws Exception {
        RestaurantService.SearchResult result =
                serviceWithSampleOsm().search("", null, null, 21.03, 105.85, "Bình thường", true, BASE_URL);
        assertEquals("osm", result.source());
        assertTrue(result.hasLocation());
        List<String> names = result.items().stream().map(RestaurantDto::name).toList();
        assertEquals(List.of("Nhà hàng chay An Lạc", "Phở Thìn", "Bún chả Hương Liên"), names); // bỏ cà phê, quán bia
        assertEquals(0, result.items().get(0).rating());      // OpenStreetMap không có điểm đánh giá
        assertFalse(result.items().get(0).openKnown());       // và quán này không ghi giờ mở cửa
    }

    @Test
    void dishNameIsShortenedAndNothingIsInventedWhenNoMatch() throws Exception {
        RestaurantService service = serviceWithSampleOsm();
        RestaurantService.SearchResult bunCha = service.search("", "Bún chả Hà Nội", null, 21.03, 105.85, null, true, BASE_URL);
        assertEquals("Bún chả", bunCha.query());
        assertEquals("Bún chả Hương Liên", bunCha.items().get(0).name());

        RestaurantService.SearchResult sushi = service.search("sushi", null, null, 21.03, 105.85, null, true, BASE_URL);
        assertTrue(sushi.items().isEmpty());
        assertEquals("none", sushi.source());
    }

    @Test
    void categoriesAndDietPreference() throws Exception {
        RestaurantService service = serviceWithSampleOsm();
        assertEquals("Bia hơi Hà Nội",
                service.search("", null, "Quán Nhậu", 21.03, 105.85, null, true, BASE_URL).items().get(0).name());
        // Hồ sơ ăn chay: quán chay được đưa lên đầu; không gửi vị trí -> hasLocation = false
        RestaurantService.SearchResult vegetarianFirst = service.search("", null, null, null, null, "Chay trường", true, BASE_URL);
        assertEquals("Món Chay", vegetarianFirst.items().get(0).category());
        assertFalse(vegetarianFirst.hasLocation());

        assertEquals("Món Chay", RestaurantService.classify("Cơm chay Hà Thành", "restaurant", "", false));
        assertEquals("Quán Nhậu", RestaurantService.classify("Beer Club", "bar", "", false));
        assertEquals("Ăn vặt", RestaurantService.classify("Chè bốn mùa", "cafe", "dessert", false));
        assertEquals("Nhà hàng", RestaurantService.classify("Phở 10", "restaurant", "vietnamese", false));
    }

    @Test
    void openingHours() {
        assertEquals(Boolean.TRUE, RestaurantService.openNow("24/7", 100));
        assertEquals(Boolean.TRUE, RestaurantService.openNow("Mo-Su 06:00-21:00", 7 * 60));
        assertEquals(Boolean.FALSE, RestaurantService.openNow("06:00-14:00,17:00-22:00", 15 * 60));
        assertEquals(Boolean.TRUE, RestaurantService.openNow("18:00-02:00", 60)); // mở qua đêm
        assertNull(RestaurantService.openNow("Mo-Fr 08:00-17:00; Sa off", 600));  // quá phức tạp -> không rõ
        assertNull(RestaurantService.openNow("", 600));
    }

    @Test
    void googleResponseParsing() throws Exception {
        String json = """
                {"status":"OK","results":[
                  {"place_id":"abc","name":"Phở 10","vicinity":"10 Lý Quốc Sư","rating":4.4,
                   "geometry":{"location":{"lat":21.03,"lng":105.84}},"opening_hours":{"open_now":true},
                   "photos":[{"photo_reference":"REF"}],"types":["restaurant","food"]},
                  {"place_id":"def","name":"Quán mới","geometry":{"location":{"lat":21.0,"lng":105.8}}}]}""";
        List<PlacesClient.Place> places = PlacesClient.parse(new ObjectMapper().readTree(json));
        assertEquals(2, places.size());
        assertEquals("10 Lý Quốc Sư", places.get(0).address());
        assertEquals(0, places.get(1).rating());   // chưa có điểm -> 0, không tự gán 4.5
        assertNull(places.get(1).openNow());
        assertTrue(PlacesClient.parse(new ObjectMapper().readTree(
                "{\"status\":\"REQUEST_DENIED\",\"error_message\":\"The provided API key is invalid.\"}")).isEmpty());
    }
}
