package vn.homnayangi.api.dish;

/**
 * Tiêu chí ở màn Bộ lọc: thời gian chuẩn bị, vùng miền, thời tiết, tâm trạng.
 * time: "Bất kỳ" | "≤ 15 phút" | "15–30 phút" | "30–60 phút" | "> 60 phút".
 */
public record DishCriteria(String time, Double maxTime, String region, String weather, String mood) {

    public DishCriteria {
        time = blankToNull(time) == null ? "Bất kỳ" : time.trim();
        maxTime = maxTime == null ? 180.0 : maxTime;
        region = blankToNull(region);
        weather = blankToNull(weather);
        mood = blankToNull(mood);
    }

    public static DishCriteria none() {
        return new DishCriteria(null, null, null, null, null);
    }

    public boolean isActive() {
        return !"Bất kỳ".equals(time) || region != null || weather != null || mood != null;
    }

    public boolean matches(Dish dish) {
        int t = dish.getPrepTimeMinutes();
        boolean matchesTime = switch (time) {
            case "≤ 15 phút" -> t <= 15;
            case "15–30 phút" -> t > 15 && t <= 30;
            case "30–60 phút" -> t > 30 && t <= 60;
            case "> 60 phút" -> t > 60;
            default -> true;
        };
        return matchesTime
                && t <= maxTime
                && (region == null || region.equals(dish.getRegion()))
                && (weather == null || weather.equals(dish.getWeather()))
                && (mood == null || mood.equals(dish.getMood()));
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s;
    }
}
