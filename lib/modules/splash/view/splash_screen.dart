import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/modules/splash/controller/splash_controller.dart';
import '../../../core/utils/colors.dart';
import '../../../shared/widgets/ScreenSize/screen_size_utils.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: GetBuilder<SplashController>(
        init: SplashController(),
        builder: (_) => Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: ColorResources.appGradient,
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  SvgPicture.asset(
                    ImagesConstant.mJafferjeesLogo,
                    height: context.responsiveHeight(0.20),
                  ),
                  SizedBox(height: context.spacingLG),
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
