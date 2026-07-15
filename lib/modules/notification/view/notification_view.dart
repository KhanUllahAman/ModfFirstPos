import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/notification/controller/notification_controller.dart';
import 'package:modfirstpos/modules/notification/widgets/notification_narrow_layout.dart';
import 'package:modfirstpos/modules/notification/widgets/notification_wide_layout.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';
import 'package:modfirstpos/shared/widgets/sideNav/pos_side_nav.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600 ||
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(showMenuIcon: false),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PosSideNav(currentRouteOverride: Routes.notification),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.responsiveWidth(0.02)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BackBar(title: 'Notifications'),
                    SizedBox(height: context.spacingSM),
                    Expanded(
                      child: isWide
                          ? const NotificationWideLayout()
                          : const NotificationNarrowLayout(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).noKeyboard();
  }
}
