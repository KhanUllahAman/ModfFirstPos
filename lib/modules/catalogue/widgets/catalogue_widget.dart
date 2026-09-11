import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/currency_utils.dart';
import 'package:modfirstpos/modules/catalogue/controller/catalogue_controller.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/shared/widgets/AppWidgets/product_pin_button.dart';
import 'package:modfirstpos/shared/widgets/Buttons/sync_button_widget.dart';
import 'package:modfirstpos/shared/widgets/DynamicImage/product_image_carousel.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class CatalogueTabsHeader extends StatelessWidget {
  final CatalogueController controller;
  const CatalogueTabsHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            final active = controller.activeTab.value;
            return Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      title: 'Categories',
                      icon: Icons.category_outlined,
                      isSelected: active == PosScreenTab.categories,
                      onTap: () => controller.switchTab(PosScreenTab.categories),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _TabButton(
                      title: 'Products',
                      icon: Icons.inventory_2_outlined,
                      isSelected: active == PosScreenTab.products,
                      onTap: () => controller.switchTab(PosScreenTab.products),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(width: 10),
        Obx(
          () => AppSyncButton(
            onPressed: controller.syncCategories,
            isLoading: controller.isLoading.value,
            label: 'Sync Server',
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isSelected ? theme.secondaryColor.value : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.secondaryColor.value.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? theme.onSecondaryColor
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppFonts.geistMono(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? theme.onSecondaryColor
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBarCatalogue extends StatelessWidget {
  final CatalogueController controller;
  const SearchBarCatalogue({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.responsiveHeight(0.055),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearch,
        style: AppFonts.geistMono(
          fontSize: context.fontSM,
          color: ColorResources.labelColor,
        ),
        decoration: InputDecoration(
          hintText: 'Search Category',
          hintStyle: AppFonts.geistMono(
            fontWeight: FontWeight.w500,
            fontSize: context.fontSM,
            color: ColorResources.labelColor.withOpacity(0.5),
          ),
          prefixIcon:
              const Icon(Icons.search, color: ColorResources.blackColor),
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

class ProductGrid extends StatelessWidget {
  final CatalogueController controller;
  const ProductGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.activeTab.value == PosScreenTab.products) {
        return _buildAllProductsView(context);
      }
      if (controller.selectedCategory.value == null) {
        return _buildTopCategoriesView(context);
      }
      return _buildCategoryDetailView(context);
    });
  }

  Widget _buildTopCategoriesView(BuildContext context) {
    final categories = controller.filteredCategories;

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No categories found',
              style: AppFonts.geistMono(
                fontSize: context.fontSM,
                color: ColorResources.blackColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            AppSyncButton(
              onPressed: () => controller.syncCategories(),
              label: 'Reload Categories',
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Text(
                'TOP-LEVEL CATEGORIES',
                style: AppFonts.geistMono(
                  fontSize: context.fontXS,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: const Color(0xFF9AA1B0),
                ),
              ),
              const Spacer(),
              Text(
                '${categories.length} categories',
                style: AppFonts.geistMono(
                  fontSize: context.fontXS * 0.9,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            primary: false,
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (_, i) => _CategoryCard(
              category: categories[i],
              onTap: () => controller.onCategoryTap(categories[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDetailView(BuildContext context) {
    final category = controller.selectedCategory.value!;
    final childCategories = controller.childCategoriesFor(category.id ?? 0);
    final products = controller.filteredProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            InkWell(
              onTap: controller.onCategoryBack,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorResources.whiteColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorResources.cardBorderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                      color: ColorResources.blackColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Back',
                      style: AppFonts.geistMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ColorResources.blackColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Obx(() {
                final stack = controller.categoryHierarchyStack;
                if (stack.length > 1) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < stack.length; i++) ...[
                          if (i > 0)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                size: 14,
                                color: Colors.grey,
                              ),
                            ),
                          InkWell(
                            onTap: () {
                              while (
                                  controller.categoryHierarchyStack.isNotEmpty &&
                                      controller
                                              .categoryHierarchyStack.last.id !=
                                          stack[i].id) {
                                controller.onCategoryBack();
                              }
                            },
                            child: Text(
                              stack[i].displayName,
                              style: AppFonts.geistMono(
                                fontSize: context.fontSM * 0.95,
                                fontWeight: i == stack.length - 1
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: i == stack.length - 1
                                    ? ColorResources.appAccentColor
                                    : ColorResources.labelColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return Text(
                  category.displayName.toUpperCase(),
                  style: AppFonts.geistMono(
                    fontSize: context.fontSM,
                    fontWeight: FontWeight.w800,
                    color: ColorResources.labelColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }),
            ),
          ],
        ),
        SizedBox(height: context.spacingXS),
        SizedBox(
          height: context.responsiveHeight(0.055),
          child: TextField(
            controller: controller.productSearchController,
            onChanged: controller.onProductSearch,
            style: AppFonts.geistMono(fontSize: context.fontSM),
            decoration: InputDecoration(
              filled: true,
              fillColor: ColorResources.whiteColor,
              hintText: 'Search product in ${category.displayName}...',
              hintStyle: AppFonts.geistMono(
                color: ColorResources.blackColor.withOpacity(0.5),
                fontSize: context.fontSM,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.spacingSM,
                vertical: context.spacingXS,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorResources.cardBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorResources.cardBorderColor),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: ColorResources.blackColor,
              ),
            ),
          ),
        ),
        if (childCategories.isNotEmpty) ...[
          const SizedBox(height: 10),
          _CatalogueChildCategoriesRow(
            childCategories: childCategories,
            onTap: controller.onCategoryTap,
          ),
        ],
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                'PRODUCTS',
                style: AppFonts.geistMono(
                  fontSize: context.fontXS,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: const Color(0xFF9AA1B0),
                ),
              ),
              const Spacer(),
              Text(
                '${products.length} items',
                style: AppFonts.geistMono(
                  fontSize: context.fontXS * 0.9,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 48,
                        color: ColorResources.blackColor.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No products found in this category',
                        style: AppFonts.geistMono(
                          fontSize: context.fontSM,
                          color: ColorResources.blackColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  primary: false,
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (_, i) => _CatalogueProductCard(
                    product: products[i],
                    onTap: () => controller.onProductTap(products[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildAllProductsView(BuildContext context) {
    final products = controller.filteredAllProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: context.responsiveHeight(0.055),
          child: TextField(
            controller: controller.allProductsSearchController,
            onChanged: controller.onAllProductsSearch,
            style: AppFonts.geistMono(fontSize: context.fontSM),
            decoration: InputDecoration(
              filled: true,
              fillColor: ColorResources.whiteColor,
              hintText: 'Search all products by name or SKU...',
              hintStyle: AppFonts.geistMono(
                color: ColorResources.blackColor.withOpacity(0.5),
                fontSize: context.fontSM,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.spacingSM,
                vertical: context.spacingXS,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorResources.cardBorderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorResources.cardBorderColor),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: ColorResources.blackColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                'ALL PRODUCTS',
                style: AppFonts.geistMono(
                  fontSize: context.fontXS,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: const Color(0xFF9AA1B0),
                ),
              ),
              const Spacer(),
              Text(
                '${products.length} items',
                style: AppFonts.geistMono(
                  fontSize: context.fontXS * 0.9,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: ColorResources.blackColor.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No products found',
                        style: AppFonts.geistMono(
                          fontSize: context.fontSM,
                          color: ColorResources.blackColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  primary: false,
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (_, i) => _CatalogueProductCard(
                    product: products[i],
                    onTap: () => controller.onProductTap(products[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _CatalogueChildCategoriesRow extends StatelessWidget {
  final List<CategoryModel> childCategories;
  final ValueChanged<CategoryModel> onTap;

  const _CatalogueChildCategoriesRow({
    required this.childCategories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            'SUB-CATEGORIES',
            style: AppFonts.geistMono(
              fontSize: context.fontXS * 0.95,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: const Color(0xFF9AA1B0),
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: childCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final child = childCategories[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTap(child),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ColorResources.whiteColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorResources.cardBorderColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (child.imageUrl != null &&
                            child.imageUrl!.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: CachedNetworkImage(
                              imageUrl: child.imageUrl!,
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Icon(
                                Icons.folder_outlined,
                                size: 16,
                                color: theme.secondaryColor.value,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ] else ...[
                          Icon(
                            Icons.subdirectory_arrow_right_rounded,
                            size: 16,
                            color: theme.secondaryColor.value,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          child.displayName,
                          style: AppFonts.geistMono(
                            fontSize: context.fontSM * 0.95,
                            fontWeight: FontWeight.w600,
                            color: ColorResources.labelColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: ColorResources.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorResources.cardBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(11)),
                child: category.imageUrl != null &&
                        category.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: category.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorWidget: (_, __, ___) => Container(
                          color: theme.secondaryColor.value.withOpacity(0.12),
                          child: Center(
                            child: Text(
                              category.displayName.isNotEmpty
                                  ? category.displayName[0].toUpperCase()
                                  : '?',
                              style: AppFonts.geistMono(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: theme.secondaryColor.value,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: theme.secondaryColor.value.withOpacity(0.12),
                        child: Center(
                          child: Text(
                            category.displayName.isNotEmpty
                                ? category.displayName[0].toUpperCase()
                                : '?',
                            style: AppFonts.geistMono(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: theme.secondaryColor.value,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                alignment: Alignment.center,
                child: Text(
                  category.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppFonts.geistMono(
                    fontSize: context.fontSM,
                    fontWeight: FontWeight.w600,
                    color: ColorResources.labelColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogueProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  const _CatalogueProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : null;
    final productId = product.id?.toString() ?? product.displayName;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: _buildCardBody(context)),
            if (homeController != null)
              Positioned(
                top: 4,
                right: 4,
                child: Obx(
                  () => ProductPinButton(
                    isPinned: homeController.isPinned(productId),
                    onTap: () => homeController.pinProduct(product),
                    size: 22,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: ProductCardImageSlider(
            imageUrls: product.allImageUrls,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: onTap,
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppFonts.geistMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: ColorResources.labelColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyUtils.format(product.effectivePrice, decimals: 0),
                  style: AppFonts.geistMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ColorResources.labelColor,
                  ),
                ),
                if (product.hasVariants)
                  Text(
                    '${product.variants.length} variants',
                    style: AppFonts.geistMono(
                      fontSize: 8.5,
                      color: ColorResources.labelColor.withOpacity(0.5),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}