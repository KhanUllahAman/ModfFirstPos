import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/auth/widget/auth_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';
import '../../../shared/widgets/ScreenSize/screen_size_utils.dart';
import '../controller/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: ColorResources.backgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveWidth(0.03),
              vertical: context.responsiveHeight(0.03),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 9, child: WelcomeBannerCard(context: context)),
                SizedBox(width: context.responsiveWidth(0.03)),
                Expanded(
                  flex: 9,
                  child: Column(
                    children: [
                      Expanded(child: LoginFormCard(controller: controller)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).noKeyboard();
  }
}