package vn.homnayangi.api.dish;

import com.fasterxml.jackson.annotation.JsonProperty;

/** Món ăn trả về cho app (trường khớp với model Dish bên Flutter). */
public record DishDto(
        String id,
        String title,
        String description,
        String imageUrl,
        int calories,
        int prepTimeMinutes,
        String difficulty,
        String category,
        int likesCount,
        @JsonProperty("isLiked") boolean isLiked,
        @JsonProperty("isSpecialOfTheWeek") boolean isSpecialOfTheWeek,
        String region,
        String weather,
        String mood,
        int price) {

    public static DishDto of(Dish d, boolean liked) {
        return new DishDto(String.valueOf(d.getId()), d.getTitle(), d.getDescription(), d.getImageUrl(),
                d.getCalories(), d.getPrepTimeMinutes(), d.getDifficulty(), d.getCategory(), d.getLikesCount(),
                liked, d.isSpecialOfTheWeek(), d.getRegion(), d.getWeather(), d.getMood(), d.getPrice());
    }
}
