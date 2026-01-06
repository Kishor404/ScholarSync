import 'package:get/get.dart';

import '../bindings/splash_binding.dart';
import '../bindings/home_binding.dart';
import '../views/splash_screen.dart';
import '../views/main_screen.dart';
import '../views/home_screen.dart';
import '../views/cgpa_screen.dart';
import '../views/vault_screen.dart';
import '../views/course_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),

    GetPage(
      name: AppRoutes.main,
      page: () => MainScreen(),
      binding: HomeBinding(),
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => HomeScreen(),
    ),

    GetPage(
      name: AppRoutes.cgpa,
      page: () => CGPAScreen(),
    ),

    GetPage(
      name: AppRoutes.vault,
      page: () => VaultScreen(),
    ),

    GetPage(
      name: AppRoutes.courses,
      page: () => CourseScreen(),
    ),
  ];
}
