// lib/shared/widgets/DynamicImage/dynamic_network_image.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';

class DynamicAppLogo extends StatelessWidget {
  final double height;
  const DynamicAppLogo({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Obx(() {
      final logoUrl = theme.logoUrl.value;

      if (logoUrl.isNotEmpty) {
        return CachedNetworkImage(
          imageUrl: logoUrl,
          height: height,
          fit: BoxFit.contain,
          fadeInDuration: Duration.zero,        
          fadeOutDuration: Duration.zero,     
          placeholderFadeInDuration: Duration.zero,
          placeholder: (_, __) => SvgPicture.asset(
            color: theme.secondaryColor.value,
            ImagesConstant.mJafferjeesLogo,
            height: height,
          ),
          errorWidget: (_, __, ___) => SvgPicture.asset(
            color: theme.secondaryColor.value,
            ImagesConstant.mJafferjeesLogo,
            height: height,
          ),
        );
      }

      return SvgPicture.asset(
        color: theme.secondaryColor.value,
        ImagesConstant.mJafferjeesLogo,
        height: height,
      );
    });
  }
}