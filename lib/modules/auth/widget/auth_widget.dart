import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/modules/auth/controller/auth_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';
 
class WelcomeBannerCard extends StatelessWidget {
  final BuildContext context;
  const WelcomeBannerCard({super.key, required this.context});
 
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorResources.appMainColor,
              ColorResources.appMainColor.withOpacity(0.75),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.08),
                ),
              ),
            ),
 
            // Frosted glass layer
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 1,
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.all(context.spacingMD),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'WELCOME TO MODFIRST',
                              style: GoogleFonts.geistMono(
                                fontSize: context.fontXXL,
                                fontWeight: FontWeight.w700,
                                color: ColorResources.blackColor,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: context.spacingXS),
                            Text(
                              'Fast, accurate, and smooth transactions\nright at the counter.',
                              style: GoogleFonts.geistMono(
                                fontSize: context.fontSM,
                                fontWeight: FontWeight.w400,
                                color: ColorResources.blackColor
                                    .withOpacity(0.85),
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: context.spacingLG),
 
                            _BannerCarousel(
                              height: context.responsiveHeight(0.60),
                              images: const [
                                ImagesConstant.authBannerImage1,
                                ImagesConstant.authBannerImage2,
                                ImagesConstant.authBannerImage3,
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideX(begin: -0.08, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }
}
 
class _BannerCarousel extends StatefulWidget {
  final List<String> images;
  final double height;
 
  const _BannerCarousel({required this.images, required this.height});
 
  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}
 
class _BannerCarouselState extends State<_BannerCarousel> {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentPage = 0;
 
  static const Duration _autoPlayInterval = Duration(seconds: 4);
  static const Duration _animDuration = Duration(milliseconds: 500);
 
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }
 
  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(_autoPlayInterval, (_) {
      if (!mounted || widget.images.length <= 1) return;
      if (!_pageController.hasClients) return;
      final next = (_currentPage + 1) % widget.images.length;
      _pageController.animateToPage(
        next,
        duration: _animDuration,
        curve: Curves.easeInOut,
      );
    });
  }
 
  void _onUserInteraction() {
    _startAutoPlay();
  }
 
  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification) {
                  _onUserInteraction();
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      widget.images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: context.spacingSM),
 
        // Dots indicator
        Row(
          children: List.generate(widget.images.length, (index) {
            final isActive = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: context.spacingXS),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: ColorResources.blackColor.withOpacity(isActive ? 0.95 : 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}


class LoginFormCard extends StatelessWidget {
  final AuthController controller;
  const LoginFormCard({super.key, required this.controller});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: ColorResources.whiteColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE7E9F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: context.spacingLG,
              vertical: context.spacingLG,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SvgPicture.asset(
                      ImagesConstant.mJafferjeesLogo,
                      height: context.responsiveHeight(0.09),
                    ),
                    SizedBox(height: context.spacingSM),
                    Text(
                      'Sign in to your store',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.geistMono(
                        fontSize: context.fontLG,
                        fontWeight: FontWeight.w600,
                        color: ColorResources.blackColor,
                      ),
                    ),
                    SizedBox(height: context.spacingXS),
                    Text(
                      'Enter your store details to continue.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.geistMono(
                        fontSize: context.fontXS,
                        fontWeight: FontWeight.w400,
                        color: ColorResources.blackColor.withOpacity(0.55),
                      ),
                    ),
                    SizedBox(height: context.spacingXL),
                    CustomTextFormField(
                      controller: controller.storeNameController,
                      labelText: 'Store Name',
                      validator: controller.validateStoreName,
                      keyboardType: TextInputType.text,
                      borderRadius: 12,
                      customFocusedBorderColor: ColorResources.blackColor,
                      customEnabledBorderColor: ColorResources.blackColor,
                    ),
                    SizedBox(height: context.spacingSM),
                    Obx(
                      () => CustomTextFormField(
                        controller: controller.passwordController,
                        labelText: 'Password',
                        validator: controller.validatePassword,
                        isPasswordField: true,
                        obscureText: !controller.isPasswordVisible.value,
                        onSuffixIconPressed:
                            controller.togglePasswordVisibility,
                        borderRadius: 12,
                        customFocusedBorderColor: ColorResources.blackColor,
                      customEnabledBorderColor: ColorResources.blackColor,
                      ),
                    ),
                    SizedBox(height: context.spacingMD),
                    AppButton(
                      backgroundColor: ColorResources.mainbuttonColor,
                      onPressed: () {},
                      isLoading: false,
                      borderRadius: 12,
                      child: Text(
                        'Login',
                        style: GoogleFonts.geistMono(
                          fontSize: context.fontMD,
                          fontWeight: FontWeight.w500,
                          color: ColorResources.blackColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}