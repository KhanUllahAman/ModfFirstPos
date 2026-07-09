import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/modules/splash/controller/splash_controller.dart';
import 'package:modfirstpos/shared/widgets/DynamicImage/dynamic_network_image.dart';
import '../../../shared/widgets/ScreenSize/screen_size_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _logoReady = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareLogo());
  }

  Future<void> _prepareLogo() async {
    final theme = Get.find<AppThemeService>();
    final url = theme.logoUrl.value;

    if (url.isNotEmpty) {
      try {
        await precacheImage(CachedNetworkImageProvider(url), context);
      } catch (_) {
      }
    }

    if (!mounted) return;

    setState(() => _logoReady = true);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: GetBuilder<SplashController>(
        init: SplashController(),
        builder: (_) => Scaffold(
          body: Obx(() => Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: theme.splashGradient,
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),

                  // Jab tak logo ready na ho, khali space rakho —
                  // local SVG bilkul bhi flash nahi hoga
                  if (_logoReady)
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: DynamicAppLogo(
                              height: context.responsiveHeight(0.18),
                            ),
                          ),
                        );
                      },
                    )
                  else
                    SizedBox(height: context.responsiveHeight(0.18)),

                  SizedBox(height: context.spacingLG),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}