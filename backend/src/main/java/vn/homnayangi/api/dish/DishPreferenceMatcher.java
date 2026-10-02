package vn.homnayangi.api.dish;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import vn.homnayangi.api.common.TextUtils;
import vn.homnayangi.api.user.PreferencesDto;

/**
 * Lọc món theo hồ sơ ăn uống: dị ứng, chế độ ăn (chay, thuần chay, ít tinh bột,
 * eat clean, Địa Trung Hải), độ cay, không đường, món không thích và ngân sách.
 */
public final class DishPreferenceMatcher {

    private static final List<String> MEAT = List.of(
            "thit", "bun bo", "bo kho", "pho bo", "thit bo", "ga", "suon", "heo", "luoi heo", "hai san", "tom", "muc",
            "ca", "ca loc", "cha", "cha ca", "cha lua", "xa xiu", "cua", "oc", "so", "ghe", "bun cha", "bun rieu",
            "bun mam", "mam tom", "bi", "long", "ech", "vit", "banh da cua", "hu tieu nam vang");
    private static final List<String> ANIMAL_PRODUCTS = List.of("trung", "sua", "mat ong", "pho mai", "bo sua");
    private static final List<String> VEGETARIAN_HINTS = List.of("chay", "dau hu", "nam", "rau cu", "rau", "salad", "dau");
    private static final List<String> CARBS = List.of(
            "com", "bun", "pho", "mi", "banh mi", "banh", "xoi", "mien", "hu tieu", "chao", "cao lau", "banh canh");
    private static final List<String> FRIED_FATTY = List.of("chien", "gion", "quay", "beo", "beo ngay", "xa xiu", "mo");
    private static final List<String> SPICY = List.of("cay", "cay nong", "lau thai", "bun bo", "ot", "sa te");
    private static final List<String> SUGAR = List.of("che", "ngot", "mat ong", "caramen", "kem", "sua chua");

    /** Từ khoá dị ứng. Khoá là nhãn hiển thị ở các màn cài đặt của app. */
    public static final Map<String, List<String>> ALLERGY_KEYWORDS = Map.ofEntries(
            Map.entry("Hải sản", List.of("hai san", "tom", "muc", "cua", "oc", "so", "ghe", "ca", "cha ca", "mam tom",
                    "bun mam", "bun rieu", "canh chua", "banh da cua")),
            Map.entry("Tôm", List.of("tom", "mam tom", "hai san")),
            Map.entry("Cua", List.of("cua", "bun rieu", "banh da cua", "hai san")),
            Map.entry("Ghe", List.of("ghe", "hai san")),
            Map.entry("Sò", List.of("so", "hai san")),
            Map.entry("Ốc", List.of("oc", "hai san")),
            Map.entry("Mực", List.of("muc", "hai san")),
            Map.entry("Cá biển", List.of("hai san", "ca thu", "ca ngu", "ca hoi", "bun mam")),
            Map.entry("Cá sông", List.of("ca loc", "cha ca", "canh chua", "ca")),
            Map.entry("Trứng", List.of("trung")),
            Map.entry("Sữa", List.of("sua", "pho mai", "bo sua", "kem")),
            Map.entry("Gluten", List.of("banh mi", "mi", "mi quang", "cao lau", "bot mi", "bot", "banh bao")),
            Map.entry("Đậu", List.of("dau", "dau hu", "dau phu", "tuong")),
            Map.entry("Đậu nành", List.of("dau hu", "dau phu", "dau nanh", "tuong", "sua dau")),
            Map.entry("Đậu phộng", List.of("dau phong", "lac")),
            Map.entry("Vừng", List.of("vung", "me")),
            Map.entry("Hạnh nhân", List.of("hanh nhan")),
            Map.entry("Hạt cây", List.of("hanh nhan", "hat dieu", "oc cho", "hat de", "hat")));

    /** Nhãn ở màn "Dị ứng & Kiêng khem" -> tên chuẩn dùng chung với màn "Tùy chọn ăn uống". */
    private static final Map<String, String> ALLERGY_ALIASES = Map.of(
            "Sữa & Sản phẩm từ sữa", "Sữa",
            "Bột mì (Gluten)", "Gluten");

    private static final Map<String, List<String>> DISLIKE_KEYWORDS = Map.of(
            "Sầu riêng", List.of("sau rieng"),
            "Mắm tôm", List.of("mam tom"),
            "Rau mùi", List.of("rau mui", "ngo"));

    /** "cà chua", "cà phê"... bỏ dấu thành "ca ..." nhưng không phải cá. */
    private static final Pattern NOT_FISH_CA =
            Pattern.compile("(^|[^a-z])ca (chua|phe|rot|tim|ri|phao|muoi|cuong|pao)(?=$|[^a-z])");
    private static final Pattern ONION = Pattern.compile("(^|[^a-z])hanh(?! nhan)(?=$|[^a-z])");

    private DishPreferenceMatcher() {
    }

    public static String canonicalAllergy(String label) {
        return ALLERGY_ALIASES.getOrDefault(label, label);
    }

    static String textOf(Dish dish) {
        String text = TextUtils.normalize(dish.getTitle() + " " + dish.getDescription());
        Matcher m = NOT_FISH_CA.matcher(text);
        return m.replaceAll("$1ca$2");
    }

    private static boolean hasAny(String text, List<String> keywords) {
        for (String k : keywords) {
            if (TextUtils.hasPhrase(text, k)) {
                return true;
            }
        }
        return false;
    }

    private static boolean isVegetarianDish(Dish dish, String text) {
        if (hasAny(text, MEAT)) {
            return false;
        }
        return hasAny(text, VEGETARIAN_HINTS) || "Healthy".equals(dish.getCategory());
    }

    private static boolean wantsVegetarian(PreferencesDto p) {
        return "Chay trứng/sữa".equals(p.dietType()) || "Chay trường".equals(p.dietType())
                || p.safeDietaryRestrictions().contains("Ăn chay (Vegetarian)")
                || p.safeDietaryRestrictions().contains("Thuần chay (Vegan)");
    }

    private static boolean wantsVegan(PreferencesDto p) {
        return "Chay trường".equals(p.dietType()) || p.safeDietaryRestrictions().contains("Thuần chay (Vegan)");
    }

    private static boolean wantsLowCarb(PreferencesDto p) {
        String diet = p.dietType() == null ? "" : p.dietType();
        return "Ít tinh bột".equals(diet) || diet.startsWith("Ketogenic")
                || p.safeDietaryRestrictions().contains("Ít tinh bột (Low-carb)");
    }

    private static boolean wantsNoSpicy(PreferencesDto p) {
        return "Không cay".equals(p.spiciness()) || p.safeDietaryRestrictions().contains("Không ăn cay");
    }

    /** Món có chứa thành phần gây dị ứng cho người dùng không. */
    public static boolean containsAllergen(Dish dish, PreferencesDto prefs) {
        return containsAllergen(dish, prefs, null);
    }

    private static boolean containsAllergen(Dish dish, PreferencesDto prefs, String normalizedText) {
        if (prefs.safeAllergies().isEmpty()) {
            return false;
        }
        String text = normalizedText != null ? normalizedText : textOf(dish);
        for (String allergy : prefs.safeAllergies()) {
            List<String> keywords = ALLERGY_KEYWORDS.getOrDefault(canonicalAllergy(allergy),
                    List.of(TextUtils.normalize(allergy)));
            if (hasAny(text, keywords)) {
                return true;
            }
        }
        return false;
    }

    /** Điều kiện BẮT BUỘC: dị ứng, chế độ ăn, độ cay, món không thích. */
    public static boolean matchesStrict(Dish dish, PreferencesDto prefs) {
        String text = textOf(dish);
        if (containsAllergen(dish, prefs, text)) {
            return false;
        }
        if (wantsVegetarian(prefs)) {
            if (!isVegetarianDish(dish, text)) {
                return false;
            }
            if (wantsVegan(prefs) && hasAny(text, ANIMAL_PRODUCTS)) {
                return false;
            }
        }
        if (wantsLowCarb(prefs) && hasAny(text, CARBS)) {
            return false;
        }
        if ("Thực phẩm sạch, nguyên bản".equals(prefs.dietType())
                && (hasAny(text, FRIED_FATTY) || dish.getCalories() > 550)) {
            return false;
        }
        if ("Chế độ ăn Địa Trung Hải".equals(prefs.dietType())
                && (hasAny(text, List.of("heo quay", "xa xiu", "beo ngay", "chien")) || dish.getCalories() > 600)) {
            return false;
        }
        if (wantsNoSpicy(prefs) && hasAny(text, SPICY)) {
            return false;
        }
        if (prefs.safeDietaryRestrictions().contains("Không đường") && hasAny(text, SUGAR)) {
            return false;
        }
        for (String disliked : prefs.safeDislikedIngredients()) {
            if ("Hành".equals(disliked)) {
                // "hành" nhưng không nhầm với "hạnh nhân"
                if (ONION.matcher(text).find()) {
                    return false;
                }
                continue;
            }
            List<String> keywords = DISLIKE_KEYWORDS.getOrDefault(disliked, List.of(TextUtils.normalize(disliked)));
            if (hasAny(text, keywords)) {
                return false;
            }
        }
        return true;
    }

    /** Điều kiện MỀM: ngân sách thường dùng. */
    public static boolean matchesBudget(Dish dish, PreferencesDto prefs) {
        String level = prefs.budgetLevel() == null ? "" : prefs.budgetLevel();
        return switch (level) {
            case "Rẻ" -> dish.getPrice() <= 40000;
            case "Vừa" -> dish.getPrice() >= 30000 && dish.getPrice() <= 100000;
            case "Sang" -> dish.getPrice() >= 80000;
            default -> true;
        };
    }

    /** Lọc theo hồ sơ. Nếu ngân sách làm rỗng danh sách thì nới ngân sách (không bao giờ nới dị ứng/chế độ ăn). */
    public static List<Dish> apply(List<Dish> dishes, PreferencesDto prefs) {
        List<Dish> strict = new ArrayList<>();
        for (Dish d : dishes) {
            if (matchesStrict(d, prefs)) {
                strict.add(d);
            }
        }
        List<Dish> withBudget = new ArrayList<>();
        for (Dish d : strict) {
            if (matchesBudget(d, prefs)) {
                withBudget.add(d);
            }
        }
        return withBudget.isEmpty() ? strict : withBudget;
    }

    /** Chỉ loại món gây dị ứng – dùng khi các điều kiện khác quá chặt. */
    public static List<Dish> allergenFree(List<Dish> dishes, PreferencesDto prefs) {
        List<Dish> result = new ArrayList<>();
        for (Dish d : dishes) {
            if (!containsAllergen(d, prefs)) {
                result.add(d);
            }
        }
        return result;
    }
}
