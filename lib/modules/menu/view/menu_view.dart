import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/services/sync_service.dart';
import 'package:modfirstpos/core/services/website_settings_service.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/menu/widget/menu_widget.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/AppWidgets/appinfo_dailog_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/helperFunction/get_device_id_function.dart';
import 'package:modfirstpos/shared/widgets/helperFunction/logout_helper.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';

import 'package:modfirstpos/shared/widgets/sideNav/app_nav_drawer.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: ColorResources.backgroundColor,
        appBar: AppTopBar(showBackIcon: true),
        drawer: const AppNavDrawer(),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
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
            ],
          ),
        ),
      ),
    ).noKeyboard();
  }
}

class _MainTab extends StatelessWidget {
  const _MainTab();

  /// Re-fetches the website settings from the API, updates the local cache
  /// and applies the latest theme/branding immediately.
  Future<void> _refreshWebsiteSettings() async {
    final storeSlug = await SecureStorageService.getSelectedStore();
    if (storeSlug == null || storeSlug.trim().isEmpty) {
      customSnackBar(
        'No Store Selected',
        'Select a store before refreshing website settings',
        snackBarType: SnackBarType.warning,
      );
      return;
    }
    try {
      final response = await WebsiteSettingsService()
          .fetchAndSaveWebsiteSettings(storeSlug);
      if (response.isSuccess) {
        // Apply theme, colors, branding and configuration immediately.
        await Get.find<AppThemeService>().refreshFromStorage();
        customSnackBar(
          'Settings Refreshed',
          'Latest website settings applied',
          snackBarType: SnackBarType.success,
        );
      } else {
        customSnackBar(
          'Refresh Failed',
          response.message.isNotEmpty
              ? response.message
              : 'Could not refresh website settings',
          snackBarType: SnackBarType.error,
        );
      }
    } catch (e) {
      customSnackBar(
        'Refresh Failed',
        'Could not reach the server. Cached settings remain active.',
        snackBarType: SnackBarType.error,
      );
    }
  }

  Future<void> _syncAndReport({
    required String label,
    required Future<SyncSummary> Function() run,
  }) async {
    final summary = await run();
    if (summary.total == 0) {
      customSnackBar(
        '$label Sync',
        'Nothing to sync — everything is already up to date.',
        snackBarType: SnackBarType.info,
      );
      return;
    }
    customSnackBar(
      '$label Sync',
      '${summary.synced} synced, ${summary.duplicates} duplicate, ${summary.failed} failed.',
      snackBarType: summary.failed > 0
          ? SnackBarType.warning
          : SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      padding: EdgeInsets.fromLTRB(
        context.spacingMD,
        context.spacingSM,
        context.spacingMD,
        context.spacingMD,
      ),
      children: [
        MenuSectionCard(
          title: "Qucick Actions",
          children: [
            MenuList(
              menuIcon: Icons.grid_view_rounded,
              menuTitle: 'Category',
              menuTap: () => Get.toNamed(Routes.catalogue),
            ),
            MenuList(
              menuIcon: Icons.receipt_long_rounded,
              menuTitle: 'Orders',
              menuTap: () {
                Get.toNamed(Routes.order);
              },
            ),
            // MenuList(
            //   menuIcon: Icons.search_rounded,
            //   menuTitle: 'Search',
            //   menuTap: () {
            //     // Get.toNamed(Routes.searchSku);
            //   },
            // ),
          ],
        ),
        SizedBox(height: context.spacingMD),
        MenuSectionCard(
          title: "Operations",
          children: [
            // MenuList(
            //   menuIcon: Icons.notifications_rounded,
            //   menuTitle: 'Notification',
            //   menuTap: () {
            //     Get.toNamed(Routes.notification);
            //   },
            // ),
            Obx(
              () => MenuList(
                menuIcon: Icons.cloud_sync_rounded,
                menuTitle: 'Sync Pending Items',
                badgeCount: Get.find<SyncService>().pendingCount.value,
                menuTap: () async {
                  final sync = Get.find<SyncService>();
                  await sync.syncNow();
                  await sync.refreshPendingCount();
                  if (sync.pendingCount.value == 0) {
                    customSnackBar(
                      'Sync',
                      'Everything is synced — nothing pending.',
                      snackBarType: SnackBarType.success,
                    );
                  } else {
                    customSnackBar(
                      'Sync',
                      '${sync.pendingCount.value} item(s) still pending — will retry automatically.',
                      snackBarType: SnackBarType.warning,
                    );
                  }
                },
              ),
            ),
            MenuList(
              menuIcon: Icons.refresh_rounded,
              menuTitle: 'Refresh Website Settings',
              menuTap: _refreshWebsiteSettings,
            ),
            MenuList(
              menuIcon: Icons.cloud_sync_rounded,
              menuTitle: 'Sync Shifts',
              menuTap: () => _syncAndReport(
                label: 'Shifts',
                run: () => Get.find<SyncService>().syncShiftsNow(),
              ),
            ),
            MenuList(
              menuIcon: Icons.cloud_sync_rounded,
              menuTitle: 'Sync Orders',
              menuTap: () => _syncAndReport(
                label: 'Orders',
                run: () => Get.find<SyncService>().syncOrdersNow(),
              ),
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
      primary: false,
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
      primary: false,
      padding: EdgeInsets.all(context.spacingMD),
      children: [
        MenuSectionCard(
          title: "System",
          children: [
            MenuList(
              menuIcon: Icons.settings_rounded,
              menuTitle: 'Setting',
              menuTap: () => Get.toNamed(Routes.setting),
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
          ],
        ),
        SizedBox(height: context.spacingSM),
        MenuSectionCard(
          children: [
            MenuList(
              menuIcon: Icons.logout_rounded,
              menuTitle: 'Log Out',
              menuColor: MenuTileColor.destructive,
              menuTap: () => AppLogout.attempt(context),
            ),
          ],
        ),
      ],
    );
  }
}
