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
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(showMenuIcon: false, showBackIcon: true),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Padding(
          padding: EdgeInsets.all(context.responsiveWidth(0.02)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with animations
              Row(
                children: [
                  Expanded(
                    child: BackBar(title: controller.product.displayName),
                  ),
                  Obx(() {
                    if (!controller.addedToCart.value) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: controller.goToCart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

              // Split panel layout
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Pane - Image & Details Card
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: EdgeInsets.all(context.spacingMD),
                        decoration: BoxDecoration(
                          color: ColorResources.whiteColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ColorResources.cardBorderColor.withOpacity(0.6)),
                        ),
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
                            if (controller.product.sku != null && controller.product.sku!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'SKU: ${controller.product.sku}',
                                style: AppFonts.geistMono(
                                  fontSize: context.fontXS,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            if (controller.product.shortDesc != null) ...[
                              Text(
                                'Description',
                                style: AppFonts.geistMono(
                                  fontSize: context.fontXS,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    controller.product.shortDesc!,
                                    style: AppFonts.geistMono(
                                      fontSize: context.fontSM,
                                      color: ColorResources.labelColor.withOpacity(0.7),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ] else
                              const Expanded(child: SizedBox.shrink()),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: context.responsiveWidth(0.02)),

                    // Right Pane - Variant Selection Form Card
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: EdgeInsets.all(context.spacingMD),
                        decoration: BoxDecoration(
                          color: ColorResources.whiteColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ColorResources.cardBorderColor.withOpacity(0.6)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Product Pricing',
                              style: AppFonts.geistMono(
                                fontSize: context.fontXS,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Obx(() => Text(
                              'Rs. ${controller.displayPrice.toStringAsFixed(0)}',
                              style: AppFonts.geistMono(
                                fontSize: context.fontXXL,
                                fontWeight: FontWeight.w800,
                                color: theme.secondaryColor.value,
                              ),
                            )),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 12),

                            // Variant Selector Wrap
                            if (controller.product.hasVariants) ...[
                              Text(
                                'SELECT VARIANT',
                                style: AppFonts.geistMono(
                                  fontSize: context.fontXS,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Scrollbar(
                                  child: SingleChildScrollView(
                                    child: Obx(() => Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: controller.product.variants.map((variant) {
                                        final selected = controller.selectedVariant.value == variant;
                                        return GestureDetector(
                                          onTap: () => controller.selectVariant(variant),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: selected ? theme.secondaryColor.value : Colors.grey[100],
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: selected ? theme.secondaryColor.value : ColorResources.cardBorderColor.withOpacity(0.6),
                                                width: selected ? 1.5 : 1.0,
                                              ),
                                            ),
                                            child: Text(
                                              'SKU: ${variant.sku ?? '--'}  •  Rs. ${variant.effectivePrice.toStringAsFixed(0)}',
                                              style: AppFonts.geistMono(
                                                fontSize: context.fontXS,
                                                fontWeight: FontWeight.w600,
                                                color: selected ? theme.onSecondaryColor : ColorResources.labelColor,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    )),
                                  ),
                                ),
                              ),
                            ] else
                              const Expanded(child: SizedBox.shrink()),

                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 12),

                            // Quantity Adjuster
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'QUANTITY',
                                  style: AppFonts.geistMono(
                                    fontSize: context.fontXS,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                Obx(() => Row(
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
                                )),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Cart Add Action
                            Obx(() => AppButton(
                              backgroundColor: controller.addedToCart.value ? Colors.grey.shade300 : theme.secondaryColor.value,
                              onPressed: controller.addedToCart.value ? () {} : controller.addToCart,
                              isLoading: false,
                              borderRadius: 12,
                              height: 52,
                              child: Text(
                                controller.addedToCart.value ? 'ADDED TO CART ✓' : 'ADD TO CART',
                                style: AppFonts.geistMono(
                                  fontSize: context.fontSM,
                                  fontWeight: FontWeight.w700,
                                  color: controller.addedToCart.value ? Colors.grey.shade600 : theme.onSecondaryColor,
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: context.responsiveHeight(0.3),
        color: const Color(0xFFF3F4F6),
        child: controller.product.primaryImageUrl != null
            ? CachedNetworkImage(
                imageUrl: controller.product.primaryImageUrl!,
                fit: BoxFit.contain,
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
