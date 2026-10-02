package vn.homnayangi.api.chat;

import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.ThreadLocalRandom;
import java.util.function.Predicate;
import java.util.regex.Pattern;

import vn.homnayangi.api.common.TextUtils;
import vn.homnayangi.api.dish.Dish;
import vn.homnayangi.api.dish.DishPreferenceMatcher;
import vn.homnayangi.api.dish.MainDishes;
import vn.homnayangi.api.restaurant.RestaurantService;
import vn.homnayangi.api.user.PreferencesDto;

/**
 * "Bộ não" offline của chatbot: hiểu câu nói (tâm trạng, thời tiết, vùng miền, bữa, ngân sách...),
 * chọn món phù hợp và tự trả lời khi không gọi được Gemini.
 */
public final class ChatAnalyzer {

    private static final Map<String, List<String>> MOOD_CUES = new LinkedHashMap<>();

    static {
        MOOD_CUES.put("Buồn", List.of("buon", "tuot mood", "co don", "that tinh", "khoc", "sad"));
        MOOD_CUES.put("Bực bội", List.of("buc boi", "buc minh", "buc qua", "cau kinh", "cau gat", "tuc gian", "uc che",
                "stress", "cang thang", "ap luc", "angry"));
        MOOD_CUES.put("Chán nản", List.of("chan nan", "chan qua", "chan an", "chan doi", "chan ghe", "nhat nheo",
                "ue oai", "met moi", "lam bieng", "bored"));
        MOOD_CUES.put("Phấn khích", List.of("phan khich", "hao hung", "an mung", "ky niem", "an tiec", "excited"));
        MOOD_CUES.put("Vui vẻ", List.of("vui", "hanh phuc", "yeu doi", "happy"));
    }

    private static final List<String> SUGGESTION_CUES = List.of("goi y", "an gi", "doi bung", "dang doi", "mon nao",
            "nen an", "thu mon", "de xuat", "recommend", "suggest", "hungry", "what to eat");
    private static final List<String> INTENT_CUES = List.of("quan", "o dau", "nha hang", "cho nao", "dia chi",
            "gan day", "gia", "bao nhieu", "muon an", "them");
    private static final Pattern VEGETARIAN = Pattern.compile("(^|\\s)chay(\\s|$|[,.!?])");
    private static final DateTimeFormatter TIME_FORMAT =
            DateTimeFormatter.ofPattern("EEEE, dd/MM/yyyy HH:mm", Locale.forLanguageTag("vi"));

    private ChatAnalyzer() {
    }

    // ======================================================= Phân tích câu
    static boolean wantsSuggestions(String text) {
        if (text.toLowerCase(Locale.ROOT).contains("đói")) {
            return true;
        }
        String t = TextUtils.normalize(text);
        return SUGGESTION_CUES.stream().anyMatch(t::contains);
    }

    static ChatCriteria extractCriteria(String text) {
        String t = TextUtils.normalize(text);
        ChatCriteria c = new ChatCriteria();

        for (Map.Entry<String, List<String>> e : MOOD_CUES.entrySet()) {
            if (e.getValue().stream().anyMatch(k -> TextUtils.hasPhrase(t, k))) {
                c.mood = e.getKey();
                break;
            }
        }

        // Thời tiết: kiểm tra trên chữ CÓ dấu vì bỏ dấu sẽ nhầm "mưa" với "mua", "nắng" với "nặng"...
        String raw = text.toLowerCase(Locale.ROOT);
        if (raw.contains("mưa") || t.contains("troi mua")) {
            c.weather = "Mưa";
        } else if (raw.contains("se lạnh") || t.contains("se lanh")) {
            c.weather = "Se lạnh";
        } else if (raw.contains("lạnh") || raw.contains("rét") || t.contains("troi lanh")) {
            c.weather = "Lạnh";
        } else if (raw.contains("nóng") || raw.contains("nắng") || raw.contains("oi bức") || t.contains("troi nong")
                || t.contains("troi nang")) {
            c.weather = "Nắng";
        } else if (raw.contains("mát") || t.contains("troi mat")) {
            c.weather = "Mát mẻ";
        }

        if (t.contains("mien bac") || t.contains("bac bo")) {
            c.region = "Miền bắc";
        } else if (t.contains("mien trung") || TextUtils.hasPhrase(t, "hue") || t.contains("da nang")
                || t.contains("quang nam")) {
            c.region = "Miền trung";
        } else if (t.contains("mien nam") || t.contains("sai gon") || t.contains("mien tay")) {
            c.region = "Miền nam";
        }

        if (t.contains("bua sang") || t.contains("an sang")) {
            c.category = "Bữa sáng";
        } else if (t.contains("bua trua") || t.contains("an trua")) {
            c.category = "Bữa trưa";
        } else if (t.contains("bua toi") || t.contains("an toi")) {
            c.category = "Bữa tối";
        } else if (t.contains("an vat") || t.contains("an nhe")) {
            c.category = "Ăn nhẹ";
        }

        if (t.contains("healthy") || t.contains("giam can") || t.contains("it calo") || t.contains("eat clean")) {
            c.light = true;
        }
        // "chay" có dấu khác "chạy" nên kiểm tra trên chữ gốc
        if (VEGETARIAN.matcher(raw).find()) {
            c.vegetarian = true;
        }
        c.budget = TextUtils.parseBudget(text);
        c.mainDish = MainDishes.detect(text);
        return c;
    }

    /** Món người dùng đang hỏi tới (gõ đúng tên món, hoặc tên món chính kèm ý định tìm quán). */
    static Dish findMentionedDish(String text, List<Dish> pool, List<Dish> allDishes) {
        String t = TextUtils.normalize(text);
        for (Dish dish : pool) {
            String title = dish.getNormalizedTitle();
            if (title.length() >= 4 && t.contains(title)) {
                return dish;
            }
        }
        String mainName = MainDishes.detect(text);
        if (mainName == null || INTENT_CUES.stream().noneMatch(t::contains)) {
            return null;
        }
        String n = TextUtils.normalize(mainName);
        return allDishes.stream()
                .filter(d -> d.getNormalizedTitle().startsWith(n))
                .min(Comparator.comparingInt(d -> d.getTitle().length()))
                .orElse(null);
    }

    /** Chọn 3 món phù hợp nhất, nới dần điều kiện nếu thiếu. */
    static List<Dish> suggestDishes(ChatCriteria c, List<Dish> pool, Dish exclude) {
        if (pool.isEmpty()) {
            return List.of();
        }
        PreferencesDto vegetarianProfile = new PreferencesDto("Chay trứng/sữa", null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null, null, null).withDefaults();
        String mainNormalized = c.mainDish == null ? null : TextUtils.normalize(c.mainDish);

        Predicate<Dish> budgetOk = d -> c.budget == null || d.getPrice() <= c.budget;
        Predicate<Dish> lightOk = d -> !c.light || "Healthy".equals(d.getCategory()) || d.getCalories() <= 400;
        Predicate<Dish> vegOk = d -> !c.vegetarian || DishPreferenceMatcher.matchesStrict(d, vegetarianProfile);
        Predicate<Dish> mainOk = d -> mainNormalized == null || d.getNormalizedTitle().startsWith(mainNormalized);
        Predicate<Dish> base = budgetOk.and(lightOk).and(vegOk);

        List<Predicate<Dish>> levels = List.of(
                mainOk.and(base).and(d -> (c.mood == null || c.mood.equals(d.getMood()))
                        && (c.weather == null || c.weather.equals(d.getWeather()))
                        && (c.region == null || c.region.equals(d.getRegion()))
                        && (c.category == null || c.category.equals(d.getCategory()))),
                mainOk.and(base).and(d -> (c.weather == null || c.weather.equals(d.getWeather()))
                        && (c.region == null || c.region.equals(d.getRegion()))),
                mainOk.and(base),
                budgetOk.and(vegOk));

        for (Predicate<Dish> level : levels) {
            List<Dish> matches = new ArrayList<>();
            for (Dish d : pool) {
                if ((exclude == null || d.getId() != exclude.getId()) && level.test(d)) {
                    matches.add(d);
                }
            }
            if (!matches.isEmpty()) {
                Collections.shuffle(matches, ThreadLocalRandom.current());
                return matches.subList(0, Math.min(3, matches.size()));
            }
        }
        List<Dish> fallback = new ArrayList<>(pool);
        Collections.shuffle(fallback, ThreadLocalRandom.current());
        return fallback.subList(0, Math.min(3, fallback.size()));
    }

    /** Giá tham khảo tại quán = cột price của món (giống màn Chi tiết món bên app). */
    static int referencePrice(Dish dish) {
        return dish.getPrice();
    }

    // ================================================================ Gemini
    static final String SYSTEM_INSTRUCTION =
            "Bạn là 'Trợ lý AI Ẩm thực' của ứng dụng 'Hôm Nay Ăn Gì'. "
                    + "Nhiệm vụ: tư vấn món ăn ngoài và gợi ý quán ăn ở Hà Nội dựa trên tâm trạng, thời tiết & ngân sách. "
                    + "QUY TẮC BẮT BUỘC: CHỈ gợi ý món ăn ngoài và chỉ đường đến quán ăn. KHÔNG hướng dẫn nấu ăn hay cung cấp công thức chế biến. "
                    + "Nếu người dùng gửi ảnh món ăn, hãy nhận diện tên món và gợi ý quán bán món đó. "
                    + "Luôn trả lời bằng tiếng Việt, thân thiện, đồng cảm, ngắn gọn (tối đa khoảng 120 từ), không dùng markdown phức tạp.";

    static String buildPrompt(String text, Dish foundDish, List<Dish> suggestions, boolean wantsSuggestions,
                              PreferencesDto prefs, List<String> restaurantNames) {
        StringBuilder sb = new StringBuilder();
        sb.append("THỜI GIAN HIỆN TẠI: ").append(ZonedDateTime.now(RestaurantService.VIETNAM).format(TIME_FORMAT)).append('\n');
        sb.append("DỮ LIỆU ỨNG DỤNG CUNG CẤP:\n");
        if (foundDish != null) {
            sb.append("- Món người dùng hỏi: '").append(foundDish.getTitle()).append("'\n");
            sb.append("  Giá trung bình tại quán: ").append(TextUtils.formatVnd(referencePrice(foundDish)))
                    .append(" VNĐ, ").append(foundDish.getCalories()).append(" kcal, danh mục ")
                    .append(foundDish.getCategory()).append('\n');
        }
        if (wantsSuggestions && !suggestions.isEmpty()) {
            sb.append("- Các món trong app phù hợp nhất (hãy ưu tiên gợi ý đúng các món này):\n");
            for (Dish d : suggestions) {
                sb.append("  • ").append(d.getTitle()).append(" – ~").append(TextUtils.formatVnd(d.getPrice()))
                        .append("đ, ").append(d.getCalories()).append(" kcal, ")
                        .append(d.getRegion() == null ? "" : d.getRegion())
                        .append(", hợp trời ").append(d.getWeather() == null ? "" : d.getWeather()).append('\n');
            }
        }
        String t = TextUtils.normalize(text);
        if (t.contains("loc") || t.contains("tim kiem")) {
            sb.append("- Ứng dụng có bộ lọc: Vùng miền (Miền bắc, Miền trung, Miền nam), Thời tiết (Nắng, Mưa, Mát mẻ, "
                    + "Se lạnh, Lạnh), Tâm trạng (Vui vẻ, Buồn, Bực bội, Phấn khích, Chán nản), Thời gian chuẩn bị.\n");
        }
        if ((t.contains("quan") || t.contains("nha hang") || t.contains("o dau")) && !restaurantNames.isEmpty()) {
            sb.append("- Một số quán trong app: ")
                    .append(String.join(", ", restaurantNames.subList(0, Math.min(8, restaurantNames.size()))))
                    .append(".\n");
        }
        if (prefs != null) {
            sb.append("- Hồ sơ người dùng: chế độ ăn ").append(prefs.dietType())
                    .append(", ngân sách ").append(prefs.budgetLevel())
                    .append(", độ cay ").append(prefs.spiciness());
            if (!prefs.safeAllergies().isEmpty()) {
                sb.append(", DỊ ỨNG: ").append(String.join(", ", prefs.safeAllergies()))
                        .append(" (tuyệt đối không gợi ý món chứa các thành phần này)");
            }
            if (!prefs.safeDislikedIngredients().isEmpty()) {
                sb.append(", không thích: ").append(String.join(", ", prefs.safeDislikedIngredients()));
            }
            sb.append(".\n");
        }
        sb.append("\nNgười dùng: ").append(text);
        return sb.toString();
    }

    // ====================================================== Trả lời offline
    static String localReply(String text, ChatCriteria c, Dish foundDish, List<Dish> suggestions,
                             boolean wantsSuggestions, List<String> restaurantNames) {
        String t = TextUtils.normalize(text);

        if (foundDish != null) {
            int price = referencePrice(foundDish);
            return foundDish.getTitle() + " là lựa chọn tuyệt vời! Giá tham khảo tại quán khoảng "
                    + Math.round(price / 1000.0) + "k, "
                    + "khoảng " + foundDish.getCalories() + " kcal. Nhấn \"Tìm quán bán món này\" để xem các quán gần bạn và chỉ đường nhé!";
        }

        if (wantsSuggestions && !suggestions.isEmpty()) {
            List<String> reasons = new ArrayList<>();
            if (c.mood != null) reasons.add("tâm trạng " + c.mood.toLowerCase(Locale.ROOT));
            if (c.weather != null) reasons.add("trời " + c.weather.toLowerCase(Locale.ROOT));
            if (c.budget != null) reasons.add("ngân sách " + TextUtils.formatVnd(c.budget) + "đ");
            if (c.region != null) reasons.add("món " + c.region.toLowerCase(Locale.ROOT));
            if (c.category != null) reasons.add(c.category.toLowerCase(Locale.ROOT));
            if (c.vegetarian) reasons.add("ăn chay");
            if (c.light) reasons.add("ăn nhẹ nhàng, healthy");

            String intro = reasons.isEmpty() ? "Hôm nay bạn thử một trong mấy món này nhé"
                    : "Với " + String.join(", ", reasons) + ", mình gợi ý";
            String comfort = "Buồn".equals(c.mood) || "Chán nản".equals(c.mood)
                    ? " Một bữa ngon sẽ giúp bạn thấy khá hơn đó!"
                    : ("Bực bội".equals(c.mood) ? " Ăn gì đó ngon để hạ hỏa nào!" : "");
            StringBuilder list = new StringBuilder();
            for (Dish d : suggestions) {
                if (list.length() > 0) list.append('\n');
                list.append("• ").append(d.getTitle()).append(" (~").append(Math.round(d.getPrice() / 1000.0)).append("k)");
            }
            return intro + ":\n" + list + "\n\nNhấn vào món để tìm quán gần bạn." + comfort;
        }

        if (t.contains("chao") || TextUtils.hasPhrase(t, "hi") || t.contains("hello")) {
            return "Xin chào! Hôm nay bạn thấy thế nào? Kể mình nghe tâm trạng, thời tiết hoặc ngân sách, mình sẽ gợi ý món ngon và quán gần bạn nhé!";
        }
        if (t.contains("cam on") || t.contains("thank")) {
            return "Rất vui được hỗ trợ bạn! Chúc bạn có một bữa ăn ngon miệng nhé.";
        }
        if (t.contains("nau") || t.contains("cong thuc")) {
            return "Mình chuyên gợi ý món ăn ngoài và quán ngon nên không hướng dẫn nấu ăn được. Bạn cho mình biết muốn ăn gì, mình tìm quán gần bạn nhé!";
        }
        if (t.contains("quan") || t.contains("nha hang")) {
            List<String> names = restaurantNames.subList(0, Math.min(4, restaurantNames.size()));
            return names.isEmpty()
                    ? "Bạn vào mục \"Gợi ý quán\" để xem các quán gần bạn nhé!"
                    : "Một vài quán trong app: " + String.join(", ", names)
                            + ". Bạn muốn ăn món gì để mình lọc quán phù hợp?";
        }
        return "Mình chưa hiểu rõ lắm. Bạn thử nói \"Trời mưa, mình buồn, có 50k thì ăn gì?\" hoặc \"Bún chả ở đâu ngon?\" nhé!";
    }
}
