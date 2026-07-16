import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/modules/pin/controller/pin_controller.dart';
import 'package:modfirstpos/shared/widgets/DynamicImage/dynamic_network_image.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

  class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
    const AppTopBar({
      super.key,
      this.showMenuIcon = true,
      this.onMenuPressed,
      this.showBackIcon = false,
      this.onBackPressed,
      this.height,
    });

    final bool showMenuIcon;
    final VoidCallback? onMenuPressed;
    final bool showBackIcon;
    final VoidCallback? onBackPressed;
    final double? height;

    @override
    Size get preferredSize => Size.fromHeight(height ?? 85.0);

    @override
    Widget build(BuildContext context) {
      final theme = Get.find<AppThemeService>();

      return Obx(() {
        final bgColor = theme.primaryColor.value;
        final iconColor = theme.onPrimaryColor; 

        return Container(
          width: double.infinity,
          height: preferredSize.height,
          decoration: BoxDecoration(
            borderRadius: const BorderRadiusDirectional.only(
              bottomEnd: Radius.circular(16.0),
              bottomStart: Radius.circular(16.0),
            ),
            color: bgColor,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveWidth(0.025),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (showMenuIcon || showBackIcon)
                          _IconBtn(
                            icon: showBackIcon
                                ? ImagesConstant.closeIcon
                                : ImagesConstant.menuIcon,
                            color: iconColor,
                            onPressed: showBackIcon
                                ? (onBackPressed ?? () => Get.back())
                                : onMenuPressed,
                          ),
                        SizedBox(width: context.responsiveWidth(0.035)),
                        DynamicAppLogo(height: context.responsiveHeight(0.028)),
                      ],
                    ),
                  ),
                  Obx(() {
                    final pinController = Get.find<PinController>();
                    if (!pinController.pinEnabled.value) {
                      return const SizedBox.shrink();
                    }
                    return GestureDetector(
                      onTap: pinController.lockNow,
                      child: Icon(Icons.lock_outline, color: iconColor, size: 18),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      });
    }
  }

  class _IconBtn extends StatelessWidget {
    const _IconBtn({required this.icon, required this.color, this.onPressed});

    final String icon;
    final Color color;
    final VoidCallback? onPressed;

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: onPressed,
        child: SvgPicture.asset(
          icon,
          width: 15,
          height: 15,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      );
    }
  }