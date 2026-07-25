import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/modules/shift/controller/shift_controller.dart';
import 'package:modfirstpos/modules/shift/widgets/open_shift_dialog.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/AppWidgets/appinfo_dailog_widget.dart';
import 'package:modfirstpos/shared/widgets/DynamicImage/dynamic_network_image.dart';
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

/// App navigation drawer (standard Flutter [Drawer]).
///
/// Opened from the AppTopBar menu icon; replaces the old always-visible
/// [PosSideNav] rail so every screen keeps its full width.
class AppNavDrawer extends StatelessWidget {
  const AppNavDrawer({super.key});

  static const List<PosNavItem> navItems = [
    PosNavItem(route: Routes.home, icon: Iconsax.home_2, label: 'Home'),
    PosNavItem(
      route: Routes.catalogue,
      icon: Iconsax.category,
      label: 'Category',
    ),
    PosNavItem(route: Routes.order, icon: Iconsax.receipt_2_1, label: 'Orders'),
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
    PosNavItem(route: Routes.setting, icon: Iconsax.setting_2, label: 'Setting'),
    PosNavItem(route: Routes.shift, icon: Iconsax.moneys, label: 'Shift'),
    PosNavItem(route: Routes.inventory, icon: Iconsax.box_1, label: 'Inventory'),
    PosNavItem(route: Routes.menu, icon: Iconsax.category_2, label: 'Menu'),
    PosNavItem(
      route: Routes.reporting,
      icon: Iconsax.document_download,
      label: 'Reporting',
    ),
  ];

  void _onItemTap(BuildContext context, String route) {
    Navigator.of(context).pop(); // close the drawer first
    if (Get.currentRoute == route) return;

    // Home stays the root of the stack so the back button (and the system
    // back gesture) always returns to it instead of closing the app.
    if (route == Routes.home) {
      Get.until((r) => r.settings.name == Routes.home || r.isFirst);
      if (Get.currentRoute != Routes.home) {
        Get.offAllNamed(Routes.home);
      }
      return;
    }

    if (Get.currentRoute == Routes.home) {
      Get.toNamed(route);
    } else {
      // Replace the current screen but keep Home underneath.
      Get.offNamedUntil(
        route,
        (r) => r.settings.name == Routes.home || r.isFirst,
      );
    }
  }

  void _onLogoutTap(BuildContext context) {
    Navigator.of(context).pop();

    final hasActiveShift =
        Get.find<ShiftController>().currentShift.value != null;
    if (hasActiveShift) {
      AppDialog.showInfo(
        context,
        title: "Shift Still Open",
        content:
            "You have an active shift. Please close your shift before logging out.",
        buttonText: "OK",
      );
      return;
    }

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
        Get.find<ShiftController>().resetForLogout();
        Get.offAllNamed(Routes.storeSelection);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Obx(() {
      final navBgColor = theme.hasThemeData.value
          ? theme.primaryColor.value
          : ColorResources.blackColor;
      final accent = theme.secondaryColor.value;
      final activeRoute = Get.currentRoute;
      final hasActiveShift = Get.find<ShiftController>().currentShift.value != null;

      return Drawer(
        backgroundColor: navBgColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              DynamicAppLogo(height: context.responsiveHeight(0.032)),
              const SizedBox(height: 20),
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.white24,
              ),
              const SizedBox(height: 12),
              if (!hasActiveShift)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Material(
                    color: accent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(context).pop();
                        OpenShiftDialog.show(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(Iconsax.moneys, size: 22, color: accent),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Open Shift',
                                style: AppFonts.geistMono(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (!hasActiveShift) const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  primary: false,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: navItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = navItems[index];
                    final isSelected = item.route == activeRoute;

                    return Material(
                      color: isSelected
                          ? accent.withOpacity(0.14)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _onItemTap(context, item.route),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 22,
                                color: isSelected
                                    ? accent
                                    : theme.onPrimaryColor.withOpacity(0.65),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: AppFonts.geistMono(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? accent
                                        : theme.onPrimaryColor
                                            .withOpacity(0.85),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.white24,
              ),
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _onLogoutTap(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.logout_1,
                          color: ColorResources.gradientRed,
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Log Out',
                          style: AppFonts.geistMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ColorResources.gradientRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    });
  }
}
