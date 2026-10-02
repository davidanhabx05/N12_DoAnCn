package vn.homnayangi.api.auth;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

/**
 * Đọc header "Authorization: Bearer &lt;token&gt;" và gắn user_id vào request.
 * Không chặn request: endpoint nào cần đăng nhập sẽ gọi AuthContext.requireUserId().
 */
@Component
public class AuthInterceptor implements HandlerInterceptor {

    private final SessionRepository sessions;

    public AuthInterceptor(SessionRepository sessions) {
        this.sessions = sessions;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String header = request.getHeader("Authorization");
        if (header != null && header.regionMatches(true, 0, "Bearer ", 0, 7)) {
            String token = header.substring(7).trim();
            if (!token.isEmpty()) {
                sessions.findUserId(token).ifPresent(userId -> {
                    request.setAttribute(AuthContext.USER_ID_ATTRIBUTE, userId);
                    request.setAttribute(AuthContext.TOKEN_ATTRIBUTE, token);
                });
            }
        }
        return true;
    }
}
