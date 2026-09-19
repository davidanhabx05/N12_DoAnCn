import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:n12_doan_cn/core/theme/app_theme.dart';
import 'package:n12_doan_cn/viewmodels/app_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/home_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/search_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/feed_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/menu_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/profile_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/filter_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/settings_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/restaurant_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/chatbot_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/notification_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/language_viewmodel.dart';
import 'package:n12_doan_cn/features/main_scaffold.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {}

  try {
    await Firebase.initializeApp();
  } catch (_) {}

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => FeedViewModel()),
        ChangeNotifierProvider(create: (_) => MenuViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => FilterViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => RestaurantViewModel()),
        ChangeNotifierProvider(create: (_) => ChatbotViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
      ],
      child: const RootApp(),
    );
  }
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageVm = context.watch<LanguageViewModel>();
    
    return MaterialApp(
      title: 'N12 DoAnCn - Hôm Nay Ăn Gì',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: languageVm.currentLocale,
      scrollBehavior: AppScrollBehavior(),
      home: const MainScaffold(),
    );
  }
}
