package vn.homnayangi.api.user;

/** Một dòng trong bảng users. */
public record UserRecord(
        long id,
        String firebaseUid,
        String email,
        String displayName,
        String bio,
        String avatarUrl,
        boolean guest,
        boolean demo) {
}
