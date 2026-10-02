package vn.homnayangi.api.auth;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Đăng nhập / đăng xuất. Các API khác gửi kèm header "Authorization: Bearer &lt;token&gt;". */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService service;

    public AuthController(AuthService service) {
        this.service = service;
    }

    @PostMapping("/google")
    public AuthResponse google(@RequestBody GoogleLoginRequest request) {
        return service.loginWithGoogle(request.idToken());
    }

    @PostMapping("/guest")
    public AuthResponse guest() {
        return service.loginAsGuest();
    }

    @PostMapping("/demo")
    public AuthResponse demo() {
        return service.loginDemo();
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout() {
        AuthContext.currentToken().ifPresent(service::logout);
        return ResponseEntity.noContent().build();
    }
}
