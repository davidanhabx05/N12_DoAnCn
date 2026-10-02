package vn.homnayangi.api;

import java.util.TimeZone;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Điểm khởi động backend "Hôm Nay Ăn Gì".
 * Chạy: ./mvnw spring-boot:run (Windows: mvnw.cmd spring-boot:run) //hoặc ấn run ở trên
 * Tài liệu API: http://localhost:8080/swagger-ui.html
 */
@SpringBootApplication
@EnableScheduling
public class HomNayAnGiApplication {

    public static void main(String[] args) {
        // Windows báo múi giờ là "Asia/Saigon" (tên cũ) mà PostgreSQL trong Docker không nhận
        // -> ép dùng tên mới trước khi kết nối database.
        TimeZone.setDefault(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
        SpringApplication.run(HomNayAnGiApplication.class, args);
    }
}