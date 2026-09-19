import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/app_viewmodel.dart';
import '../viewmodels/language_viewmodel.dart';
import '../core/theme/app_theme.dart';
import 'home/home_screen.dart';
import 'feed/feed_screen.dart';
import 'search/search_screen.dart';
import 'restaurant/restaurant_screen.dart';
import 'menu/menu_screen.dart';
import 'profile/profile_screen.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    FeedScreen(),
    SearchScreen(),
    RestaurantScreen(),
    MenuScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appViewModel = context.watch<AppViewModel>();
    final langVm = context.watch<LanguageViewModel>();

    return Scaffold(
      body: _screens[appViewModel.currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: appViewModel.currentIndex,
          onTap: (index) => appViewModel.setIndex(index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryOrange,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: langVm.t('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.dynamic_feed_outlined),
              activeIcon: const Icon(Icons.dynamic_feed),
              label: langVm.t('feed'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.search),
              activeIcon: const Icon(Icons.search),
              label: langVm.t('search'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map),
              label: langVm.t('restaurants'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_month_outlined),
              activeIcon: const Icon(Icons.calendar_month),
              label: langVm.t('menu'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: langVm.t('profile'),
            ),
          ],
        ),
      ),
    );
  }
}
