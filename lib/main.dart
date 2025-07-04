import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:easy_localization/easy_localization.dart' hide TextDirection;
// import 'package:easy_localization/easy_localization.dart' show RootBundleAssetLoader;
import 'dart:ui' as ui;

import 'constants/app_theme.dart';
import 'services/api_service.dart';
import 'services/activity_service.dart';
import 'services/auth_service.dart';
import 'models/property.dart';
import 'controllers/main_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/properties_controller.dart';
import 'controllers/client_dashboard_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/investment_controller.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/property_details_screen.dart';
import 'screens/search_screen.dart';
import 'screens/properties_list_screen.dart';
import 'screens/map_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/client_dashboard_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/investment_dashboard_screen.dart';

// ✅ تم حل مشكلة الصور - لا نحتاج أداة التشخيص
// import 'utils/image_diagnostic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage
  await GetStorage.init();
  
  // Initialize EasyLocalization - REMOVED
  // await EasyLocalization.ensureInitialized();
  
  // Initialize services
  Get.put(ApiService());
  Get.put(ActivityService());
  
  // Initialize controllers
  Get.put(NotificationController());
  Get.put(MainController());
  Get.put(HomeController());
  Get.put(PropertiesController());
  
  // Initialize AuthController with fenix for auto-recreation
  Get.lazyPut(() => AuthController(), fenix: true);
  
  // Initialize InvestmentController
  Get.lazyPut(() => InvestmentController(), fenix: true);

  // ✅ تم حل مشكلة الصور باستخدام Image Proxy
  // _testProblematicImageUrl();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const AlbrogApp());
}

// ✅ تم حل مشكلة الصور باستخدام Image Proxy API
// void _testProblematicImageUrl() async {
//   const problematicUrl = 'https://albrog.com/wp-content/uploads/2025/05/مشروع-204-بحي-المنار-بجدة-مكبرة-1.jpg';
//   
//   print('🔍 اختبار الرابط المُشكِل...');
//   print('📎 الرابط الأصلي: $problematicUrl');
//   
//   final result = await ImageDiagnostic.testImageUrl(problematicUrl);
//   
//   print('📊 نتيجة الاختبار:');
//   print(result.toString());
//   
//   if (result.cleanUrl != null && result.cleanUrl != problematicUrl) {
//     print('🔧 الرابط المُنظف: ${result.cleanUrl}');
//   }
// }

class AlbrogApp extends StatelessWidget {
  const AlbrogApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'شركة البروج',
      debugShowCheckedModeBanner: false,
      
      // Arabic locale
      locale: const Locale('ar'),
      fallbackLocale: const Locale('ar'),
      
      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      
      // RTL Support - FIXED: Using ui.TextDirection to avoid conflicts
      builder: (context, child) {
        return Directionality(
          textDirection: ui.TextDirection.rtl, // Using ui.TextDirection for RTL support
          child: child!,
        );
      },
      
      // Routes
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashScreen(),
          transition: Transition.fade,
        ),
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/main',
          page: () => const MainScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/property-details',
          page: () {
            final Property? property = Get.arguments as Property?;
            if (property == null) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'لم يتم العثور على تفاصيل العقار',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              );
            }
            return PropertyDetailsScreen(property: property);
          },
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/search',
          page: () => const SearchScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/properties',
          page: () => const PropertiesListScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/map',
          page: () => const MapScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/favorites',
          page: () => const FavoritesScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfileScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/settings',
          page: () => const SettingsScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/client-dashboard',
          page: () => const ClientDashboardScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/notifications',
          page: () => const NotificationScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/investment-dashboard',
          page: () => const InvestmentDashboardScreen(),
          transition: Transition.rightToLeft,
        ),
      ],
      
      // Unknown Route
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const Scaffold(
          body: Center(
            child: Text('صفحة غير موجودة'),
          ),
        ),
      ),
    );
  }
}