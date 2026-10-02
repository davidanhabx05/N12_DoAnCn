package vn.homnayangi.api.user;

import com.fasterxml.jackson.annotation.JsonProperty;

/** Thông tin người dùng hiện tại trả về cho app. */
public record ProfileDto(
        long id,
        String displayName,
        String bio,
        String avatarUrl,
        String email,
        @JsonProperty("isGuest") boolean isGuest,
        @JsonProperty("isDemo") boolean isDemo,
        PreferencesDto preferences,
        Health health) {

    public record Health(Double bmi, String bmiCategory, Integer tdee) {
    }
}
