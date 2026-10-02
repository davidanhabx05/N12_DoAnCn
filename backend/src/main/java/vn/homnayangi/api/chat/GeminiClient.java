package vn.homnayangi.api.chat;

import java.time.Duration;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

/**
 * Gọi Gemini REST API (generateContent). Key chỉ nằm ở backend.
 * Tự dò model khả dụng (ưu tiên dòng "flash") và nhớ model dùng được.
 */
@Component
public class GeminiClient {

    private static final Logger log = LoggerFactory.getLogger(GeminiClient.class);
    private static final String BASE = "https://generativelanguage.googleapis.com/v1beta";
    private static final Pattern EXCLUDED = Pattern.compile("embedding|tts|image-generation|audio|live|thinking");

    /** Một lượt hội thoại trước đó. */
    public record Turn(boolean user, String text) {
    }

    private final String apiKey;
    private final ObjectMapper mapper;
    private final RestClient http;
    private volatile String activeModel;

    public GeminiClient(@Value("${app.gemini-api-key:}") String apiKey, ObjectMapper mapper) {
        this.apiKey = apiKey == null ? "" : apiKey.trim();
        this.mapper = mapper;
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout((int) Duration.ofSeconds(10).toMillis());
        factory.setReadTimeout((int) Duration.ofSeconds(40).toMillis());
        this.http = RestClient.builder().requestFactory(factory).build();
    }

    public boolean isConfigured() {
        return !apiKey.isEmpty();
    }

    /** Trả về câu trả lời hoặc null nếu không gọi được (backend sẽ tự trả lời offline). */
    public String ask(List<Turn> history, String prompt, String imageBase64, String imageMimeType) {
        if (!isConfigured()) {
            return null;
        }
        ObjectNode body = buildBody(history, prompt, imageBase64, imageMimeType);

        String model = activeModel;
        if (model != null) {
            String res = tryModel(model, body);
            if (res != null) {
                return res;
            }
            activeModel = null;
        }
        List<String> models = listModels();
        for (String m : models.subList(0, Math.min(5, models.size()))) {
            String res = tryModel(m, body);
            if (res != null) {
                activeModel = m;
                return res;
            }
        }
        return null;
    }

    private ObjectNode buildBody(List<Turn> history, String prompt, String imageBase64, String imageMimeType) {
        ArrayNode contents = mapper.createArrayNode();
        for (Turn turn : history) {
            if (turn.text() == null || turn.text().isBlank()) {
                continue;
            }
            String role = turn.user() ? "user" : "model";
            ObjectNode last = contents.isEmpty() ? null : (ObjectNode) contents.get(contents.size() - 1);
            if (last != null && role.equals(last.path("role").asText())) {
                ((ArrayNode) last.get("parts")).addObject().put("text", turn.text());
            } else {
                ObjectNode node = contents.addObject();
                node.put("role", role);
                node.putArray("parts").addObject().put("text", turn.text());
            }
        }
        // Gemini yêu cầu hội thoại bắt đầu bằng lượt 'user'
        while (!contents.isEmpty() && !"user".equals(contents.get(0).path("role").asText())) {
            contents.remove(0);
        }

        ArrayNode parts = mapper.createArrayNode();
        parts.addObject().put("text", prompt);
        if (imageBase64 != null && !imageBase64.isBlank()) {
            ObjectNode inline = parts.addObject().putObject("inline_data");
            inline.put("mime_type", imageMimeType == null || imageMimeType.isBlank() ? "image/jpeg" : imageMimeType);
            inline.put("data", imageBase64);
        }
        ObjectNode last = contents.isEmpty() ? null : (ObjectNode) contents.get(contents.size() - 1);
        if (last != null && "user".equals(last.path("role").asText())) {
            ((ArrayNode) last.get("parts")).addAll(parts);
        } else {
            ObjectNode node = contents.addObject();
            node.put("role", "user");
            node.set("parts", parts);
        }

        ObjectNode body = mapper.createObjectNode();
        body.putObject("system_instruction").putArray("parts").addObject()
                .put("text", ChatAnalyzer.SYSTEM_INSTRUCTION);
        body.set("contents", contents);
        ObjectNode config = body.putObject("generationConfig");
        config.put("temperature", 0.8);
        config.put("maxOutputTokens", 600);
        return body;
    }

    private String tryModel(String model, ObjectNode body) {
        try {
            JsonNode data = http.post()
                    .uri(BASE + "/models/{model}:generateContent?key={key}", Map.of("model", model, "key", apiKey))
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(body)
                    .retrieve()
                    .body(JsonNode.class);
            if (data == null) {
                return null;
            }
            StringBuilder sb = new StringBuilder();
            for (JsonNode part : data.path("candidates").path(0).path("content").path("parts")) {
                sb.append(part.path("text").asText(""));
            }
            String text = sb.toString().trim();
            return text.isEmpty() ? null : text;
        } catch (Exception e) {
            log.debug("Model {} lỗi: {}", model, e.getMessage());
            return null;
        }
    }

    /** Model hỗ trợ generateContent, ưu tiên "flash" (nhanh, rẻ). */
    private List<String> listModels() {
        List<String> found = new ArrayList<>();
        try {
            JsonNode data = http.get()
                    .uri(BASE + "/models?key={key}", Map.of("key", apiKey))
                    .retrieve()
                    .body(JsonNode.class);
            if (data != null) {
                for (JsonNode m : data.path("models")) {
                    String name = m.path("name").asText("");
                    boolean canGenerate = false;
                    for (JsonNode method : m.path("supportedGenerationMethods")) {
                        if ("generateContent".equals(method.asText())) {
                            canGenerate = true;
                        }
                    }
                    if (!name.contains("gemini") || !canGenerate || EXCLUDED.matcher(name).find()) {
                        continue;
                    }
                    found.add(name.replaceFirst("^models/", ""));
                }
            }
        } catch (Exception e) {
            log.warn("Không lấy được danh sách model Gemini: {}", e.getMessage());
        }
        found.sort(Comparator.comparingInt(GeminiClient::rank));
        if (found.isEmpty()) {
            found.addAll(List.of("gemini-2.0-flash", "gemini-1.5-flash"));
        }
        return found;
    }

    private static int rank(String name) {
        int score = 0;
        if (name.contains("flash")) score -= 10;
        if (name.contains("lite")) score += 1;
        if (name.contains("exp") || name.contains("preview")) score += 5;
        if (name.contains("1.0")) score += 8;
        return score;
    }
}
