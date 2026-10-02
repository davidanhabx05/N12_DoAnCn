package vn.homnayangi.api.restaurant;

import com.fasterxml.jackson.annotation.JsonProperty;

/** Quán ăn trả về cho app (khớp model Restaurant bên Flutter). */
public record RestaurantDto(
        String id,
        String name,
        String address,
        /** Điểm đánh giá; 0 = chưa có (quán lấy từ OpenStreetMap không có điểm). */
        double rating,
        String imageUrl,
        String category,
        String distance,
        @JsonProperty("isOpen") boolean isOpen,
        double latitude,
        double longitude,
        /** Chuỗi dùng để mở Google Maps chính xác nhất. */
        String mapsQuery,
        /** place_id của Google (nếu quán lấy từ Google Places). */
        String placeId,
        /** false = nguồn dữ liệu không cho biết giờ mở cửa (khi đó isOpen không có ý nghĩa). */
        boolean openKnown) {
}
