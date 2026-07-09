import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/pin/controller/set_pin_controller.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/numpad/pin_numpad.dart';

class SetPinView extends GetView<SetPinController> {
  const SetPinView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(showMenuIcon: true, onMenuPressed: () => Get.back()),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(context.responsiveWidth(0.03)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BackBar(title: "Set Screen-Lock PIN"),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: context.spacingLG,
                            horizontal: context.spacingMD,
                          ),
                          decoration: BoxDecoration(
                            color: ColorResources.whiteColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE7E9F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ColorResources.appMainColor
                                      .withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.lock_outline_rounded,
                                  color: ColorResources.appMainColor,
                                  size: 26,
                                ),
                              ),
                              SizedBox(height: context.spacingSM),
                              Obx(
                                () => Text(
                                  controller.stage.value == SetPinStage.enterNew
                                      ? "Enter a new PIN"
                                      : "Confirm your PIN",
                                  style: AppFonts.geistMono(
                                    fontSize: context.fontMD,
                                    fontWeight: FontWeight.w600,
                                    color: ColorResources.blackColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: context.spacingXS),
                              Text(
                                "This PIN will be used to unlock the POS screen",
                                textAlign: TextAlign.center,
                                style: AppFonts.geistMono(
                                  fontSize: context.fontXS,
                                  color: ColorResources.blackColor.withOpacity(
                                    0.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: context.spacingLG),
                              Obx(
                                () => PinDotsIndicator(
                                  enteredLength:
                                      controller.stage.value ==
                                          SetPinStage.enterNew
                                      ? controller.firstPin.value.length
                                      : controller.confirmPin.value.length,
                                  maxLength: 4,
                                  activeColor: ColorResources.appMainColor,
                                  inactiveColor: const Color(0xFFD8DCE5),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                                child: Obx(
                                  () => controller.errorMessage.value.isNotEmpty
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            top: context.spacingSM,
                                          ),
                                          child: Text(
                                            controller.errorMessage.value,
                                            textAlign: TextAlign.center,
                                            style: AppFonts.geistMono(
                                              fontSize: context.fontXS,
                                              color: Colors.red,
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                              SizedBox(height: context.spacingMD),
                              PinNumpad(
                                digitColor: ColorResources.blackColor,
                                buttonFillColor: const Color(0xFFF4F5F8),
                                buttonBorderColor: const Color(0xFFE7E9F0),
                                onDigitPressed: controller.onDigit,
                                onBackspacePressed: controller.onBackspace,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
