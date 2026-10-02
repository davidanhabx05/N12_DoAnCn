package vn.homnayangi.api.chat;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.time.Year;
import java.util.List;

import org.junit.jupiter.api.Test;

import vn.homnayangi.api.common.TextUtils;
import vn.homnayangi.api.dish.Dish;
import vn.homnayangi.api.dish.DishPreferenceMatcher;
import vn.homnayangi.api.dish.MainDishes;
import vn.homnayangi.api.user.HealthCalculator;
import vn.homnayangi.api.user.PreferencesDto;

/** Kiểm thử logic nghiệp vụ (không cần database). Chạy: ./mvnw test */
class LogicTest {

    private static Dish dish(long id, String title, String description, String category) {
        return new Dish(id, title, description, "", 400, 20, "Dễ", category, 0, false, "Miền bắc", "Mưa", "Buồn", 35000);
    }

    private static PreferencesDto prefs(List<String> allergies, List<String> restrictions) {
        return new PreferencesDto(null, null, null, null, null, null, null, null, allergies, null, null, restrictions,
                null, null, null, null, null, null).withDefaults();
    }

    private final Dish pho = dish(1, "Phở bò", "Nước dùng thịt bò", "Bữa sáng");
    private final Dish tofu = dish(2, "Đậu hũ sốt cà chua", "Món chay thanh đạm", "Healthy");
    private final Dish crab = dish(3, "Bún riêu cua", "Riêu cua đồng", "Bữa trưa");

    @Test
    void normalizeRemovesVietnameseAccents() {
        assertEquals("pho bo ha noi", TextUtils.normalize("Phở Bò  Hà Nội"));
        assertEquals("bun dau mam tom", TextUtils.normalize("Bún Đậu Mắm Tôm"));
    }

    @Test
    void parseBudget() {
        assertEquals(50000, TextUtils.parseBudget("ăn gì tầm 50k"));
        assertEquals(50000, TextUtils.parseBudget("khoảng 30-50k thôi"));
        assertEquals(1000000, TextUtils.parseBudget("có 1 triệu"));
        assertEquals(40000, TextUtils.parseBudget("ngân sách 40"));
        assertNull(TextUtils.parseBudget("gợi ý món cho 2 người"));
        assertEquals("1.250.000", TextUtils.formatVnd(1250000));
    }

    @Test
    void seafoodAllergyRemovesCrabButNotTomato() {
        List<Dish> result = DishPreferenceMatcher.apply(List.of(pho, tofu, crab), prefs(List.of("Hải sản"), null));
        assertFalse(result.contains(crab));
        assertTrue(result.contains(tofu)); // "cà chua" không bị nhầm là "cá"
    }

    @Test
    void vegetarianKeepsOnlyVegetarianDishes() {
        List<Dish> result = DishPreferenceMatcher.apply(List.of(pho, tofu, crab),
                prefs(null, List.of("Ăn chay (Vegetarian)")));
        assertEquals(List.of(tofu), result);
    }

    @Test
    void chatUnderstandsMoodWeatherAndBudget() {
        ChatCriteria c = ChatAnalyzer.extractCriteria("Trời mưa, mình buồn, có 50k thì ăn gì?");
        assertEquals("Mưa", c.weather);
        assertEquals("Buồn", c.mood);
        assertEquals(50000, c.budget);
        assertTrue(ChatAnalyzer.wantsSuggestions("đói quá"));
        assertEquals("Bún chả", MainDishes.detect("Bún chả ở đâu ngon?"));
        assertSame(crab, ChatAnalyzer.findMentionedDish("Bún riêu ở đâu ngon", List.of(pho), List.of(pho, tofu, crab)));
    }

    @Test
    void healthIndicators() {
        Double bmi = HealthCalculator.bmi(65.0, 170.0);
        assertEquals(22.49, bmi, 0.01);
        assertEquals("Cân đối", HealthCalculator.bmiCategory(bmi));
        assertEquals(1911, HealthCalculator.tdee(65.0, 170.0, Year.now().getValue() - 25, "Nam", "Ít vận động"));
    }
}
