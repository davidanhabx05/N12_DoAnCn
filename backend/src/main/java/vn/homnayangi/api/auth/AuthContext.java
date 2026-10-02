package vn.homnayangi.api.auth;

import java.util.Optional;

import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;

import vn.homnayangi.api.common.ApiException;

/** Lấy id người dùng của request hiện tại (do AuthInterceptor gắn vào). */
public final class AuthContext {

    static final String USER_ID_ATTRIBUTE = "homnayangi.userId";
    static final String TOKEN_ATTRIBUTE = "homnayangi.token";

    private AuthContext() {
    }

    public static Optional<Long> currentUserId() {
        RequestAttributes attrs = RequestContextHolder.getRequestAttributes();
        if (attrs == null) {
            return Optional.empty();
        }
        Object value = attrs.getAttribute(USER_ID_ATTRIBUTE, RequestAttributes.SCOPE_REQUEST);
        return value instanceof Long id ? Optional.of(id) : Optional.empty();
    }

    /** Bắt buộc đăng nhập (kể cả tài khoản khách); nếu không -> 401. */
    public static long requireUserId() {
        return currentUserId().orElseThrow(ApiException::unauthorized);
    }

    public static Optional<String> currentToken() {
        RequestAttributes attrs = RequestContextHolder.getRequestAttributes();
        if (attrs == null) {
            return Optional.empty();
        }
        Object value = attrs.getAttribute(TOKEN_ATTRIBUTE, RequestAttributes.SCOPE_REQUEST);
        return value instanceof String s ? Optional.of(s) : Optional.empty();
    }
}
