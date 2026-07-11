import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/modules/menu/widget/menu_widget.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/AppWidgets/appinfo_dailog_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/helperFunction/get_device_id_function.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorResources.backgroundColor,
        appBar: AppTopBar(showMenuIcon: false, showBackIcon: true),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.spacingMD,
                  context.spacingSM,
                  context.spacingMD,
                  context.spacingXS,
                ),
                child: const MenuSegmentedTabs(
                  labels: ["Main", "Account", "System"],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [_MainTab(), _AccountTab(), _SystemTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    ).noKeyboard();
  }
}

class _MainTab extends StatelessWidget {
  const _MainTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.spacingMD,
        context.spacingSM,
        context.spacingMD,
        context.spacingMD,
      ),
      children: [
        MenuHeroAction(
          icon: Icons.home_rounded,
          title: 'Home',
          subtitle: 'Go to dashboard',
          onTap: () => Get.offAllNamed(Routes.home),
        ),
        SizedBox(height: context.spacingMD),
        MenuSectionCard(
          title: "Qucick Actions",
          children: [
            MenuList(
              menuIcon: Icons.grid_view_rounded,
              menuTitle: 'Catalogue',
              menuTap: () => Get.toNamed(Routes.catalogue),
            ),
            MenuList(
              menuIcon: Icons.receipt_long_rounded,
              menuTitle: 'Orders',
              menuTap: () {
                // Get.toNamed(Routes.order);
              },
            ),
            MenuList(
              menuIcon: Icons.search_rounded,
              menuTitle: 'Search',
              menuTap: () {
                // Get.toNamed(Routes.searchSku);
              },
            ),
          ],
        ),
        SizedBox(height: context.spacingMD),
        MenuSectionCard(
          title: "Operations",
          children: [
            MenuList(
              menuIcon: Icons.assignment_return_rounded,
              menuTitle: 'Item Return',
              menuTap: () {},
            ),
            MenuList(
              menuIcon: Icons.account_balance_wallet_rounded,
              menuTitle: 'Received on Account',
              menuTap: () {
                AppDialog.showSearchList(
                  context,
                  title: "Received On Account",
                  items: [
                    AppDialogListItem(
                      id: "6-18-1",
                      name: "Shaukat Ali",
                      trailing: "Rs. 0",
                    ),
                    AppDialogListItem(
                      id: "6-18-1",
                      name: "Saleem Iqbal",
                      trailing: "Rs. 0",
                    ),
                  ],
                  onItemTap: (item) => print(item.name),
                );
              },
            ),
            MenuList(
              menuIcon: Icons.payments_rounded,
              menuTitle: 'Expense',
              menuTap: () {
                AppDialog.showInput(
                  context,
                  title: "Credit Voucher Refund",
                  inputLabel: "Enter Voucher Number",
                  onConfirm: (val) => log(val),
                );
              },
            ),
            MenuList(
              menuIcon: Icons.notifications_rounded,
              menuTitle: 'Notification',
              menuTap: () {
                // Get.toNamed(Routes.notification);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(context.spacingMD),
      children: [
        MenuSectionCard(
          title: "Account",
          children: [
            MenuList(
              menuIcon: Icons.person_rounded,
              menuTitle: 'Profile',
              menuTap: () => Get.toNamed(Routes.profile),
            ),
            MenuList(
              menuIcon: Icons.lock_reset_rounded,
              menuTitle: 'Change Password',
              menuTap: () => Get.toNamed(Routes.changePassword),
            ),
            MenuList(
              menuIcon: Icons.pin_rounded,
              menuTitle: 'Pin Settings',
              menuTap: () => Get.toNamed(Routes.pinSettings),
            ),
          ],
        ),
      ],
    );
  }
}

class _SystemTab extends StatelessWidget {
  const _SystemTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(context.spacingMD),
      children: [
        MenuSectionCard(
          title: "System",
          children: [
            MenuList(
              menuIcon: Icons.bar_chart_rounded,
              menuTitle: 'X Report',
              menuTap: () {},
            ),
            MenuList(
              menuIcon: Icons.settings_rounded,
              menuTitle: 'Setting',
              menuTap: () => {},
            ),
            MenuList(
              menuIcon: Icons.system_update_alt_rounded,
              menuTitle: 'Update',
              menuTap: () => Get.toNamed(Routes.updateModule),
            ),
            MenuList(
              menuIcon: Icons.perm_device_information_rounded,
              menuTitle: 'Device Id',
              menuTap: () async {
                final id = await AppInfo.getDeviceId();
                AppDialog.showInfo(context, title: "Device ID", content: id);
              },
            ),
            MenuList(
              menuIcon: Icons.info_rounded,
              menuTitle: 'Version',
              menuTap: () async {
                final version = await AppInfo.getAppVersion();
                AppDialog.showInfo(context, title: "Version", content: version);
              },
            ),
            MenuList(
              menuIcon: Icons.info_outline_rounded,
              menuTitle: 'About',
              menuTap: () => Get.toNamed(Routes.about),
            ),
            MenuList(
              menuIcon: Icons.access_time_filled_rounded,
              menuTitle: 'Shift Close',
              menuTap: () {},
            ),
          ],
        ),
        SizedBox(height: context.spacingSM),
        MenuSectionCard(
          children: [
            MenuList(
              menuIcon: Icons.logout_rounded,
              menuTitle: 'Log Out',
              menuColor: MenuTileColor.destructive,
              menuTap: () {
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
              },
            ),
          ],
        ),
      ],
    );
  }
}
