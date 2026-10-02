package vn.homnayangi.api.filter;

/** Bộ lọc đã lưu (trường khớp với SavedFilter bên Flutter). */
public record SavedFilterDto(
        String id,
        String name,
        String time,
        Double maxTime,
        String region,
        String weather,
        String mood) {
}
