import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/pin/controller/pin_controller.dart';
import 'package:modfirstpos/modules/pin/view/lock_screen_view.dart';

class AppLockWrapper extends StatelessWidget {
  final Widget? child;

  const AppLockWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final PinController controller = Get.find<PinController>();

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => controller.registerActivity(),
      onPointerMove: (_) => controller.registerActivity(),
      child: Stack(
        children: [
          if (child != null) child!,
          Obx(
            () => controller.isLocked.value
                ? const LockScreenView()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}