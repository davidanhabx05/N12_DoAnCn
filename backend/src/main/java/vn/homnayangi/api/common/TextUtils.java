package vn.homnayangi.api.common;

import java.text.Normalizer;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Xử lý chuỗi tiếng Việt: bỏ dấu, tìm kiếm không phân biệt dấu,
 * định dạng tiền và đọc ngân sách từ câu nói tự nhiên.
 */
public final class TextUtils {

    private static final Pattern COMBINING_MARKS = Pattern.compile("\\p{M}+");
    private static final Pattern SPACES = Pattern.compile("\\s+");
    private static final Pattern MONEY = Pattern.compile(
            "(\\d+(?:[.,]\\d+)*)\\s*(k|nghin|ngan|trieu|tr|dong|vnd|d)?(?![a-z])");

    private TextUtils() {
    }

    /** Chữ thường, bỏ dấu tiếng Việt, gộp khoảng trắng: "Phở  Bò" -> "pho bo". */
    public static String normalize(String input) {
        if (input == null) {
            return "";
        }
        String lower = input.toLowerCase(Locale.ROOT).replace('đ', 'd');
        String decomposed = Normalizer.normalize(lower, Normalizer.Form.NFD);
        String noMarks = COMBINING_MARKS.matcher(decomposed).replaceAll("");
        return SPACES.matcher(noMarks).replaceAll(" ").trim();
    }

    /** true nếu haystack chứa needle (không phân biệt hoa thường & dấu). */
    public static boolean containsIgnoreAccents(String haystack, String needle) {
        if (needle == null || needle.isBlank()) {
            return true;
        }
        return normalize(haystack).contains(normalize(needle));
    }

    /** Cụm từ (đã bỏ dấu) có xuất hiện như một từ/cụm từ độc lập không. */
    public static boolean hasPhrase(String normalizedText, String normalizedPhrase) {
        if (normalizedPhrase == null || normalizedPhrase.isEmpty()) {
            return false;
        }
        Pattern p = Pattern.compile("(^|[^a-z0-9])" + Pattern.quote(normalizedPhrase) + "(?=$|[^a-z0-9])");
        return p.matcher(normalizedText).find();
    }

    /** 45000 -> "45.000". */
    public static String formatVnd(long value) {
        String digits = Long.toString(Math.abs(value));
        StringBuilder sb = new StringBuilder();
        int count = 0;
        for (int i = digits.length() - 1; i >= 0; i--) {
            sb.append(digits.charAt(i));
            if (++count % 3 == 0 && i > 0) {
                sb.append('.');
            }
        }
        if (value < 0) {
            sb.append('-');
        }
        return sb.reverse().toString();
    }

    /**
     * Đọc số tiền trong câu: "50k", "50 nghìn", "100.000đ", "1 triệu", "tầm 30-50k"...
     * Trả về số VNĐ (lấy mức cao nhất nếu có khoảng) hoặc null nếu không có.
     */
    public static Integer parseBudget(String text) {
        String t = normalize(text);
        boolean hasMoneyContext = t.contains("tien") || t.contains("ngan sach") || t.contains("budget")
                || t.contains("gia ") || t.contains("tui");
        Matcher m = MONEY.matcher(t);
        Integer best = null;
        Integer bareCandidate = null;
        while (m.find()) {
            String raw = m.group(1);
            String unit = m.group(2);
            Integer value = null;
            if ("trieu".equals(unit) || "tr".equals(unit)) {
                Double v = parseDouble(raw);
                if (v != null) {
                    value = (int) Math.round(v * 1_000_000);
                }
            } else if ("k".equals(unit) || "nghin".equals(unit) || "ngan".equals(unit)) {
                Double v = parseDouble(raw);
                if (v != null) {
                    value = (int) Math.round(v * 1000);
                }
            } else if (unit != null) {
                Integer v = parseInt(raw);
                if (v != null) {
                    value = v < 1000 ? v * 1000 : v;
                }
            } else {
                Integer v = parseInt(raw);
                if (v != null && bareCandidate == null) {
                    if (v >= 1000) {
                        bareCandidate = v;
                    } else if (v >= 10) {
                        bareCandidate = v * 1000;
                    }
                }
                continue;
            }
            if (value != null && (best == null || value > best)) {
                best = value;
            }
        }
        if (best != null) {
            return best;
        }
        return hasMoneyContext ? bareCandidate : null;
    }

    private static Double parseDouble(String raw) {
        try {
            return Double.parseDouble(raw.replace(',', '.'));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static Integer parseInt(String raw) {
        try {
            long v = Long.parseLong(raw.replace(".", "").replace(",", ""));
            return v > Integer.MAX_VALUE ? null : (int) v;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
