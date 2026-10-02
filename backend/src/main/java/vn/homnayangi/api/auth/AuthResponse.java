package vn.homnayangi.api.auth;

import vn.homnayangi.api.user.ProfileDto;

public record AuthResponse(String token, ProfileDto user) {
}
