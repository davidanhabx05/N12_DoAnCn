package vn.homnayangi.api.dish;

import java.util.List;

import vn.homnayangi.api.common.TextUtils;

/** Tên các món chính – dùng để nhận diện món trong câu chat / khi tìm quán. */
public final class MainDishes {

    public static final List<String> NAMES = List.of(
            "Phở", "Bún bò", "Cơm tấm", "Hủ tiếu", "Gỏi cuốn", "Canh chua", "Mì Quảng", "Cháo gà", "Lẩu thái",
            "Bánh xèo", "Xôi xéo", "Bánh cuốn", "Miến trộn", "Cơm rang", "Bún riêu", "Bún chả", "Cao lầu",
            "Bánh đa cua", "Bún mắm", "Hủ tiếu Nam Vang", "Bánh canh", "Chả cá Lã Vọng", "Bún đậu mắm tôm",
            "Gỏi đu đủ", "Bò kho", "Phở cuốn", "Bún thang", "Bánh mì kẹp",
            // Món chính của bộ 60 món ba miền (database/02_seed_data.sql)
            "Phở bò", "Phở gà", "Phở khô", "Nộm đu đủ", "Nộm hoa chuối", "Rau muống xào tỏi", "Bánh tôm",
            "Nem rán", "Canh cua", "Đậu phụ sốt cà chua", "Lẩu riêu cua", "Mì vằn thắn", "Bánh bèo", "Gỏi cá",
            "Chè hạt sen", "Gỏi mít", "Bánh tráng nướng", "Bánh căn", "Cơm hến", "Cơm gà", "Bánh mì",
            "Bún bò Huế", "Bún chả cá", "Bánh bột lọc", "Lẩu thả", "Nem nướng", "Cơm chay", "Chè ba màu",
            "Gỏi ngó sen", "Gỏi cuốn chay", "Bột chiên", "Bò kho bánh mì", "Cơm gà xối mỡ", "Bún thịt nướng",
            "Bánh tráng trộn", "Canh khổ qua", "Hủ tiếu chay", "Lẩu mắm", "Lẩu cá kèo", "Mì vịt tiềm");

    private MainDishes() {
    }

    /** Tên món chính dài nhất xuất hiện trong câu (không phân biệt dấu), hoặc null. */
    public static String detect(String text) {
        String normalized = TextUtils.normalize(text);
        String best = null;
        int bestLength = -1;
        for (String name : NAMES) {
            String n = TextUtils.normalize(name);
            if (TextUtils.hasPhrase(normalized, n) && n.length() > bestLength) {
                best = name;
                bestLength = n.length();
            }
        }
        return best;
    }
}
