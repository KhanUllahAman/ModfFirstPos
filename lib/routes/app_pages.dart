import 'package:get/get.dart';
import 'package:modfirstpos/modules/about/binding/about_binding.dart';
import 'package:modfirstpos/modules/about/view/about_view.dart';
import 'package:modfirstpos/modules/categoryProducts/binding/category_products_binding.dart';
import 'package:modfirstpos/modules/categoryProducts/view/category_products_view.dart';
import 'package:modfirstpos/modules/changePassword/bindings/change_password_binding.dart';
import 'package:modfirstpos/modules/changePassword/view/change_password_view.dart';
import 'package:modfirstpos/modules/menu/view/menu_view.dart';
import 'package:modfirstpos/modules/auth/binding/auth_binding.dart';
import 'package:modfirstpos/modules/catalogue/binding/catalogue_binding.dart';
import 'package:modfirstpos/modules/catalogue/view/catalogue_view.dart';
import 'package:modfirstpos/modules/errorScreen/error_screen.dart';
import 'package:modfirstpos/modules/forgotPassword/binding/forgot_password_binding.dart';
import 'package:modfirstpos/modules/forgotPassword/view/forgot_password_view.dart';
import 'package:modfirstpos/modules/home/binding/home_binding.dart';
import 'package:modfirstpos/modules/home/view/home_view.dart';
import 'package:modfirstpos/modules/pin/binding/pin_settings_binding.dart';
import 'package:modfirstpos/modules/pin/binding/set_pin_binding.dart';
import 'package:modfirstpos/modules/pin/view/pin_settings_view.dart';
import 'package:modfirstpos/modules/pin/view/set_pin_view.dart';
import 'package:modfirstpos/modules/productVariant/binding/product_variant_binding.dart';
import 'package:modfirstpos/modules/productVariant/view/product_variant_view.dart';
import 'package:modfirstpos/modules/profile/binding/get_profile_binding.dart';
import 'package:modfirstpos/modules/profile/binding/update_profile_binding.dart';
import 'package:modfirstpos/modules/profile/view/get_profile_view.dart';
import 'package:modfirstpos/modules/profile/view/update_profile_view.dart';
import 'package:modfirstpos/modules/storeSelection/binding/store_selection_binding.dart';
import 'package:modfirstpos/modules/storeSelection/view/store_selection_view.dart';
import 'package:modfirstpos/modules/verifyOtp/binding/verify_otp_binding.dart';
import 'package:modfirstpos/modules/verifyOtp/view/verify_otp_view.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/modules/order/binding/order_binding.dart';
import 'package:modfirstpos/modules/order/view/order_view.dart';
import 'package:modfirstpos/modules/setting/binding/setting_binding.dart';
import 'package:modfirstpos/modules/setting/view/setting_view.dart';
import '../modules/splash/binding/splash_binding.dart';
import '../modules/splash/view/splash_screen.dart';
import '../modules/auth/view/auth_view.dart';
import 'package:modfirstpos/modules/notification/binding/notification_binding.dart';
import 'package:modfirstpos/modules/notification/view/notification_view.dart';
import 'package:modfirstpos/modules/customer/binding/customer_binding.dart';
import 'package:modfirstpos/modules/customer/view/customer_view.dart';

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
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.verifyOtp,
      page: () => const VerifyOtpView(),
      binding: VerifyOtpBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const GetProfileView(),
      binding: GetProfileViewBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.updateProfile,
      page: () => const UpdateProfileView(),
      binding: UpdateProfileBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.changePassword,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.catalogue,
      page: () => const CatalogueView(),
      binding: CatalogueBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.menu,
      page: () => const MenuView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.setPin,
      page: () => const SetPinView(),
      binding: SetPinBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.pinSettings,
      page: () => const PinSettingsView(),
      binding: PinSettingsBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.storeSelection,
      page: () => const StoreSelectionView(),
      binding: StoreSelectionBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.about,
      page: () => const AboutView(),
      binding: AboutBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.categoryProducts,
      page: () => const CategoryProductsView(),
      binding: CategoryProductsBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.productVariant,
      page: () => const ProductVariantView(),
      binding: ProductVariantBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.order,
      page: () => const OrderView(),
      binding: OrderBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.customer,
      page: () => const CustomerView(),
      binding: CustomerBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.setting,
      page: () => const SettingView(),
      binding: SettingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.notification,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: Routes.error404Route,
      page: () => const Error404View(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
