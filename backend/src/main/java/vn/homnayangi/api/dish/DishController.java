package vn.homnayangi.api.dish;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import vn.homnayangi.api.auth.AuthContext;

/** Món ăn: gợi ý, tìm kiếm, nổi bật, chi tiết. Không bắt buộc đăng nhập. */
@RestController
@RequestMapping("/api/dishes")
public class DishController {

    private final DishService service;

    public DishController(DishService service) {
        this.service = service;
    }

    /** VD: /api/dishes/suggestions?region=Miền bắc&weather=Mưa&time=15–30 phút */
    @GetMapping("/suggestions")
    public DishService.SuggestionResult suggestions(
            @RequestParam(required = false) String time,
            @RequestParam(required = false) Double maxTime,
            @RequestParam(required = false) String region,
            @RequestParam(required = false) String weather,
            @RequestParam(required = false) String mood,
            @RequestParam(required = false) Integer limit) {
        return service.suggestions(new DishCriteria(time, maxTime, region, weather, mood),
                AuthContext.currentUserId(), limit);
    }

    /** VD: /api/dishes/search?q=bun cha&category=Bún */
    @GetMapping("/search")
    public List<DishDto> search(
            @RequestParam(required = false, defaultValue = "") String q,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String time,
            @RequestParam(required = false) Double maxTime,
            @RequestParam(required = false) String region,
            @RequestParam(required = false) String weather,
            @RequestParam(required = false) String mood) {
        return service.search(q, category, new DishCriteria(time, maxTime, region, weather, mood),
                AuthContext.currentUserId());
    }

    @GetMapping("/featured")
    public List<DishDto> featured() {
        return service.featured(AuthContext.currentUserId());
    }

    @GetMapping("/{id}")
    public DishDto get(@PathVariable long id) {
        return service.get(id, AuthContext.currentUserId());
    }
}
