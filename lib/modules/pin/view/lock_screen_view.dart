import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/pin/controller/pin_controller.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/numpad/pin_numpad.dart';

class LockScreenView extends StatefulWidget {
  const LockScreenView({super.key});

  @override
  State<LockScreenView> createState() => _LockScreenViewState();
}

class _LockScreenViewState extends State<LockScreenView> {
  final PinController controller = Get.find<PinController>();
  String _enteredPin = '';

  void _onDigit(String digit) {
    if (_enteredPin.length >= 6) return;
    setState(() => _enteredPin += digit);
    controller.verifyError.value = '';
    if (_enteredPin.length == 4) {
      _tryVerify();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    setState(
      () => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1),
    );
  }

  Future<void> _tryVerify() async {
    final pin = _enteredPin;
    final success = await controller.unlockWithPin(pin);
    if (!success) {
      setState(() => _enteredPin = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveWidth(0.06),
                  vertical: context.spacingLG,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: context.spacingXL,
                      horizontal: context.spacingLG,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorResources.appMainColor.withOpacity(
                              0.15,
                            ),
                          ),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            color: ColorResources.appMainColor,
                            size: 32,
                          ),
                        ),
                        SizedBox(height: context.spacingMD),
                        Text(
                          "Screen Locked",
                          style: AppFonts.geistMono(
                            fontSize: context.fontMD,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: context.spacingXS),
                        FutureBuilder<String?>(
                          future: SecureStorageService.getProfileData().then(
                            (d) => d?['full_name']?.toString(),
                          ),
                          builder: (context, snapshot) {
                            final name = snapshot.data;
                            if (name == null || name.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              "Enter PIN to continue as $name",
                              textAlign: TextAlign.center,
                              style: AppFonts.geistMono(
                                fontSize: context.fontXS,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: context.spacingXL),
                        PinDotsIndicator(
                          enteredLength: _enteredPin.length,
                          maxLength: 4,
                        ),
                        SizedBox(
                          height: 28,
                          child: Obx(
                            () => controller.verifyError.value.isNotEmpty
                                ? Padding(
                                    padding: EdgeInsets.only(
                                      top: context.spacingSM,
                                    ),
                                    child: Text(
                                      controller.verifyError.value,
                                      textAlign: TextAlign.center,
                                      style: AppFonts.geistMono(
                                        fontSize: context.fontXS,
                                        color: Colors.redAccent.shade100,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                        SizedBox(height: context.spacingLG),
                        Obx(
                          () => controller.isLoading.value
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : PinNumpad(
                                  onDigitPressed: _onDigit,
                                  onBackspacePressed: _onBackspace,
                                ),
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
    );
  }
}
