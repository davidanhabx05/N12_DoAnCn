package vn.homnayangi.api.restaurant;

import jakarta.servlet.http.HttpServletRequest;

import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.time.Duration;

import vn.homnayangi.api.common.ApiException;

@RestController
@RequestMapping("/api/restaurants")
public class RestaurantController {

    private final RestaurantService service;
    private final PlacesClient places;

    public RestaurantController(RestaurantService service, PlacesClient places) {
        this.service = service;
        this.places = places;
    }

    /**
     * VD: /api/restaurants?q=bún chả&lat=21.02&lng=105.85
     *     /api/restaurants?dish=Bún chả thịt băm thơm ngon   (tự rút gọn về "Bún chả")
     */
    @GetMapping
    public RestaurantService.SearchResult search(
            @RequestParam(required = false, defaultValue = "") String q,
            @RequestParam(required = false) String dish,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lng,
            @RequestParam(required = false) String diet,
            @RequestParam(required = false, defaultValue = "true") boolean live,
            HttpServletRequest request) {
        String baseUrl = ServletUriComponentsBuilder.fromContextPath(request).build().toUriString();
        return service.search(q, dish, category, lat, lng, diet, live, baseUrl);
    }

    /** Ảnh quán từ Google Places (backend tải hộ để không lộ API key). */
    @GetMapping("/photo")
    public ResponseEntity<byte[]> photo(@RequestParam String ref) {
        if (!places.isConfigured()) {
            throw ApiException.notFound("Chưa cấu hình Google Places");
        }
        try {
            ResponseEntity<byte[]> upstream = places.photo(ref);
            MediaType type = upstream.getHeaders().getContentType() != null
                    ? upstream.getHeaders().getContentType() : MediaType.IMAGE_JPEG;
            return ResponseEntity.ok()
                    .contentType(type)
                    .cacheControl(CacheControl.maxAge(Duration.ofDays(1)).cachePublic())
                    .body(upstream.getBody());
        } catch (Exception e) {
            throw ApiException.notFound("Không tải được ảnh quán");
        }
    }
}
