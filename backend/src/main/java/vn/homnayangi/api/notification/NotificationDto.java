package vn.homnayangi.api.notification;

import java.time.OffsetDateTime;

import com.fasterxml.jackson.annotation.JsonProperty;

/** type: promo | personal | update; icon: tên Material icon (celebration, restaurant, local_offer...). */
public record NotificationDto(
        String id,
        String title,
        String message,
        OffsetDateTime timestamp,
        @JsonProperty("isRead") boolean isRead,
        String type,
        String icon,
        String imageUrl) {
}
