import 'package:modfirstpos/core/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/categoryProducts/controller/category_products_controller.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/AppWidgets/product_pin_button.dart';
import 'package:modfirstpos/shared/widgets/DynamicImage/product_image_carousel.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';

class CategoryProductsView extends GetView<CategoryProductsController> {
  const CategoryProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources
          .backgroundColor, // Changed from white to grey background for premium card contrast
      appBar: AppTopBar(showMenuIcon: false, showBackIcon: true),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Padding(
          padding: EdgeInsets.all(context.responsiveWidth(0.02)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BackBar(title: controller.category.displayName),
              SizedBox(height: context.spacingMD),
              _SearchField(controller: controller),
              SizedBox(height: context.spacingMD),
              Expanded(child: _ProductGrid(controller: controller)),
            ],
          ),
        ),
      ),
    ).noKeyboard();
  }
}

class _SearchField extends StatelessWidget {
  final CategoryProductsController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.responsiveHeight(0.065),
      decoration: BoxDecoration(
        color: ColorResources.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: AppFonts.geistMono(
          fontSize: context.fontSM,
          color: ColorResources.labelColor,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search Product in this category...',
          hintStyle: AppFonts.geistMono(
            fontWeight: FontWeight.w500,
            fontSize: context.fontSM,
            color: ColorResources.labelColor.withOpacity(0.4),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: ColorResources.blackColor,
          ),
          suffixIcon: controller.searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                  onPressed: () {
                    controller.searchController.clear();
                    controller.onSearchChanged('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.spacingSM,
            vertical: context.spacingSM,
          ),
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final CategoryProductsController controller;
  const _ProductGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(() {
      final _ = controller.searchQuery.value; // rebuild trigger
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: theme.secondaryColor.value,
            strokeWidth: 3,
          ),
        );
      }

      final products = controller.filteredProducts;

      if (products.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: ColorResources.blackColor.withOpacity(0.2),
              ),
              const SizedBox(height: 12),
              Text(
                'No products found in this category',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w600,
                  color: ColorResources.blackColor.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => controller.syncProducts(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  'Reload Products',
                  style: AppFonts.geistMono(
                    fontSize: context.fontXS,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor.value,
                  foregroundColor: theme.onPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        primary: false,
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (_, i) => _ProductCard(
          product: products[i],
          onTap: () => controller.onProductTap(products[i]),
        ),
      );
    });
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final homeController = Get.find<HomeController>();
    final productId = product.id?.toString() ?? product.displayName;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ColorResources.cardBorderColor.withOpacity(0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            _buildCardBody(context, theme),
            Positioned(
              top: 6,
              right: 6,
              child: Obx(
                () => ProductPinButton(
                  isPinned: homeController.isPinned(productId),
                  onTap: () => homeController.pinProduct(product),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBody(BuildContext context, AppThemeService theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image part with badge overlay
        Expanded(
          flex: 6,
          child: Stack(
            children: [
              Positioned.fill(
                child: ProductCardImageSlider(
                  imageUrls: product.allImageUrls,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
              if (product.hasVariants)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.value.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${product.variants.length} VARIANTS',
                      style: AppFonts.geistMono(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: theme.onPrimaryColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Info text part
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  product.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.geistMono(
                    fontSize: context.fontXS,
                    fontWeight: FontWeight.bold,
                    color: ColorResources.labelColor,
                  ),
                ),
                if (product.sku != null && product.sku!.isNotEmpty)
                  Text(
                    'SKU: ${product.sku}',
                    style: AppFonts.geistMono(
                      fontSize: 9,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CurrencyUtils.format(product.effectivePrice, decimals: 0),
                      style: AppFonts.geistMono(
                        fontSize: context.fontSM,
                        fontWeight: FontWeight.w800,
                        color: theme.secondaryColor.value,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: theme.secondaryColor.value,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
