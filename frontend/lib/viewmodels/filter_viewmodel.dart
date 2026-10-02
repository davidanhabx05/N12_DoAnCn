import 'package:flutter/material.dart';

import '../core/network/api_client.dart';

/// Một bộ lọc người dùng đã đặt tên, lưu ở backend (bảng saved_filters).
class SavedFilter {
  /// id trên server (null khi đang chờ server lưu xong).
  final String? id;
  final String name;
  final String time;
  final double maxTime;
  final String? region;
  final String? weather;
  final String? mood;

  const SavedFilter({
    this.id,
    required this.name,
    required this.time,
    required this.maxTime,
    this.region,
    this.weather,
    this.mood,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'time': time,
        'maxTime': maxTime,
        'region': region,
        'weather': weather,
        'mood': mood,
      };

  factory SavedFilter.fromMap(Map<String, dynamic> map) => SavedFilter(
        id: map['id']?.toString(),
        name: map['name']?.toString() ?? '',
        time: map['time']?.toString() ?? 'Bất kỳ',
        maxTime: (map['maxTime'] as num?)?.toDouble() ?? 180.0,
        region: map['region'] as String?,
        weather: map['weather'] as String?,
        mood: map['mood'] as String?,
      );
}

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

  List<SavedFilter> _savedFilters = [];
  List<SavedFilter> get savedFilters => List.unmodifiable(_savedFilters);

  final ApiClient _api = ApiClient.instance;
  String? _lastError;
  String? get lastError => _lastError;

  FilterViewModel() {
    _api.sessionVersion.addListener(loadSavedFilters);
    loadSavedFilters();
  }

  @override
  void dispose() {
    _api.sessionVersion.removeListener(loadSavedFilters);
    super.dispose();
  }

  /// GET /api/me/filters
  Future<void> loadSavedFilters() async {
    if (!_api.hasSession) {
      _savedFilters = [];
      notifyListeners();
      return;
    }
    try {
      final data = await _api.get('/api/me/filters');
      if (data is List) {
        _savedFilters = data
            .whereType<Map<String, dynamic>>()
            .map(SavedFilter.fromMap)
            .where((f) => f.name.isNotEmpty)
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _lastError = e.toString();
    }
  }

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

  List<Map<String, String>> get activeFilters {
    final List<Map<String, String>> filters = [];
    if (selectedTime != 'Bất kỳ') filters.add({'type': 'time', 'label': selectedTime});
    if (selectedRegion != null) filters.add({'type': 'region', 'label': selectedRegion!});
    if (selectedWeather != null) filters.add({'type': 'weather', 'label': selectedWeather!});
    if (selectedMood != null) filters.add({'type': 'mood', 'label': selectedMood!});
    return filters;
  }

  void removeFilter(String type) {
    if (type == 'time') {
      selectedTime = 'Bất kỳ';
    } else if (type == 'region') {
      selectedRegion = null;
    } else if (type == 'weather') {
      selectedWeather = null;
    } else if (type == 'mood') {
      selectedMood = null;
    }
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

  // ------------------------------------------------------ Bộ lọc đã lưu
  /// Lưu bộ lọc hiện tại với tên [savedFilterName].
  /// Trả về thông báo lỗi (nếu có), null nếu lưu thành công.
  String? saveCurrentFilter({bool english = false}) {
    final name = savedFilterName.trim();
    if (name.isEmpty) {
      return english ? 'Please enter a filter name' : 'Vui lòng đặt tên cho bộ lọc';
    }
    final hasCriteria = activeFilters.isNotEmpty || maxTimeSlider < 180;
    if (!hasCriteria) {
      return english ? 'Select at least one criterion first' : 'Hãy chọn ít nhất một tiêu chí trước khi lưu';
    }

    final filter = SavedFilter(
      name: name,
      time: selectedTime,
      maxTime: maxTimeSlider,
      region: selectedRegion,
      weather: selectedWeather,
      mood: selectedMood,
    );
    if (!_api.hasSession) {
      return english ? 'Please sign in to save filters' : 'Vui lòng đăng nhập để lưu bộ lọc';
    }
    // Trùng tên -> ghi đè. Hiển thị ngay, server lưu xong sẽ trả về id.
    final previous = List<SavedFilter>.of(_savedFilters);
    _savedFilters.removeWhere((f) => f.name.toLowerCase() == name.toLowerCase());
    _savedFilters.insert(0, filter);
    notifyListeners();

    _api.post('/api/me/filters', body: filter.toMap()).then((data) {
      if (data is Map<String, dynamic>) {
        final saved = SavedFilter.fromMap(data);
        final i = _savedFilters.indexWhere((f) => f.name.toLowerCase() == saved.name.toLowerCase());
        if (i != -1) _savedFilters[i] = saved;
        notifyListeners();
      }
    }).catchError((Object e) {
      _savedFilters = previous;
      _lastError = e.toString();
      notifyListeners();
    });
    return null;
  }

  void applySavedFilter(SavedFilter filter) {
    savedFilterName = filter.name;
    selectedTime = filter.time;
    maxTimeSlider = filter.maxTime.clamp(0, 180).toDouble();
    selectedRegion = filter.region;
    selectedWeather = filter.weather;
    selectedMood = filter.mood;
    notifyListeners();
  }

  void deleteSavedFilter(String name) {
    final removed = _savedFilters.where((f) => f.name == name).toList();
    _savedFilters.removeWhere((f) => f.name == name);
    notifyListeners();
    for (final f in removed) {
      if (f.id != null) {
        _api.delete('/api/me/filters/${f.id}').catchError((Object e) {
          _lastError = e.toString();
        });
      }
    }
  }

  void reset() {
    _savedFilters = [];
    clearAll();
  }
}
