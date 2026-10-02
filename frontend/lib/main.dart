import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:n12_doan_cn/core/theme/app_theme.dart';
import 'package:n12_doan_cn/viewmodels/app_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/home_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/search_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/profile_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/filter_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/settings_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/restaurant_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/chatbot_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/notification_viewmodel.dart';
import 'package:n12_doan_cn/viewmodels/language_viewmodel.dart';
import 'package:n12_doan_cn/routes/app_routes.dart';
import 'package:n12_doan_cn/core/constants/app_constants.dart';
import 'package:n12_doan_cn/core/services/local_storage_service.dart';
import 'package:n12_doan_cn/core/network/api_client.dart';

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
    if (kIsWeb) {
      // Bản web (Chrome): lấy các giá trị này ở Firebase Console >
      // Project settings > Your apps > app Web > firebaseConfig
      await Firebase.initializeApp(
        // apiKey đọc từ frontend/.env (FIREBASE_WEB_API_KEY) để không lộ key trên GitHub
        options: FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? '',
          authDomain: 'gen-lang-client-0593027046.firebaseapp.com',
          projectId: 'gen-lang-client-0593027046',
          storageBucket: 'gen-lang-client-0593027046.firebasestorage.app',
          messagingSenderId: '243339744043',
          appId: '1:243339744043:web:58ca5e016c928823adab6e',
        ),
      );
    } else {
      // Android / iOS: tự đọc cấu hình từ google-services.json
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase init lỗi: $e');
  }

  await LocalStorage.init();
  // Đọc token đăng nhập đã lưu (backend Spring Boot cấp khi đăng nhập)
  ApiClient.instance.init();

  // Đã đăng nhập / đã chọn "Bỏ qua" ở lần trước -> vào thẳng Trang chủ
  final initialRoute = ProfileViewModel.hasActiveSession ? AppConstants.routeHome : AppConstants.routeLogin;

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, this.initialRoute = AppConstants.routeLogin});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        // Trang chủ tự tải lại gợi ý mỗi khi hồ sơ ăn uống trên server thay đổi
        ChangeNotifierProxyProvider<ProfileViewModel, HomeViewModel>(
          create: (_) => HomeViewModel(),
          update: (_, profileVm, homeVm) => (homeVm ?? HomeViewModel())..onPreferencesChanged(profileVm.preferencesVersion),
        ),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => FilterViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => RestaurantViewModel()),
        ChangeNotifierProvider(create: (_) => ChatbotViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
      ],
      child: RootApp(initialRoute: initialRoute),
    );
  }
}

class RootApp extends StatelessWidget {
  final String initialRoute;

  const RootApp({super.key, this.initialRoute = AppConstants.routeLogin});

  @override
  Widget build(BuildContext context) {
    final languageVm = context.watch<LanguageViewModel>();

    return MaterialApp(
      title: 'N12 DoAnCn - Hôm Nay Ăn Gì',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: languageVm.currentLocale,
      scrollBehavior: AppScrollBehavior(),
      initialRoute: initialRoute,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}