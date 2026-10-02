package vn.homnayangi.api.filter;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import vn.homnayangi.api.auth.AuthContext;
import vn.homnayangi.api.common.ApiException;
import vn.homnayangi.api.dish.DishCriteria;

/** Bộ lọc người dùng đặt tên và lưu lại. */
@RestController
@RequestMapping("/api/me/filters")
public class SavedFilterController {

    private final SavedFilterRepository repository;

    public SavedFilterController(SavedFilterRepository repository) {
        this.repository = repository;
    }

    @GetMapping
    public List<SavedFilterDto> list() {
        return repository.findByUser(AuthContext.requireUserId());
    }

    @PostMapping
    @Transactional
    public SavedFilterDto save(@RequestBody SavedFilterDto request) {
        long userId = AuthContext.requireUserId();
        String name = request.name() == null ? "" : request.name().trim();
        if (name.isEmpty()) {
            throw ApiException.badRequest("Vui lòng đặt tên cho bộ lọc");
        }
        if (name.length() > 60) {
            throw ApiException.badRequest("Tên bộ lọc tối đa 60 ký tự");
        }
        double maxTime = request.maxTime() == null ? 180 : Math.max(0, Math.min(180, request.maxTime()));
        DishCriteria criteria = new DishCriteria(request.time(), maxTime, request.region(), request.weather(),
                request.mood());
        if (!criteria.isActive() && maxTime >= 180) {
            throw ApiException.badRequest("Hãy chọn ít nhất một tiêu chí trước khi lưu");
        }
        return repository.upsert(userId, new SavedFilterDto(null, name, criteria.time(), maxTime,
                criteria.region(), criteria.weather(), criteria.mood()));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable long id) {
        repository.delete(AuthContext.requireUserId(), id);
        return ResponseEntity.noContent().build();
    }
}
