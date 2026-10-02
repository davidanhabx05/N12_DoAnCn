import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:n12_doan_cn/viewmodels/restaurant_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/profile_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/language_viewmodel.dart';
import 'package:n12_doan_cn/core/theme/app_theme.dart';
import 'package:n12_doan_cn/models/restaurant.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  late final TextEditingController _searchController;
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: context.read<RestaurantViewModel>().searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _openGoogleMaps(BuildContext context, RestaurantViewModel vm, Restaurant r) async {
    final params = <String, String>{'api': '1', 'query': vm.mapsQueryFor(r)};
    // Quán lấy từ Google Places -> mở đúng địa điểm theo place_id
    if (r.id.startsWith('place_')) params['query_place_id'] = r.id.substring('place_'.length);
    final url = Uri.https('www.google.com', '/maps/search/', params);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('launch failed');
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Không mở được Google Maps trên thiết bị này.')));
    }
  }

  /// Mở Google Maps tìm theo từ khoá quanh vị trí hiện tại (dùng khi app không có kết quả).
  Future<void> _searchOnGoogleMaps(String keyword) async {
    final query = keyword.trim().isEmpty ? 'quán ăn gần đây' : '${keyword.trim()} gần đây';
    final url = Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query});
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('launch failed');
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Không mở được Google Maps trên thiết bị này.')));
    }
  }

  /// Dòng nhỏ cho biết quán lấy từ đâu và app đã có vị trí người dùng hay chưa.
  Widget _buildSourceLine(RestaurantViewModel vm, bool isVi) {
    String text;
    IconData icon = Icons.place_outlined;
    Color color = AppTheme.textGrey;
    if (!vm.hasLocation) {
      icon = Icons.location_off_outlined;
      color = Colors.orange;
      text = isVi
          ? '${vm.locationIssue ?? 'Đang lấy vị trí'}. Tạm tìm quanh trung tâm Hà Nội, chạm để thử lại.'
          : 'Location unavailable. Searching around central Hanoi, tap to retry.';
    } else if (vm.source == 'google') {
      text = isVi ? 'Quán thật quanh vị trí của bạn · Google Maps' : 'Real places near you · Google Maps';
    } else if (vm.source == 'osm') {
      text = isVi ? 'Quán thật quanh vị trí của bạn · © OpenStreetMap' : 'Real places near you · © OpenStreetMap';
    } else if (vm.source == 'local') {
      text = isVi ? 'Quán trong cơ sở dữ liệu của app' : 'Places from the app database';
    } else {
      text = isVi ? 'Đang dùng vị trí hiện tại của bạn' : 'Using your current location';
    }
    return InkWell(
      onTap: vm.hasLocation ? null : vm.retryLocation,
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: color))),
        ],
      ),
    );
  }

  /// Không có quán nào khớp: nói rõ, không bịa quán; cho phép tìm tiếp trên Google Maps.
  Widget _buildEmptyState(RestaurantViewModel vm, bool isVi) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              isVi ? 'Chưa tìm thấy quán phù hợp quanh đây.' : 'No matching places found nearby.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textGrey),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _searchOnGoogleMaps(vm.searchQuery),
              icon: const Icon(Icons.map_outlined, size: 18),
              label: Text(isVi ? 'Tìm trên Google Maps' : 'Search on Google Maps'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantViewModel>();
    // Từ khoá có thể được đặt từ màn khác (chi tiết món, chatbot) -> đồng bộ ô tìm kiếm
    if (!_searchFocus.hasFocus && _searchController.text != vm.searchQuery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_searchFocus.hasFocus) _searchController.text = vm.searchQuery;
      });
    }
    final profileVm = context.watch<ProfileViewModel>();
    final langVm = context.watch<LanguageViewModel>();
    final dietType = profileVm.preferences.dietType;
    final isVi = langVm.currentLocale.languageCode == 'vi';

    final displayRestaurants = vm.getFilteredByPreference(dietType);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('${langVm.t('restaurant_suggest')} (${langVm.currentLocale.languageCode == 'vi' ? 'Dành cho bạn' : 'For you'})', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppTheme.textGrey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        textInputAction: TextInputAction.search,
                        onChanged: vm.onSearchChanged,
                        onSubmitted: (_) => vm.fetchNearbyFromPlaces(),
                        decoration: InputDecoration(
                          hintText: langVm.currentLocale.languageCode == 'vi' ? 'Tìm quán ăn gần bạn...' : 'Find restaurants nearby...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    if (dietType != 'Bình thường')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text(dietType, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.categories.length,
                  itemBuilder: (context, index) {
                    final cat = vm.categories[index];
                    final isSelected = vm.selectedCategory == cat;
                    
                    String label = cat;
                    if (langVm.currentLocale.languageCode == 'en') {
                      final map = {'Tất cả': 'All', 'Món Chay': 'Vegetarian', 'Healthy': 'Healthy', 'Nhà hàng': 'Restaurant', 'Ăn vặt': 'Snack', 'Quán Nhậu': 'Bar/Pub'};
                      label = map[cat] ?? cat;
                    }

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: AppTheme.primaryOrange,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (_) => vm.setCategory(cat),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              Text(
                '${langVm.currentLocale.languageCode == 'vi' ? 'Quán ăn phù hợp' : 'Suitable restaurants'} · ${displayRestaurants.length} ${langVm.currentLocale.languageCode == 'vi' ? 'kết quả' : 'results'}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
              ),
              const SizedBox(height: 4),
              _buildSourceLine(vm, isVi),
              const SizedBox(height: 12),

              Expanded(
                child: displayRestaurants.isEmpty && (vm.isSearching || vm.errorMessage != null)
                    ? Center(
                        child: vm.isSearching
                            ? const CircularProgressIndicator(color: AppTheme.primaryOrange)
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                                  const SizedBox(height: 12),
                                  Text(vm.errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                                  TextButton(onPressed: vm.fetchNearbyFromPlaces, child: const Text('Thử lại')),
                                ],
                              ),
                      )
                    : displayRestaurants.isEmpty
                        ? _buildEmptyState(vm, isVi)
                        : ListView.builder(
                  itemCount: displayRestaurants.length,
                  itemBuilder: (context, index) {
                    final r = displayRestaurants[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quán lấy từ OpenStreetMap không có ảnh -> hiện dải màu thay vì ảnh trống
                          if (r.imageUrl.isEmpty)
                            Container(
                              height: 64,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryOrange.withOpacity(0.08),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              child: const Icon(Icons.storefront, color: AppTheme.primaryOrange, size: 30),
                            )
                          else
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: CachedNetworkImage(
                              imageUrl: r.imageUrl,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(height: 160, color: Colors.grey[200]),
                              errorWidget: (context, url, error) => Container(height: 160, color: Colors.grey[300], child: const Icon(Icons.restaurant, color: Colors.grey)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textDark)),
                                    ),
                                    if (r.rating > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 14),
                                          const SizedBox(width: 4),
                                          Text('${r.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(r.address, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.directions_walk, size: 14, color: AppTheme.primaryOrange),
                                        Text(' ${r.distance}   ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                                        if (r.openKnown)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: r.isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            r.isOpen 
                                                ? (langVm.currentLocale.languageCode == 'vi' ? 'Đang mở cửa' : 'Open now') 
                                                : (langVm.currentLocale.languageCode == 'vi' ? 'Đã đóng cửa' : 'Closed'),
                                            style: TextStyle(color: r.isOpen ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryOrange,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      icon: const Icon(Icons.map, size: 16),
                                      label: Text(langVm.currentLocale.languageCode == 'vi' ? 'Mở Google Maps' : 'Open Maps', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      onPressed: () => _openGoogleMaps(context, vm, r),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
