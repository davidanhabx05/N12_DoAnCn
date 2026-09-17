import 'package:flutter/material.dart';

class FilterViewModel extends ChangeNotifier {
  String savedFilterName = '';
  String selectedTime = 'Bất kỳ';
  double maxTimeSlider = 180.0;

  String? selectedRegion;
  String? selectedWeather;
  String? selectedMood;
  String? selectedOccasion;
  String? selectedSeason;

  final List<String> timeOptions = ['Bất kỳ', '≤ 15 phút', '15–30 phút', '30–60 phút', '> 60 phút'];
  final List<String> regionOptions = ['Miền bắc', 'Miền trung', 'Miền nam'];
  final List<String> weatherOptions = ['Nắng', 'Mưa', 'Mát mẻ', 'Se lạnh', 'Lạnh'];
  final List<String> moodOptions = ['Vui vẻ', 'Buồn', 'Bực bội', 'Phấn khích', 'Chán nản'];
  final List<String> occasionOptions = ['Sinh nhật', 'Đám cưới', 'Lễ, kỳ nghỉ', 'Tiệc', 'Bình thường'];
  final List<String> seasonOptions = ['Mùa xuân', 'Mùa hè', 'Mùa thu', 'Mùa đông', 'Mùa nóng', 'Mùa lạnh'];

  void setTime(String time) {
    selectedTime = time;
    notifyListeners();
  }

  void setTimeSlider(double value) {
    maxTimeSlider = value;
    notifyListeners();
  }

  void setRegion(String? region) {
    selectedRegion = region;
    notifyListeners();
  }

  void setWeather(String? weather) {
    selectedWeather = weather;
    notifyListeners();
  }

  void setMood(String? mood) {
    selectedMood = mood;
    notifyListeners();
  }

  void setOccasion(String? occasion) {
    selectedOccasion = occasion;
    notifyListeners();
  }

  void setSeason(String? season) {
    selectedSeason = season;
    notifyListeners();
  }

  void clearAll() {
    savedFilterName = '';
    selectedTime = 'Bất kỳ';
    maxTimeSlider = 180.0;
    selectedRegion = null;
    selectedWeather = null;
    selectedMood = null;
    selectedOccasion = null;
    selectedSeason = null;
    notifyListeners();
  }
}
