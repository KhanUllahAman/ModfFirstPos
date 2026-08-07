import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/push_notification_service.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/modules/auth/service/auth_service.dart';
import 'package:modfirstpos/modules/shift/controller/shift_controller.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/AppWidgets/appinfo_dailog_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

/// Single guarded logout flow shared by every "Log Out" entry point (nav
/// drawer, Menu > System, etc) so the active-shift check can't drift
/// between call sites.
class AppLogout {
  AppLogout._();

  static void attempt(BuildContext context, {bool checkActiveShift = true}) {
    if (checkActiveShift &&
        Get.isRegistered<ShiftController>() &&
        Get.find<ShiftController>().currentShift.value != null) {
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
        // Best-effort — a failed/offline logout call shouldn't block the
        // local logout; the device just keeps receiving push until the
        // token naturally expires or the next successful call.
        try {
          final fcmToken = Get.isRegistered<PushNotificationService>()
              ? await Get.find<PushNotificationService>().getToken()
              : null;
          await AuthService().logout(fcmToken: fcmToken);
        } catch (e) {
          log('AppLogout: logout API call failed: $e');
        }
        await SecureStorageService.clearAll();
        if (Get.isRegistered<ShiftController>()) {
          Get.find<ShiftController>().resetForLogout();
        }
        Get.offAllNamed(Routes.storeSelection);
      },
    );
  }
}
