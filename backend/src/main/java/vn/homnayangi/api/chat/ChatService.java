package vn.homnayangi.api.chat;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import vn.homnayangi.api.common.ApiException;
import vn.homnayangi.api.dish.Dish;
import vn.homnayangi.api.dish.DishCatalog;
import vn.homnayangi.api.dish.DishDto;
import vn.homnayangi.api.dish.DishService;
import vn.homnayangi.api.restaurant.RestaurantService;
import vn.homnayangi.api.user.PreferencesDto;

@Service
public class ChatService {

    private static final int CONTEXT_MESSAGES = 10;
    private static final int MAX_SESSIONS = 50;
    private static final int MAX_IMAGE_BASE64_LENGTH = 7_000_000; // ~5MB ảnh

    private final ChatRepository chats;
    private final DishService dishService;
    private final DishCatalog catalog;
    private final RestaurantService restaurants;
    private final GeminiClient gemini;

    public ChatService(ChatRepository chats, DishService dishService, DishCatalog catalog,
                       RestaurantService restaurants, GeminiClient gemini) {
        this.chats = chats;
        this.dishService = dishService;
        this.catalog = catalog;
        this.restaurants = restaurants;
        this.gemini = gemini;
    }

    public ChatDtos.SendMessageResponse send(long userId, ChatDtos.SendMessageRequest req) {
        String trimmed = req.text() == null ? "" : req.text().trim();
        String image = req.imageBase64() == null || req.imageBase64().isBlank() ? null : stripDataPrefix(req.imageBase64());
        if (trimmed.isEmpty() && image == null) {
            throw ApiException.badRequest("Tin nhắn trống");
        }
        if (image != null && image.length() > MAX_IMAGE_BASE64_LENGTH) {
            throw ApiException.badRequest("Ảnh quá lớn, vui lòng chọn ảnh nhỏ hơn 5MB");
        }
        String userText = trimmed.isEmpty() ? "Đây là món gì? Gợi ý giúp tôi quán bán món này ở Hà Nội." : trimmed;

        // 1) Cuộc trò chuyện: dùng tiếp hoặc tạo mới
        ChatRepository.SessionRow session = parseId(req.sessionId())
                .flatMap(id -> chats.findSession(userId, id))
                .orElse(null);
        List<GeminiClient.Turn> history = new ArrayList<>();
        long sessionId;
        String title;
        if (session != null) {
            sessionId = session.id();
            title = session.title();
            for (ChatRepository.MessageRow m : chats.findRecentMessages(sessionId, CONTEXT_MESSAGES)) {
                history.add(new GeminiClient.Turn(m.user(), m.content()));
            }
        } else {
            title = trimmed.isEmpty() ? "📷 Hỏi về ảnh món ăn" : (trimmed.length() > 60 ? trimmed.substring(0, 57) + "..." : trimmed);
            sessionId = chats.createSession(userId, title);
        }

        ChatRepository.MessageRow userRow = chats.insertMessage(sessionId, true, trimmed, "text", List.of(), null,
                image != null);

        // 2) Hiểu câu nói và chọn món từ dữ liệu của app
        PreferencesDto prefs = dishService.preferencesOf(Optional.of(userId));
        List<Dish> pool = dishService.poolFor(prefs);
        ChatCriteria criteria = ChatAnalyzer.extractCriteria(userText);
        Dish found = ChatAnalyzer.findMentionedDish(userText, pool, catalog.all());
        List<Dish> suggestions = ChatAnalyzer.suggestDishes(criteria, pool, found);
        boolean wantsSuggestions = ChatAnalyzer.wantsSuggestions(userText) || !criteria.isEmpty();
        List<String> restaurantNames = restaurants.topNames(8);

        // 3) Hỏi Gemini; lỗi / chưa có key -> tự trả lời bằng dữ liệu của app
        String reply = null;
        if (gemini.isConfigured()) {
            String prompt = ChatAnalyzer.buildPrompt(userText, found, suggestions, wantsSuggestions, prefs, restaurantNames);
            reply = gemini.ask(history, prompt, image, req.imageMimeType());
        }
        if (reply == null) {
            if (image != null && found == null && trimmed.isEmpty()) {
                reply = "Hiện tôi chưa kết nối được AI nhận diện hình ảnh (kiểm tra GEMINI_API_KEY ở backend và kết nối mạng). "
                        + "Bạn hãy gõ tên món trong ảnh, tôi sẽ tìm quán bán món đó gần bạn nhé!";
            } else {
                reply = ChatAnalyzer.localReply(userText, criteria, found, suggestions, wantsSuggestions, restaurantNames);
            }
        }

        String type = "text";
        List<Long> dishIds = List.of();
        Long recipeDishId = null;
        if (found != null) {
            type = "restaurantSuggestion";
            recipeDishId = found.getId();
        } else if (wantsSuggestions && !suggestions.isEmpty()) {
            type = "recipeList";
            dishIds = suggestions.stream().map(Dish::getId).toList();
        }
        ChatRepository.MessageRow botRow = chats.insertMessage(sessionId, false, reply, type, dishIds, recipeDishId, false);
        chats.touchSession(sessionId);
        chats.pruneSessions(userId, MAX_SESSIONS);

        return new ChatDtos.SendMessageResponse(String.valueOf(sessionId), title,
                toDto(userRow, userId), toDto(botRow, userId));
    }

    public List<ChatDtos.SessionSummary> sessions(long userId) {
        return chats.findSessions(userId, 20).stream()
                .map(s -> new ChatDtos.SessionSummary(String.valueOf(s.id()), s.title(), s.createdAt(), s.updatedAt()))
                .toList();
    }

    public ChatDtos.SessionDetail session(long userId, long sessionId) {
        ChatRepository.SessionRow s = chats.findSession(userId, sessionId)
                .orElseThrow(() -> ApiException.notFound("Không tìm thấy cuộc trò chuyện"));
        List<ChatDtos.MessageDto> messages = chats.findMessages(sessionId).stream()
                .map(m -> toDto(m, userId))
                .toList();
        return new ChatDtos.SessionDetail(String.valueOf(s.id()), s.title(), s.createdAt(), messages);
    }

    public void delete(long userId, long sessionId) {
        chats.deleteSession(userId, sessionId);
    }

    private ChatDtos.MessageDto toDto(ChatRepository.MessageRow m, long userId) {
        List<Dish> dishes = new ArrayList<>();
        for (Long id : m.dishIds()) {
            catalog.find(id).ifPresent(dishes::add);
        }
        List<DishDto> dishDtos = dishes.isEmpty() ? List.of() : dishService.toDtos(dishes, Optional.of(userId));
        DishDto recipe = m.recipeDishId() == null ? null : catalog.find(m.recipeDishId())
                .map(d -> dishService.toDtos(List.of(d), Optional.of(userId)).get(0))
                .orElse(null);
        String type = m.type();
        if ("restaurantSuggestion".equals(type) && recipe == null) {
            type = "text"; // món đã bị xoá khỏi DB
        }
        return new ChatDtos.MessageDto(String.valueOf(m.id()), m.user(), m.content(), type, dishDtos, recipe,
                m.hadImage(), m.createdAt());
    }

    private static Optional<Long> parseId(String raw) {
        if (raw == null || raw.isBlank()) {
            return Optional.empty();
        }
        try {
            return Optional.of(Long.parseLong(raw.trim()));
        } catch (NumberFormatException e) {
            return Optional.empty();
        }
    }

    private static String stripDataPrefix(String base64) {
        int comma = base64.indexOf(',');
        return base64.startsWith("data:") && comma > 0 ? base64.substring(comma + 1) : base64;
    }
}
