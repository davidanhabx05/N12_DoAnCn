package vn.homnayangi.api.dish;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.concurrent.ThreadLocalRandom;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import vn.homnayangi.api.common.ApiException;
import vn.homnayangi.api.common.TextUtils;
import vn.homnayangi.api.dish.UserDishRepository.Kind;
import vn.homnayangi.api.user.PreferencesDto;
import vn.homnayangi.api.user.PreferencesRepository;

@Service
public class DishService {

    public static final int DEFAULT_CARD_LIMIT = 200;
    private static final List<String> MEAL_CATEGORIES = List.of("Bữa sáng", "Bữa trưa", "Bữa tối", "Ăn nhẹ", "Healthy");

    private final DishCatalog catalog;
    private final DishRepository dishRepository;
    private final UserDishRepository userDishes;
    private final PreferencesRepository preferences;

    public DishService(DishCatalog catalog, DishRepository dishRepository, UserDishRepository userDishes,
                       PreferencesRepository preferences) {
        this.catalog = catalog;
        this.dishRepository = dishRepository;
        this.userDishes = userDishes;
        this.preferences = preferences;
    }

    public PreferencesDto preferencesOf(Optional<Long> userId) {
        return userId.map(preferences::findByUserId).orElseGet(PreferencesDto::defaults);
    }

    // ------------------------------------------------------------ Gợi ý
    public record SuggestionResult(boolean filterActive, int total, List<DishDto> items) {
    }

    /**
     * Danh sách gợi ý cho Trang chủ / "Ăn theo ý trời":
     * lọc theo bộ lọc + hồ sơ ăn uống, xáo trộn ngẫu nhiên.
     * - Đang bật bộ lọc: trả đúng kết quả (có thể rỗng -> app hiện "Không tìm thấy").
     * - Không lọc: nếu hồ sơ quá chặt thì nới dần (chỉ loại món gây dị ứng), luôn có món.
     */
    public SuggestionResult suggestions(DishCriteria criteria, Optional<Long> userId, Integer limit) {
        PreferencesDto prefs = preferencesOf(userId);
        List<Dish> all = catalog.all();
        List<Dish> byFilter = all.stream().filter(criteria::matches).toList();
        List<Dish> result = new ArrayList<>(DishPreferenceMatcher.apply(byFilter, prefs));

        if (!criteria.isActive() && result.isEmpty()) {
            List<Dish> safe = DishPreferenceMatcher.allergenFree(all, prefs);
            result = new ArrayList<>(safe.isEmpty() ? all : safe);
        }
        Collections.shuffle(result, ThreadLocalRandom.current());

        int total = result.size();
        int max = limit != null && limit > 0 ? limit : (criteria.isActive() ? Integer.MAX_VALUE : DEFAULT_CARD_LIMIT);
        if (result.size() > max) {
            result = result.subList(0, max);
        }
        return new SuggestionResult(criteria.isActive(), total, toDtos(result, userId));
    }

    /** Danh sách món phù hợp hồ sơ (không phụ thuộc bộ lọc) – dùng cho chatbot. */
    public List<Dish> poolFor(PreferencesDto prefs) {
        List<Dish> all = catalog.all();
        List<Dish> filtered = DishPreferenceMatcher.apply(all, prefs);
        return filtered.isEmpty() ? all : filtered;
    }

    // ---------------------------------------------------------- Tìm kiếm
    /** Tìm không dấu ("bun cha" ra "Bún chả"); mọi từ trong câu tìm đều phải có trong tên món. */
    public List<DishDto> search(String query, String category, DishCriteria criteria, Optional<Long> userId) {
        List<String> words = new ArrayList<>();
        for (String w : TextUtils.normalize(query).split(" ")) {
            if (!w.isEmpty()) {
                words.add(w);
            }
        }
        String cat = category == null || category.isBlank() ? "Tất cả" : category.trim();
        String normalizedCategory = TextUtils.normalize(cat);

        List<Dish> result = new ArrayList<>();
        for (Dish dish : catalog.all()) {
            String title = dish.getNormalizedTitle();
            boolean matchesQuery = words.stream().allMatch(title::contains);
            if (!matchesQuery || !criteria.matches(dish)) {
                continue;
            }
            boolean matchesCategory;
            if ("Tất cả".equals(cat)) {
                matchesCategory = true;
            } else if (MEAL_CATEGORIES.contains(cat)) {
                matchesCategory = cat.equals(dish.getCategory());
            } else if ("Mì".equals(cat)) {
                // "Mì" không được khớp nhầm "Bánh mì"
                matchesCategory = TextUtils.hasPhrase(title, "mi") && !TextUtils.hasPhrase(title, "banh mi");
            } else {
                matchesCategory = TextUtils.hasPhrase(title, normalizedCategory);
            }
            if (matchesCategory) {
                result.add(dish);
            }
        }
        return toDtos(result, userId);
    }

    public List<DishDto> featured(Optional<Long> userId) {
        List<Dish> sorted = new ArrayList<>(catalog.all());
        sorted.sort(Comparator.comparing(Dish::isSpecialOfTheWeek).reversed()
                .thenComparing(Comparator.comparingInt(Dish::getLikesCount).reversed()));
        return toDtos(sorted.subList(0, Math.min(5, sorted.size())), userId);
    }

    public DishDto get(long id, Optional<Long> userId) {
        Dish dish = require(id);
        return toDtos(List.of(dish), userId).get(0);
    }

    // ------------------------------------------------ Yêu thích / Lưu món
    public List<DishDto> list(Kind kind, long userId) {
        List<Dish> dishes = new ArrayList<>();
        for (Long id : userDishes.findDishIds(kind, userId)) {
            catalog.find(id).ifPresent(dishes::add);
        }
        return toDtos(dishes, Optional.of(userId));
    }

    public List<String> ids(Kind kind, long userId) {
        return userDishes.findDishIds(kind, userId).stream().map(String::valueOf).toList();
    }

    public record LikeResult(String dishId, boolean liked, int likesCount) {
    }

    @Transactional
    public LikeResult setLiked(long userId, long dishId, boolean liked) {
        Dish dish = require(dishId);
        boolean changed = liked ? userDishes.add(Kind.LIKE, userId, dishId) : userDishes.remove(Kind.LIKE, userId, dishId);
        if (changed) {
            dish.setLikesCount(dishRepository.addLikes(dishId, liked ? 1 : -1));
        }
        return new LikeResult(String.valueOf(dishId), liked, dish.getLikesCount());
    }

    public record BookmarkResult(String dishId, boolean bookmarked) {
    }

    public BookmarkResult setBookmarked(long userId, long dishId, boolean bookmarked) {
        require(dishId);
        if (bookmarked) {
            userDishes.add(Kind.BOOKMARK, userId, dishId);
        } else {
            userDishes.remove(Kind.BOOKMARK, userId, dishId);
        }
        return new BookmarkResult(String.valueOf(dishId), bookmarked);
    }

    // ------------------------------------------------------------ Tiện ích
    public Dish require(long id) {
        return catalog.find(id).orElseThrow(() -> ApiException.notFound("Không tìm thấy món ăn #" + id));
    }

    public List<DishDto> toDtos(List<Dish> dishes, Optional<Long> userId) {
        Set<Long> liked = userId.map(id -> userDishes.findDishIdSet(Kind.LIKE, id)).orElse(Set.of());
        List<DishDto> out = new ArrayList<>(dishes.size());
        for (Dish d : dishes) {
            out.add(DishDto.of(d, liked.contains(d.getId())));
        }
        return out;
    }
}
