import 'package:get/get.dart';
import 'package:modfirstpos/modules/auth/binding/auth_binding.dart';
import 'package:modfirstpos/modules/errorScreen/error_screen.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import '../modules/splash/binding/splash_binding.dart';
import '../modules/splash/view/splash_screen.dart';
import '../modules/auth/view/auth_view.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
      transition: Transition.leftToRightWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.error404Route,
      page: () => const Error404View(),
      transition: Transition.leftToRightWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
