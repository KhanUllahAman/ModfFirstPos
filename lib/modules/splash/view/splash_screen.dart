import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/modules/splash/controller/splash_controller.dart';
import 'package:modfirstpos/shared/widgets/DynamicImage/dynamic_network_image.dart';
import '../../../shared/widgets/ScreenSize/screen_size_utils.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Obx(
          () => Container(
            width: double.infinity,
            height: double.infinity,
            decoration: controller.theme.splashDecoration,
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  AnimatedBuilder(
                    animation: controller.animController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: controller.scaleAnimation.value,
                        child: Opacity(
                          opacity: controller.fadeAnimation.value,
                          child: controller.theme.hasThemeData.value
                              ? DynamicAppLogo(
                                  height: context.responsiveHeight(0.18),
                                  variant: LogoVariant.black,
                                )
                              : SvgPicture.asset(
                                  ImagesConstant.mJafferjeesLogo,
                                  color: Colors.black,
                                  height: context.responsiveHeight(0.18),
                                ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: context.spacingLG),
                  Obx(
                    () => CircularProgressIndicator(
                      color: controller.theme.hasThemeData.value
                          ? controller.theme.primaryColor.value
                          : Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
