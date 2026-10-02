package vn.homnayangi.api.auth;

import java.io.FileInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Instant;
import java.util.Base64;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;

import jakarta.annotation.PostConstruct;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import vn.homnayangi.api.common.ApiException;

/**
 * Xác thực Firebase ID token mà app gửi lên sau khi đăng nhập Google.
 * - Có FIREBASE_CREDENTIALS (file service account): kiểm tra chữ ký đầy đủ.
 * - Chưa có: nếu ALLOW_UNVERIFIED_GOOGLE_TOKEN=true thì chỉ đọc thông tin trong token
 *   (tiện khi phát triển), ngược lại từ chối.
 */
@Component
public class FirebaseTokenVerifier {

    private static final Logger log = LoggerFactory.getLogger(FirebaseTokenVerifier.class);

    private final String credentialsPath;
    private final boolean allowUnverified;
    private final ObjectMapper mapper;
    private FirebaseAuth firebaseAuth;

    public FirebaseTokenVerifier(@Value("${app.firebase-credentials:}") String credentialsPath,
                                 @Value("${app.allow-unverified-google-token:true}") boolean allowUnverified,
                                 ObjectMapper mapper) {
        this.credentialsPath = credentialsPath;
        this.allowUnverified = allowUnverified;
        this.mapper = mapper;
    }

    @PostConstruct
    void init() {
        if (credentialsPath == null || credentialsPath.isBlank()) {
            log.warn("Chưa cấu hình FIREBASE_CREDENTIALS -> token Google {} được kiểm chữ ký.",
                    allowUnverified ? "KHÔNG" : "sẽ bị từ chối vì không thể");
            return;
        }
        if (!Files.exists(Path.of(credentialsPath))) {
            log.warn("Không tìm thấy file service account: {}", credentialsPath);
            return;
        }
        try (InputStream in = new FileInputStream(credentialsPath)) {
            FirebaseOptions options = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.fromStream(in))
                    .build();
            FirebaseApp app = FirebaseApp.getApps().isEmpty()
                    ? FirebaseApp.initializeApp(options)
                    : FirebaseApp.getInstance();
            firebaseAuth = FirebaseAuth.getInstance(app);
            log.info("Đã khởi tạo Firebase Admin – token Google sẽ được xác thực đầy đủ.");
        } catch (Exception e) {
            log.error("Không khởi tạo được Firebase Admin", e);
        }
    }

    public GoogleIdentity verify(String idToken) {
        if (idToken == null || idToken.isBlank()) {
            throw ApiException.badRequest("Thiếu idToken");
        }
        if (firebaseAuth != null) {
            try {
                FirebaseToken token = firebaseAuth.verifyIdToken(idToken);
                return new GoogleIdentity(token.getUid(), token.getEmail(), token.getName(), token.getPicture());
            } catch (Exception e) {
                throw new ApiException(HttpStatus.UNAUTHORIZED, "Token Google không hợp lệ: " + e.getMessage());
            }
        }
        if (!allowUnverified) {
            throw new ApiException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Máy chủ chưa cấu hình Firebase để xác thực đăng nhập Google");
        }
        return decodeWithoutVerification(idToken);
    }

    private GoogleIdentity decodeWithoutVerification(String idToken) {
        try {
            String[] parts = idToken.split("\\.");
            if (parts.length < 2) {
                throw ApiException.badRequest("idToken không đúng định dạng JWT");
            }
            byte[] json = Base64.getUrlDecoder().decode(parts[1]);
            JsonNode claims = mapper.readTree(new String(json, StandardCharsets.UTF_8));
            long exp = claims.path("exp").asLong(0);
            if (exp > 0 && Instant.ofEpochSecond(exp).isBefore(Instant.now())) {
                throw new ApiException(HttpStatus.UNAUTHORIZED, "Token Google đã hết hạn, vui lòng đăng nhập lại");
            }
            String uid = text(claims, "user_id");
            if (uid == null) {
                uid = text(claims, "sub");
            }
            if (uid == null) {
                throw ApiException.badRequest("Token không có thông tin người dùng");
            }
            return new GoogleIdentity(uid, text(claims, "email"), text(claims, "name"), text(claims, "picture"));
        } catch (ApiException e) {
            throw e;
        } catch (Exception e) {
            throw ApiException.badRequest("Không đọc được idToken");
        }
    }

    private static String text(JsonNode node, String field) {
        JsonNode v = node.get(field);
        return v == null || v.isNull() || v.asText().isBlank() ? null : v.asText();
    }
}
