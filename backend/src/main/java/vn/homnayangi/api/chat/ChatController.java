package vn.homnayangi.api.chat;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import vn.homnayangi.api.auth.AuthContext;

/** Chatbot ẩm thực: gửi tin nhắn, xem / xoá lịch sử trò chuyện. */
@RestController
@RequestMapping("/api/chat")
public class ChatController {

    private final ChatService service;

    public ChatController(ChatService service) {
        this.service = service;
    }

    /** sessionId rỗng -> bắt đầu cuộc trò chuyện mới. */
    @PostMapping("/messages")
    public ChatDtos.SendMessageResponse send(@RequestBody ChatDtos.SendMessageRequest request) {
        return service.send(AuthContext.requireUserId(), request);
    }

    @GetMapping("/sessions")
    public List<ChatDtos.SessionSummary> sessions() {
        return service.sessions(AuthContext.requireUserId());
    }

    @GetMapping("/sessions/{id}")
    public ChatDtos.SessionDetail session(@PathVariable long id) {
        return service.session(AuthContext.requireUserId(), id);
    }

    @DeleteMapping("/sessions/{id}")
    public ResponseEntity<Void> delete(@PathVariable long id) {
        service.delete(AuthContext.requireUserId(), id);
        return ResponseEntity.noContent().build();
    }
}
