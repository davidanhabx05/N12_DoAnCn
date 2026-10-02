package vn.homnayangi.api.user;

import java.util.List;

/**
 * Hồ sơ ăn uống + sức khoẻ. Tên trường trùng với UserPreferences.toMap() bên Flutter.
 */
public record PreferencesDto(
        String dietType,
        List<String> favoriteFlavors,
        String budgetLevel,
        List<String> dislikedIngredients,
        String cookingLevel,
        String kitchenPreference,
        Integer defaultEaters,
        List<String> mealTimes,
        List<String> allergies,
        List<String> cuisines,
        String spiciness,
        List<String> dietaryRestrictions,
        Double height,
        Double weight,
        String gender,
        Integer birthYear,
        String activityLevel,
        Integer calorieGoal) {

    public static PreferencesDto defaults() {
        return new PreferencesDto("Bình thường", List.of(), "Vừa", List.of(), "Dễ nấu", "Tự nấu", 2,
                List.of("Bữa trưa", "Bữa tối"), List.of(), List.of("Việt Nam"), "Cay vừa", List.of(),
                null, null, null, null, null, null);
    }

    /** Điền giá trị mặc định cho các trường app không gửi lên. */
    public PreferencesDto withDefaults() {
        PreferencesDto d = defaults();
        return new PreferencesDto(
                or(dietType, d.dietType), or(favoriteFlavors, d.favoriteFlavors), or(budgetLevel, d.budgetLevel),
                or(dislikedIngredients, d.dislikedIngredients), or(cookingLevel, d.cookingLevel),
                or(kitchenPreference, d.kitchenPreference), or(defaultEaters, d.defaultEaters),
                or(mealTimes, d.mealTimes), or(allergies, d.allergies), or(cuisines, d.cuisines),
                or(spiciness, d.spiciness), or(dietaryRestrictions, d.dietaryRestrictions),
                height, weight, gender, birthYear, activityLevel, calorieGoal);
    }

    public List<String> safeAllergies() {
        return allergies == null ? List.of() : allergies;
    }

    public List<String> safeDietaryRestrictions() {
        return dietaryRestrictions == null ? List.of() : dietaryRestrictions;
    }

    public List<String> safeDislikedIngredients() {
        return dislikedIngredients == null ? List.of() : dislikedIngredients;
    }

    private static <T> T or(T value, T fallback) {
        return value != null ? value : fallback;
    }
}
