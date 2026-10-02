package vn.homnayangi.api.user;

import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class PreferencesRepository {

    private final JdbcTemplate jdbc;

    public PreferencesRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public PreferencesDto findByUserId(long userId) {
        List<PreferencesDto> rows = jdbc.query(
                "SELECT * FROM user_preferences WHERE user_id = ?",
                (rs, i) -> new PreferencesDto(
                        rs.getString("diet_type"),
                        UserRepository.fromArray(rs.getArray("favorite_flavors")),
                        rs.getString("budget_level"),
                        UserRepository.fromArray(rs.getArray("disliked_ingredients")),
                        rs.getString("cooking_level"),
                        rs.getString("kitchen_preference"),
                        rs.getInt("default_eaters"),
                        UserRepository.fromArray(rs.getArray("meal_times")),
                        UserRepository.fromArray(rs.getArray("allergies")),
                        UserRepository.fromArray(rs.getArray("cuisines")),
                        rs.getString("spiciness"),
                        UserRepository.fromArray(rs.getArray("dietary_restrictions")),
                        (Double) rs.getObject("height"),
                        (Double) rs.getObject("weight"),
                        rs.getString("gender"),
                        (Integer) rs.getObject("birth_year"),
                        rs.getString("activity_level"),
                        (Integer) rs.getObject("calorie_goal")),
                userId);
        return rows.isEmpty() ? PreferencesDto.defaults() : rows.get(0);
    }

    public void save(long userId, PreferencesDto input) {
        PreferencesDto p = input.withDefaults();
        jdbc.update("""
                INSERT INTO user_preferences (user_id, diet_type, favorite_flavors, budget_level, disliked_ingredients,
                    cooking_level, kitchen_preference, default_eaters, meal_times, allergies, cuisines, spiciness,
                    dietary_restrictions, height, weight, gender, birth_year, activity_level, calorie_goal, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
                ON CONFLICT (user_id) DO UPDATE SET
                    diet_type = EXCLUDED.diet_type,
                    favorite_flavors = EXCLUDED.favorite_flavors,
                    budget_level = EXCLUDED.budget_level,
                    disliked_ingredients = EXCLUDED.disliked_ingredients,
                    cooking_level = EXCLUDED.cooking_level,
                    kitchen_preference = EXCLUDED.kitchen_preference,
                    default_eaters = EXCLUDED.default_eaters,
                    meal_times = EXCLUDED.meal_times,
                    allergies = EXCLUDED.allergies,
                    cuisines = EXCLUDED.cuisines,
                    spiciness = EXCLUDED.spiciness,
                    dietary_restrictions = EXCLUDED.dietary_restrictions,
                    height = EXCLUDED.height,
                    weight = EXCLUDED.weight,
                    gender = EXCLUDED.gender,
                    birth_year = EXCLUDED.birth_year,
                    activity_level = EXCLUDED.activity_level,
                    calorie_goal = EXCLUDED.calorie_goal,
                    updated_at = NOW()
                """,
                userId, p.dietType(), UserRepository.toArray(p.favoriteFlavors()), p.budgetLevel(),
                UserRepository.toArray(p.dislikedIngredients()), p.cookingLevel(), p.kitchenPreference(),
                p.defaultEaters(), UserRepository.toArray(p.mealTimes()), UserRepository.toArray(p.allergies()),
                UserRepository.toArray(p.cuisines()), p.spiciness(), UserRepository.toArray(p.dietaryRestrictions()),
                p.height(), p.weight(), p.gender(), p.birthYear(), p.activityLevel(), p.calorieGoal());
    }
}
