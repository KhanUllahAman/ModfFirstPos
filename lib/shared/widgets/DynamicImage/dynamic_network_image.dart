// lib/shared/widgets/DynamicImage/dynamic_network_image.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';

enum LogoVariant { black, white }

class DynamicAppLogo extends StatelessWidget {
  final double height;

  /// Which logo color to prefer — [LogoVariant.black] for light
  /// backgrounds (login, splash), [LogoVariant.white] for dark ones (home
  /// top bar, nav drawer). Falls back to the generic `logo_url` when the
  /// store didn't send that specific variant.
  final LogoVariant variant;

  const DynamicAppLogo({
    super.key,
    required this.height,
    this.variant = LogoVariant.black,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Obx(() {
      final variantUrl = variant == LogoVariant.white
          ? theme.logoWhiteUrl.value
          : theme.logoBlackUrl.value;
      final logoUrl = variantUrl.isNotEmpty ? variantUrl : theme.logoUrl.value;

      if (logoUrl.isNotEmpty) {
        return CachedNetworkImage(
          imageUrl: logoUrl,
          height: height,
          fit: BoxFit.contain,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          placeholderFadeInDuration: Duration.zero,
          placeholder: (_, __) =>
              SvgPicture.asset(ImagesConstant.mJafferjeesLogo, height: height),
          errorWidget: (_, __, ___) =>
              SvgPicture.asset(ImagesConstant.mJafferjeesLogo, height: height),
        );
      }

      return SvgPicture.asset(ImagesConstant.mJafferjeesLogo, height: height);
    });
  }
}
