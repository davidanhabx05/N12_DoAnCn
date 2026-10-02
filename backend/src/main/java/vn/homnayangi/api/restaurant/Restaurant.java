package vn.homnayangi.api.restaurant;

/** Một dòng bảng restaurants. openMinute/closeMinute: phút trong ngày (1440 = 24:00). */
public record Restaurant(
        long id,
        String name,
        String address,
        double rating,
        String imageUrl,
        String category,
        double latitude,
        double longitude,
        int openMinute,
        int closeMinute) {
}
