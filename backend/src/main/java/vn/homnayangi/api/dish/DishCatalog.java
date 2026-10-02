package vn.homnayangi.api.dish;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Bộ nhớ đệm toàn bộ món ăn (60 món) để lọc / tìm kiếm không dấu nhanh.
 * Tự nạp lại từ PostgreSQL định kỳ, nên sửa dữ liệu trong DBeaver là app thấy sau ít phút.
 */
@Component
public class DishCatalog {

    private static final Logger log = LoggerFactory.getLogger(DishCatalog.class);

    private final DishRepository repository;
    private volatile List<Dish> dishes = List.of();
    private volatile Map<Long, Dish> byId = Map.of();

    public DishCatalog(DishRepository repository) {
        this.repository = repository;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void loadOnStartup() {
        refresh();
    }

    @Scheduled(fixedDelayString = "${app.dish-cache-refresh-ms:60000}", initialDelayString = "${app.dish-cache-refresh-ms:60000}")
    public void refresh() {
        try {
            List<Dish> loaded = repository.findAll();
            Map<Long, Dish> map = new LinkedHashMap<>();
            for (Dish d : loaded) {
                map.put(d.getId(), d);
            }
            dishes = Collections.unmodifiableList(loaded);
            byId = Collections.unmodifiableMap(map);
            log.debug("Đã nạp {} món ăn", loaded.size());
        } catch (Exception e) {
            log.error("Không đọc được bảng dishes – kiểm tra kết nối PostgreSQL và đã chạy file SQL chưa", e);
        }
    }

    public List<Dish> all() {
        return dishes;
    }

    public Optional<Dish> find(long id) {
        return Optional.ofNullable(byId.get(id));
    }

    public int size() {
        return dishes.size();
    }
}
