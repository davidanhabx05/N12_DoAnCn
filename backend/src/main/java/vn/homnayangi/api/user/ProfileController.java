package vn.homnayangi.api.user;

import jakarta.validation.Valid;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import vn.homnayangi.api.auth.AuthContext;

/** Hồ sơ người dùng đang đăng nhập. */
@RestController
@RequestMapping("/api/me")
public class ProfileController {

    private final ProfileService service;

    public ProfileController(ProfileService service) {
        this.service = service;
    }

    @GetMapping
    public ProfileDto me() {
        return service.getProfile(AuthContext.requireUserId());
    }

    @PutMapping("/profile")
    public ProfileDto updateProfile(@Valid @RequestBody UpdateProfileRequest request) {
        return service.updateProfile(AuthContext.requireUserId(), request);
    }

    @PutMapping("/preferences")
    public ProfileDto updatePreferences(@RequestBody PreferencesDto request) {
        return service.updatePreferences(AuthContext.requireUserId(), request);
    }

    /** Xoá tài khoản và toàn bộ dữ liệu liên quan (ON DELETE CASCADE). */
    @DeleteMapping
    public ResponseEntity<Void> deleteAccount() {
        service.deleteAccount(AuthContext.requireUserId());
        return ResponseEntity.noContent().build();
    }
}
