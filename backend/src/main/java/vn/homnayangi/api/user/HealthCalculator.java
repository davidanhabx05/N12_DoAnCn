package vn.homnayangi.api.user;

import java.time.Year;

/** BMI và TDEE (công thức Mifflin-St Jeor x hệ số vận động). */
public final class HealthCalculator {

    private HealthCalculator() {
    }

    public static Double bmi(Double weight, Double height) {
        if (weight == null || height == null || height <= 0 || weight <= 0) {
            return null;
        }
        double h = height / 100.0;
        return weight / (h * h);
    }

    public static String bmiCategory(Double bmi) {
        if (bmi == null) {
            return "Chưa có dữ liệu";
        }
        if (bmi < 18.5) {
            return "Thiếu cân";
        }
        if (bmi < 25) {
            return "Cân đối";
        }
        if (bmi < 30) {
            return "Thừa cân";
        }
        return "Béo phì";
    }

    public static Integer tdee(Double weight, Double height, Integer birthYear, String gender, String activityLevel) {
        if (weight == null || height == null || birthYear == null || gender == null || activityLevel == null) {
            return null;
        }
        int age = Year.now().getValue() - birthYear;
        if (age <= 0 || age > 120) {
            return null;
        }
        double bmr;
        if ("Nam".equals(gender)) {
            bmr = 10 * weight + 6.25 * height - 5 * age + 5;
        } else if ("Nữ".equals(gender)) {
            bmr = 10 * weight + 6.25 * height - 5 * age - 161;
        } else {
            bmr = 10 * weight + 6.25 * height - 5 * age - 78;
        }
        double factor = switch (activityLevel) {
            case "Vận động nhẹ" -> 1.375;
            case "Vận động vừa phải" -> 1.55;
            case "Năng động" -> 1.725;
            case "Rất năng động" -> 1.9;
            default -> 1.2;
        };
        return (int) Math.round(bmr * factor);
    }
}
