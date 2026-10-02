package vn.homnayangi.api.dish;

import java.util.concurrent.atomic.AtomicInteger;

import vn.homnayangi.api.common.TextUtils;

/** Một món ăn (bảng dishes), giữ trong bộ nhớ đệm DishCatalog. */
public class Dish {

    private final long id;
    private final String title;
    private final String description;
    private final String imageUrl;
    private final int calories;
    private final int prepTimeMinutes;
    private final String difficulty;
    private final String category;
    private final AtomicInteger likesCount;
    private final boolean specialOfTheWeek;
    private final String region;
    private final String weather;
    private final String mood;
    private final int price;
    /** Tên đã bỏ dấu, tính sẵn để tìm kiếm nhanh. */
    private final String normalizedTitle;

    public Dish(long id, String title, String description, String imageUrl, int calories, int prepTimeMinutes,
                String difficulty, String category, int likesCount, boolean specialOfTheWeek, String region,
                String weather, String mood, int price) {
        this.id = id;
        this.title = title;
        this.description = description == null ? "" : description;
        this.imageUrl = imageUrl == null ? "" : imageUrl;
        this.calories = calories;
        this.prepTimeMinutes = prepTimeMinutes;
        this.difficulty = difficulty;
        this.category = category;
        this.likesCount = new AtomicInteger(likesCount);
        this.specialOfTheWeek = specialOfTheWeek;
        this.region = region;
        this.weather = weather;
        this.mood = mood;
        this.price = price;
        this.normalizedTitle = TextUtils.normalize(title);
    }

    public long getId() { return id; }
    public String getTitle() { return title; }
    public String getDescription() { return description; }
    public String getImageUrl() { return imageUrl; }
    public int getCalories() { return calories; }
    public int getPrepTimeMinutes() { return prepTimeMinutes; }
    public String getDifficulty() { return difficulty; }
    public String getCategory() { return category; }
    public int getLikesCount() { return likesCount.get(); }
    public void setLikesCount(int value) { likesCount.set(Math.max(0, value)); }
    public boolean isSpecialOfTheWeek() { return specialOfTheWeek; }
    public String getRegion() { return region; }
    public String getWeather() { return weather; }
    public String getMood() { return mood; }
    public int getPrice() { return price; }
    public String getNormalizedTitle() { return normalizedTitle; }
}
