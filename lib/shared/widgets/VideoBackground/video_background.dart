import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'video_background_controller.dart';

class VideoBackground extends StatelessWidget {
  final String assetPath;
  final Color overlayColor;
  final double overlayOpacity;

  const VideoBackground({
    super.key,
    required this.assetPath,
    this.overlayColor = Colors.black,
    this.overlayOpacity = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    final tag = 'video_bg_$assetPath';
    if (!Get.isRegistered<VideoBackgroundController>(tag: tag)) {
      Get.put(VideoBackgroundController(assetPath: assetPath), tag: tag);
    }
    final ctrl = Get.find<VideoBackgroundController>(tag: tag);

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Obx(() {
              if (!ctrl.isReady.value) return const SizedBox.shrink();
              return FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: ctrl.videoController.value.size.width,
                  height: ctrl.videoController.value.size.height,
                  child: VideoPlayer(ctrl.videoController),
                ),
              );
            }),
            Container(
              color: overlayColor.withOpacity(overlayOpacity),
            ),
          ],
        ),
      ),
    );
  }
}