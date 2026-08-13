import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';
import 'package:modfirstpos/modules/pin/controller/pin_controller.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/helperFunction/logout_helper.dart';
import 'package:modfirstpos/shared/widgets/numpad/pin_numpad.dart';

class LockScreenView extends GetView<PinController> {
  const LockScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
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
                        Obx(() => Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.primaryColor.value
                                    .withOpacity(0.15),
                              ),
                              child: Icon(
                                Icons.lock_outline_rounded,
                                color: theme.primaryColor.value,
                                size: 32,
                              ),
                            )),
                        SizedBox(height: context.spacingMD),
                        Text(
                          'Screen Locked',
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
                              'Enter PIN to continue as $name',
                              textAlign: TextAlign.center,
                              style: AppFonts.geistMono(
                                fontSize: context.fontXS,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: context.spacingXL),
                        Obx(() => PinDotsIndicator(
                              enteredLength: controller.enteredPin.value.length,
                              maxLength: 4,
                              activeColor: theme.primaryColor.value,
                              inactiveColor: Colors.white.withOpacity(0.3),
                            )),
                        SizedBox(
                          height: 28,
                          child: Obx(
                            () => controller.verifyError.value.isNotEmpty
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        top: context.spacingSM),
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
                                  padding:
                                      EdgeInsets.symmetric(vertical: 24),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : PinNumpad(
                                  onDigitPressed: controller.onPinDigit,
                                  onBackspacePressed:
                                      controller.onPinBackspace,
                                ),
                        ),
                        SizedBox(height: context.spacingSM),
                        TextButton(
                          onPressed: () =>
                              // LockScreenView is rendered outside the app's
                              // Navigator (AppLockWrapper overlays it above
                              // `child`), so the local `context` has no
                              // Navigator ancestor for showDialog() to find —
                              // use GetX's root navigator context instead.
                              // No dialogs here at all (not even the active
                              // shift check) — from a locked screen this must
                              // log out immediately, every time.
                              AppLogout.attemptInstant(
                                Get.context!,
                                checkActiveShift: false,
                              ),
                          child: Text(
                            'Logout Instantly',
                            style: AppFonts.geistMono(
                              fontSize: context.fontXS,
                              fontWeight: FontWeight.w600,
                              color: Colors.redAccent.shade100,
                            ),
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
