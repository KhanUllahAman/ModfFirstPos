import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/AppWidgets/appinfo_dailog_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class PosNavItem {
  final String route;
  final IconData icon;
  final String label;

  const PosNavItem({
    required this.route,
    required this.icon,
    required this.label,
  });
}

class PosSideNav extends StatelessWidget {
  final String? currentRouteOverride;
  final Color? backgroundColor;

  const PosSideNav({
    super.key,
    this.currentRouteOverride,
    this.backgroundColor,
  });

  static const List<PosNavItem> navItems = [
    PosNavItem(
      route: Routes.home,
      icon: Iconsax.home_2,
      label: 'Home',
    ),
    PosNavItem(
      route: Routes.catalogue,
      icon: Iconsax.category,
      label: 'Category',
    ),
    PosNavItem(
      route: Routes.order,
      icon: Iconsax.receipt_2_1,
      label: 'Orders',
    ),
    PosNavItem(
      route: Routes.customer,
      icon: Iconsax.profile_2user,
      label: 'Users',
    ),
    PosNavItem(
      route: Routes.profile,
      icon: Iconsax.profile_circle,
      label: 'Profile',
    ),
    PosNavItem(
      route: Routes.setting,
      icon: Iconsax.setting_2,
      label: 'Setting',
    ),
  ];

  void _onItemTap(String route) {
    final activeRoute = currentRouteOverride ?? Get.currentRoute;
    if (activeRoute == route) return;

    Get.offAllNamed(route);
  }

  void _onLogoutTap(BuildContext context) {
    AppDialog.showConfirm(
      context,
      title: "Log Out",
      message: "Are you sure",
      subMessage: "You want to log out.",
      image: Image.asset(
        ImagesConstant.logout,
        height: context.responsiveHeight(0.20),
        width: context.responsiveWidth(0.20),
      ),
      onYes: () async {
        await SecureStorageService.clearAll();
        Get.offAllNamed(Routes.storeSelection);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Obx(() {
      final navBgColor =
          backgroundColor ??
          (theme.hasThemeData.value
              ? theme.primaryColor.value
              : ColorResources.blackColor);

      final activeRoute = currentRouteOverride ?? Get.currentRoute;
      final selectedIndex = navItems.indexWhere(
        (item) => item.route == activeRoute,
      );

      return Container(
        width: 54,
        margin: const EdgeInsets.fromLTRB(10, 10, 4, 10),
        decoration: BoxDecoration(
          color: navBgColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Top Menu Icon (Navigates to full Menu Screen)
            Tooltip(
              message: 'Menu Screen',
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Get.toNamed(Routes.menu),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.secondaryColor.value.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Iconsax.category_2,
                    color: theme.secondaryColor.value,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(
              height: 1,
              indent: 10,
              endIndent: 10,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            // Nav Items List
            Expanded(
              child: ListView.separated(
                primary: false,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                itemCount: navItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = navItems[index];
                  final isSelected = index == selectedIndex;

                  return Tooltip(
                    message: item.label,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _onItemTap(item.route),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.secondaryColor.value.withOpacity(0.14)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(),
                              Icon(
                                item.icon,
                                size: 22,
                                color: isSelected
                                    ? theme.secondaryColor.value
                                    : theme.onPrimaryColor.withOpacity(0.65),
                              ),
                              const Spacer(),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                height: 3.5,
                                width: isSelected ? 22 : 0,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.secondaryColor.value
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: theme.secondaryColor.value
                                                .withOpacity(0.6),
                                            blurRadius: 6,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 3),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom Logout Button
            const Divider(
              height: 1,
              indent: 10,
              endIndent: 10,
              color: Colors.white24,
            ),
            const SizedBox(height: 12),
            Tooltip(
              message: 'Log Out',
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _onLogoutTap(context),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: const Icon(
                    Iconsax.logout_1,
                    color: ColorResources.gradientRed,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    });
  }
}
