import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/home/widgets/home_widget.dart';
import 'package:modfirstpos/modules/productVariant/controller/product_variant_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';

class ProductVariantView extends GetView<ProductVariantController> {
  const ProductVariantView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Scaffold(
      backgroundColor: ColorResources.whiteColor,
      appBar: AppTopBar(showMenuIcon: false, showBackIcon: true),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Padding(
          padding: EdgeInsets.all(context.responsiveWidth(0.025)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: BackBar(title: controller.product.displayName),
                  ),
                  Obx(() {
                    if (!controller.addedToCart.value)
                      return const SizedBox.shrink();
                    return GestureDetector(
                          onTap: controller.goToCart,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.secondaryColor.value,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shopping_cart_rounded,
                                  size: 16,
                                  color: theme.onSecondaryColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Go to Cart',
                                  style: AppFonts.geistMono(
                                    fontSize: context.fontXS,
                                    fontWeight: FontWeight.w700,
                                    color: theme.onSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .fadeIn(duration: 600.ms)
                        .fadeOut(delay: 600.ms, duration: 600.ms);
                  }),
                ],
              ),
              SizedBox(height: context.spacingMD),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProductImage(controller: controller),
                      SizedBox(height: context.spacingMD),
                      Text(
                        controller.product.displayName,
                        style: AppFonts.geistMono(
                          fontSize: context.fontLG,
                          fontWeight: FontWeight.w700,
                          color: ColorResources.labelColor,
                        ),
                      ),
                      if (controller.product.shortDesc != null) ...[
                        SizedBox(height: context.spacingXS),
                        Text(
                          controller.product.shortDesc!,
                          style: AppFonts.geistMono(
                            fontSize: context.fontSM,
                            color: ColorResources.labelColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                      SizedBox(height: context.spacingMD),
                      Obx(
                        () => Text(
                          'Rs. ${controller.displayPrice.toStringAsFixed(0)}',
                          style: AppFonts.geistMono(
                            fontSize: context.fontLG,
                            fontWeight: FontWeight.w800,
                            color: theme.secondaryColor.value,
                          ),
                        ),
                      ),
                      if (controller.product.hasVariants) ...[
                        SizedBox(height: context.spacingLG),
                        Text(
                          'SELECT VARIANT',
                          style: AppFonts.geistMono(
                            fontSize: context.fontXS,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: const Color(0xFF9AA1B0),
                          ),
                        ),
                        SizedBox(height: context.spacingSM),
                        Obx(
                          () => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.product.variants.map((
                              variant,
                            ) {
                              final selected =
                                  controller.selectedVariant.value == variant;
                              return GestureDetector(
                                onTap: () => controller.selectVariant(variant),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? theme.secondaryColor.value
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: selected
                                          ? theme.secondaryColor.value
                                          : ColorResources.cardBorderColor,
                                    ),
                                  ),
                                  child: Text(
                                    'SKU: ${variant.sku ?? '--'}  •  Rs. ${variant.effectivePrice.toStringAsFixed(0)}',
                                    style: AppFonts.geistMono(
                                      fontSize: context.fontXS,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? theme.onSecondaryColor
                                          : ColorResources.labelColor,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                      SizedBox(height: context.spacingLG),
                      Text(
                        'QUANTITY',
                        style: AppFonts.geistMono(
                          fontSize: context.fontXS,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: const Color(0xFF9AA1B0),
                        ),
                      ),
                      SizedBox(height: context.spacingSM),
                      Obx(
                        () => Row(
                          children: [
                            QtyBtn(
                              icon: Icons.remove,
                              onTap: controller.decrementQty,
                            ),
                            SizedBox(width: context.spacingMD),
                            Text(
                              '${controller.quantity.value}',
                              style: AppFonts.geistMono(
                                fontSize: context.fontMD,
                                fontWeight: FontWeight.w700,
                                color: ColorResources.labelColor,
                              ),
                            ),
                            SizedBox(width: context.spacingMD),
                            QtyBtn(
                              icon: Icons.add,
                              onTap: controller.incrementQty,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.spacingXL),
                    ],
                  ),
                ),
              ),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    backgroundColor: controller.addedToCart.value
                        ? Colors.grey.shade300
                        : theme.secondaryColor.value,
                    onPressed: controller.addedToCart.value
                        ? () {}
                        : controller.addToCart,
                    isLoading: false,
                    borderRadius: 10,
                    child: Text(
                      controller.addedToCart.value ? 'Added ✓' : 'Add to Cart',
                      style: AppFonts.geistMono(
                        fontSize: context.fontSM,
                        fontWeight: FontWeight.w700,
                        color: controller.addedToCart.value
                            ? Colors.grey.shade600
                            : theme.onSecondaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final ProductVariantController controller;
  const _ProductImage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: context.responsiveHeight(0.28),
        color: const Color(0xFFE5E7EB),
        child: controller.product.primaryImageUrl != null
            ? CachedNetworkImage(
                imageUrl: controller.product.primaryImageUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                  size: 40,
                ),
              )
            : const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
      ),
    );
  }
}
