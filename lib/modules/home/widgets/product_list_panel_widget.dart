import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/customer/controller/customer_controller.dart';
import 'package:modfirstpos/modules/customer/widgets/add_customer_dialog.dart';
import 'package:modfirstpos/modules/home/widgets/cash_payment_panel.dart';
import 'package:modfirstpos/shared/widgets/Buttons/sync_button_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class ProductListPanel extends StatelessWidget {
  final HomeController controller;
  const ProductListPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final Widget panel;
      if (controller.showCashPanel.value) {
        panel = KeyedSubtree(
          key: const ValueKey('cash'),
          child: CashPaymentPanel(controller: controller),
        );
      } else if (controller.showCustomerPanel.value) {
        panel = KeyedSubtree(
          key: const ValueKey('customers'),
          child: _buildCustomersView(context),
        );
      } else if (controller.selectedCategory.value == null) {
        panel = KeyedSubtree(
          key: const ValueKey('categories'),
          child: _buildCategoriesView(context),
        );
      } else if (controller.selectedProduct.value == null) {
        panel = KeyedSubtree(
          key: ValueKey('products-${controller.selectedCategory.value?.id}'),
          child:
              _buildProductsView(context, controller.selectedCategory.value!),
        );
      } else {
        panel = KeyedSubtree(
          key: ValueKey('variants-${controller.selectedProduct.value?.id}'),
          child: _buildVariantsSelectionView(
            context,
            controller.selectedProduct.value!,
          ),
        );
      }
      // Subtle fade between panel modes for a polished POS feel.
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: panel,
      );
    });
  }

  Widget _buildCategoriesView(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Column(
      children: [
        _CategorySearchField(controller: controller),
        SizedBox(height: context.responsiveHeight(0.015)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveWidth(0.008),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'CATEGORIES',
              style: AppFonts.geistMono(
                fontSize: context.fontXS,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: const Color(0xFF9AA1B0),
              ),
            ),
          ),
        ),
        SizedBox(height: context.responsiveHeight(0.008)),
        Expanded(
          child: Obx(() {
            final _ = controller.categorySearchQuery.value;
            if (controller.isCategoriesLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.secondaryColor.value,
                  strokeWidth: 3.0,
                ),
              );
            }
            final categories = controller.filteredCategories;
            if (categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 40,
                      color: ColorResources.blackColor.withOpacity(0.3),
                    ),
                    SizedBox(height: context.spacingSM),
                    Text(
                      'No categories found',
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        color: ColorResources.blackColor.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Scrollbar(
              controller: controller.productScrollController,
              thumbVisibility: true,
              child: GridView.builder(
                controller: controller.productScrollController,
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (_, index) => _CategoryGridCard(
                  category: categories[index],
                  onTap: () => controller.onCategoryTap(categories[index]),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCustomersView(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final customerController = Get.find<CustomerController>();

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: ColorResources.blackColor,
              ),
              onPressed: () {
                controller.showCustomerPanel.value = false;
              },
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'SELECT CUSTOMER',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w700,
                  color: ColorResources.labelColor,
                ),
              ),
            ),
            Obx(
              () => AppSyncButton(
                onPressed: customerController.syncCustomers,
                isLoading: customerController.isLoading.value,
                label: 'Sync Customers',
                variant: SyncButtonVariant.iconOnly,
                borderRadius: 8,
              ),
            ),
            const SizedBox(width: 8),
            Obx(
              () => TextButton.icon(
                onPressed: () async {
                  final customer = await AddCustomerDialog.show(context);
                  if (customer != null) {
                    // Auto-select the newly created customer on the cart.
                    controller.selectedCartCustomer.value = customer;
                    controller.showCustomerPanel.value = false;
                  }
                },
                icon: Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 16,
                  color: theme.secondaryColor.value,
                ),
                label: Text(
                  'Add New',
                  style: AppFonts.geistMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.secondaryColor.value,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor:
                      theme.secondaryColor.value.withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsiveHeight(0.008)),
        TextField(
          controller: customerController.searchController,
          onChanged: customerController.onSearchChanged,
          style: AppFonts.geistMono(fontSize: context.fontSM),
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorResources.whiteColor,
            hintText: 'Search Name / Email / Phone',
            hintStyle: AppFonts.geistMono(
              color: ColorResources.blackColor.withOpacity(0.5),
              fontSize: context.fontSM,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.responsiveWidth(0.015),
              vertical: context.responsiveHeight(0.012),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: ColorResources.cardBorderColor),
            ),
            suffixIcon: const Icon(
              Icons.search,
              color: ColorResources.blackColor,
            ),
          ),
        ),
        SizedBox(height: context.responsiveHeight(0.015)),
        Expanded(
          child: Obx(() {
            if (customerController.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.secondaryColor.value,
                  strokeWidth: 3.0,
                ),
              );
            }
            final customers = customerController.filteredCustomers;
            if (customers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 40,
                      color: ColorResources.blackColor.withOpacity(0.3),
                    ),
                    SizedBox(height: context.spacingSM),
                    Text(
                      'No customers found',
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        color: ColorResources.blackColor.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              );
            }
            return Scrollbar(
              controller: controller.customerListScrollController,
              child: ListView.separated(
                controller: controller.customerListScrollController,
                primary: false,
                itemCount: customers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _CustomerRowTile(
                  customer: customers[i],
                  onTap: () {
                    // Attach the customer to the current sale. Stay on the
                    // POS screen — no navigation while ringing up a sale.
                    customerController.selectCustomer(customers[i]);
                    controller.selectedCartCustomer.value = customers[i];
                    controller.showCustomerPanel.value = false;
                  },
                ),
              ),
            );
          }),
        ),
        Obx(() {
          if (customerController.customers.isEmpty) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${customerController.totalCount.value}',
                  style: AppFonts.geistMono(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: customerController.hasPrev.value ? customerController.prevPage : null,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
                      color: ColorResources.appAccentColor,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Page ${customerController.currentPage.value} / ${customerController.totalPages.value}',
                      style: AppFonts.geistMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: ColorResources.labelColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: customerController.hasNext.value ? customerController.nextPage : null,
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      color: ColorResources.appAccentColor,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProductsView(BuildContext context, CategoryModel category) {
    final theme = Get.find<AppThemeService>();
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: ColorResources.blackColor,
              ),
              onPressed: () {
                controller.selectedCategory.value = null;
              },
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                category.displayName.toUpperCase(),
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w700,
                  color: ColorResources.labelColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Obx(
              () => AppSyncButton(
                onPressed: controller.syncCategoryProducts,
                isLoading: controller.isProductsLoading.value,
                label: 'Sync Products',
                variant: SyncButtonVariant.iconOnly,
                borderRadius: 8,
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsiveHeight(0.008)),
        TextField(
          controller: controller.productSearchController,
          onChanged: controller.onProductSearchChanged,
          style: AppFonts.geistMono(fontSize: context.fontSM),
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorResources.whiteColor,
            hintText: 'Search Product in Category',
            hintStyle: AppFonts.geistMono(
              color: ColorResources.blackColor.withOpacity(0.5),
              fontSize: context.fontSM,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: context.responsiveWidth(0.015),
              vertical: context.responsiveHeight(0.012),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: ColorResources.cardBorderColor),
            ),
            suffixIcon: const Icon(
              Icons.search,
              color: ColorResources.blackColor,
            ),
          ),
        ),
        SizedBox(height: context.responsiveHeight(0.015)),
        Expanded(
          child: Obx(() {
            if (controller.isProductsLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.secondaryColor.value,
                  strokeWidth: 3.0,
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
                      size: 40,
                      color: ColorResources.blackColor.withOpacity(0.3),
                    ),
                    SizedBox(height: context.spacingSM),
                    Text(
                      'No products found',
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        color: ColorResources.blackColor.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 300 ? 2 : 3;
                return GridView.builder(
                  primary: false,
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (_, i) => _InlineProductCard(
                    product: products[i],
                    onTap: () => controller.onProductTap(products[i]),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildVariantsSelectionView(
    BuildContext context,
    ProductModel product,
  ) {
    final theme = Get.find<AppThemeService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: ColorResources.blackColor,
              ),
              onPressed: () {
                controller.selectedProduct.value = null;
              },
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                product.displayName.toUpperCase(),
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w700,
                  color: ColorResources.labelColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsiveHeight(0.008)),
        Expanded(
          child: Scrollbar(
            controller: controller.variantPanelScrollController,
            child: SingleChildScrollView(
              controller: controller.variantPanelScrollController,
              primary: false,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (product.images.isNotEmpty) ...[
                      _ProductImageCarousel(images: product.images),
                    ] else ...[
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'PRICE',
                      style: AppFonts.geistMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      final price =
                          controller.selectedInlineVariant.value != null
                          ? controller
                                .selectedInlineVariant
                                .value!
                                .effectivePrice
                          : product.effectivePrice;
                      return Text(
                        'Rs. ${price.toStringAsFixed(0)}',
                        style: AppFonts.geistMono(
                          fontSize: context.fontMD,
                          fontWeight: FontWeight.w800,
                          color: theme.secondaryColor.value,
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Text(
                      'SELECT VARIANT',
                      style: AppFonts.geistMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.variants.map((variant) {
                          final isSelected =
                              controller.selectedInlineVariant.value?.id ==
                              variant.id;
                          return ChoiceChip(
                            label: Text(
                              'SKU: ${variant.sku ?? '--'} (${variant.effectivePrice.toStringAsFixed(0)} Rs)',
                              style: AppFonts.geistMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? theme.onSecondaryColor
                                    : ColorResources.labelColor,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: theme.secondaryColor.value,
                            backgroundColor: Colors.grey[100],
                            onSelected: (_) {
                              controller.selectedInlineVariant.value = variant;
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 12.0),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: ColorResources.cardBorderColor,
                width: 1.0,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QUANTITY',
                    style: AppFonts.geistMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[500],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          size: 22,
                          color: ColorResources.gradientRed,
                        ),
                        onPressed: controller.decrementInlineQty,
                      ),
                      const SizedBox(width: 8),
                      Obx(
                        () => Text(
                          '${controller.inlineQuantity.value}',
                          style: AppFonts.geistMono(
                            fontSize: context.fontSM,
                            fontWeight: FontWeight.bold,
                            color: ColorResources.labelColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          size: 22,
                          color: ColorResources.successGreen,
                        ),
                        onPressed: controller.incrementInlineQty,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.selectedProduct.value = null;
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: ColorResources.cardBorderColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: ColorResources.labelColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppFonts.geistMono(
                          fontWeight: FontWeight.bold,
                          fontSize: context.fontXS,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: () {
                          controller.addToCartFromProduct(
                            product,
                            variant: controller.selectedInlineVariant.value,
                            quantity: controller.inlineQuantity.value,
                          );
                          controller.selectedProduct.value = null;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.secondaryColor.value,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          'Add to Cart',
                          style: AppFonts.geistMono(
                            fontWeight: FontWeight.bold,
                            fontSize: context.fontXS,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryGridCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  const _CategoryGridCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return GestureDetector(
      onTap: onTap,
      child: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: ColorResources.whiteColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColorResources.cardBorderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                  child: category.imageUrl != null && category.imageUrl!.isNotEmpty
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  alignment: Alignment.center,
                  child: Text(
                    category.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppFonts.geistMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: ColorResources.blackColor,
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

class _CustomerRowTile extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;
  const _CustomerRowTile({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final initials = customer.fullName != null && customer.fullName!.isNotEmpty
        ? customer.fullName![0].toUpperCase()
        : '?';

    final hasImage = customer.image != null &&
        customer.image!.isNotEmpty &&
        customer.image != 'default-user.png';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorResources.cardBorderColor),
        ),
        child: Row(
          children: [
            // User Avatar Image/Initials
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: CachedNetworkImage(
                  imageUrl: customer.image!,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.secondaryColor.value.withOpacity(0.12),
                    child: Text(
                      initials,
                      style: AppFonts.geistMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.secondaryColor.value,
                      ),
                    ),
                  ),
                ),
              )
            else
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.secondaryColor.value.withOpacity(0.12),
                child: Text(
                  initials,
                  style: AppFonts.geistMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.secondaryColor.value,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            // User Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          customer.fullName ?? 'Walk-in Customer',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.geistMono(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ColorResources.labelColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          customer.role?.replaceAll('_', ' ').toUpperCase() ?? 'CUSTOMER',
                          style: AppFonts.geistMono(
                            fontSize: 6,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${customer.email ?? 'No email'}  •  ${customer.phone ?? 'No phone'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.geistMono(
                      fontSize: 9,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Selection / View Orders button indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select & View Orders',
                  style: AppFonts.geistMono(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: theme.secondaryColor.value,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 12,
                  color: theme.secondaryColor.value,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  const _InlineProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
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
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: product.primaryImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.primaryImageUrl!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFE5E7EB),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFE5E7EB),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
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
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: ColorResources.labelColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rs. ${product.effectivePrice.toStringAsFixed(0)}',
                      style: AppFonts.geistMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: ColorResources.labelColor,
                      ),
                    ),
                    if (product.hasVariants)
                      Text(
                        '${product.variants.length} variants',
                        style: AppFonts.geistMono(
                          fontSize: 8,
                          color: ColorResources.labelColor.withOpacity(0.5),
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

class _CategorySearchField extends StatelessWidget {
  final HomeController controller;
  const _CategorySearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: controller.onCategorySearchChanged,
            style: AppFonts.geistMono(fontSize: context.fontSM),
            decoration: InputDecoration(
              filled: true,
              fillColor: ColorResources.whiteColor,
              hintText: 'Search Category',
              hintStyle: AppFonts.geistMono(
                color: ColorResources.blackColor,
                fontSize: context.fontSM,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.responsiveWidth(0.015),
                vertical: context.responsiveHeight(0.012),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorResources.cardBorderColor),
              ),
              suffixIcon: const Icon(
                Icons.search,
                color: ColorResources.blackColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Obx(
          () => AppSyncButton(
            onPressed: controller.syncCategories,
            isLoading: controller.isCategoriesLoading.value,
            label: 'Sync Categories',
            variant: SyncButtonVariant.iconOnly,
            borderRadius: 8,
          ),
        ),
      ],
    );
  }
}

/// Product image carousel with page dots. Owns and disposes its
/// [PageController] (previously created in a build method and leaked).
class _ProductImageCarousel extends StatefulWidget {
  final List<ProductImageModel> images;
  const _ProductImageCarousel({required this.images});

  @override
  State<_ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<_ProductImageCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final imgUrl = widget.images[index].imageUrl ?? '';
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imgUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorWidget: (_, __, ___) => Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.images.length > 1) ...[
          const SizedBox(height: 8),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                final isCurrent = _currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isCurrent ? 12 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? theme.secondaryColor.value
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }
}
