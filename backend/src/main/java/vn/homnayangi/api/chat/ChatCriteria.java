package vn.homnayangi.api.chat;

/** Tiêu chí rút ra từ câu nói của người dùng. */
public class ChatCriteria {
    String mood;
    String weather;
    String region;
    String category;
    Integer budget;
    boolean vegetarian;
    boolean light;
    String mainDish;

    boolean isEmpty() {
        return mood == null && weather == null && region == null && category == null && budget == null
                && !vegetarian && !light && mainDish == null;
    }
}
