package vn.homnayangi.api.user;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import vn.homnayangi.api.common.ApiException;

@Service
public class ProfileService {

    private final UserRepository users;
    private final PreferencesRepository preferences;

    public ProfileService(UserRepository users, PreferencesRepository preferences) {
        this.users = users;
        this.preferences = preferences;
    }

    public ProfileDto getProfile(long userId) {
        UserRecord user = users.findById(userId).orElseThrow(() -> ApiException.notFound("Không tìm thấy người dùng"));
        PreferencesDto prefs = preferences.findByUserId(userId);
        Double bmi = HealthCalculator.bmi(prefs.weight(), prefs.height());
        Integer tdee = HealthCalculator.tdee(prefs.weight(), prefs.height(), prefs.birthYear(), prefs.gender(),
                prefs.activityLevel());
        return new ProfileDto(user.id(), user.displayName(), user.bio(), user.avatarUrl(), user.email(),
                user.guest(), user.demo(), prefs,
                new ProfileDto.Health(bmi == null ? null : Math.round(bmi * 10) / 10.0,
                        HealthCalculator.bmiCategory(bmi), tdee));
    }

    public PreferencesDto getPreferences(long userId) {
        return preferences.findByUserId(userId);
    }

    @Transactional
    public ProfileDto updateProfile(long userId, UpdateProfileRequest request) {
        String name = request.displayName() == null ? null : request.displayName().trim();
        if (name != null && name.length() < 2) {
            throw ApiException.badRequest("Tên hiển thị phải có ít nhất 2 ký tự");
        }
        String bio = request.bio() == null ? null : request.bio().trim();
        String avatar = request.avatarUrl() == null || request.avatarUrl().isBlank() ? null : request.avatarUrl();
        users.updateProfile(userId, name, bio, avatar);
        return getProfile(userId);
    }

    @Transactional
    public ProfileDto updatePreferences(long userId, PreferencesDto request) {
        if (request == null) {
            throw ApiException.badRequest("Thiếu dữ liệu hồ sơ");
        }
        if (request.height() != null && (request.height() < 50 || request.height() > 250)) {
            throw ApiException.badRequest("Chiều cao phải từ 50 đến 250 cm");
        }
        if (request.weight() != null && (request.weight() < 20 || request.weight() > 300)) {
            throw ApiException.badRequest("Cân nặng phải từ 20 đến 300 kg");
        }
        preferences.save(userId, request);
        return getProfile(userId);
    }

    @Transactional
    public void deleteAccount(long userId) {
        users.delete(userId);
    }
}
