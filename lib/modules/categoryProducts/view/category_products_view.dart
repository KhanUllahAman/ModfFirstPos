import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/categoryProducts/controller/category_products_controller.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';

class CategoryProductsView extends GetView<CategoryProductsController> {
  const CategoryProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.whiteColor,
      appBar: AppTopBar(showMenuIcon: false, showBackIcon: true),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Padding(
          padding: EdgeInsets.all(context.responsiveWidth(0.02)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BackBar(title: controller.category.displayName),
              SizedBox(height: context.spacingSM),
              _SearchField(controller: controller),
              SizedBox(height: context.spacingSM),
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
    return SizedBox(
      height: context.responsiveHeight(0.060),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: AppFonts.geistMono(fontSize: context.fontSM, color: ColorResources.labelColor),
        decoration: InputDecoration(
          hintText: 'Search Product',
          hintStyle: AppFonts.geistMono(
            fontWeight: FontWeight.w600,
            fontSize: context.fontSM,
            color: ColorResources.labelColor,
          ),
          suffixIcon: const Icon(Icons.search, color: ColorResources.blackColor),
          filled: true,
          fillColor: ColorResources.whiteColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: ColorResources.cardBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: ColorResources.cardBorderColor),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.spacingSM,
            vertical: context.spacingXS,
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
          child: CircularProgressIndicator(color: theme.secondaryColor.value),
        );
      }

      final products = controller.filteredProducts;

      if (products.isEmpty) {
        return Center(
          child: Text(
            'No products found in this category',
            style: AppFonts.geistMono(
              fontSize: context.fontSM,
              color: ColorResources.blackColor.withOpacity(0.5),
            ),
          ),
        );
      }

      return GridView.builder(
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
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

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: product.primaryImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.primaryImageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFE5E7EB),
                          child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFE5E7EB),
                        child: const Icon(Icons.image_outlined, color: Colors.grey),
                      ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        fontWeight: FontWeight.w600,
                        color: ColorResources.labelColor,
                      ),
                    ),
                    if (product.hasVariants)
                      Text(
                        '${product.variants.length} variants',
                        style: AppFonts.geistMono(
                          fontSize: context.fontXS - 1,
                          color: ColorResources.labelColor.withOpacity(0.5),
                        ),
                      ),
                    Text(
                      'Rs. ${_fmt(product.effectivePrice)}',
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        fontWeight: FontWeight.w700,
                        color: ColorResources.labelColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}