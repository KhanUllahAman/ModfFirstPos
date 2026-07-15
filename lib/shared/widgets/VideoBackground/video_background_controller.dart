import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoBackgroundController extends GetxController {
  final String assetPath;
  late VideoPlayerController videoController;
  final RxBool isReady = false.obs;

  VideoBackgroundController({required this.assetPath});

  @override
  void onInit() {
    super.onInit();
    _initVideo();
  }

  Future<void> _initVideo() async {
    videoController = VideoPlayerController.asset(assetPath)
      ..setLooping(true)
      ..setVolume(0);
    await videoController.initialize();
    isReady.value = true;
    videoController.play();
  }

  @override
  void onClose() {
    videoController.dispose();
    super.onClose();
  }
}
