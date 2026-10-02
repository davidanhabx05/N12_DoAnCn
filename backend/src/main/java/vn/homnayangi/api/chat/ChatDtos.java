package vn.homnayangi.api.chat;

import java.time.OffsetDateTime;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonProperty;

import vn.homnayangi.api.dish.DishDto;

/** Các đối tượng dữ liệu của chatbot. */
public final class ChatDtos {

    private ChatDtos() {
    }

    /** imageBase64: ảnh gửi kèm (không có tiền tố data:), tối đa ~5MB. */
    public record SendMessageRequest(String sessionId, String text, String imageBase64, String imageMimeType) {
    }

    /** type: text | recipeList | restaurantSuggestion (khớp ChatMessageType bên app). */
    public record MessageDto(
            String id,
            @JsonProperty("isUser") boolean isUser,
            String text,
            String type,
            List<DishDto> dishes,
            DishDto recipeDish,
            boolean hadImage,
            OffsetDateTime createdAt) {
    }

    public record SendMessageResponse(String sessionId, String title, MessageDto userMessage, MessageDto reply) {
    }

    public record SessionSummary(String id, String title, OffsetDateTime createdAt, OffsetDateTime updatedAt) {
    }

    public record SessionDetail(String id, String title, OffsetDateTime createdAt, List<MessageDto> messages) {
    }
}
