import 'package:modfirstpos/core/utils/currency_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/modules/customer/widgets/add_customer_dialog.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/customer/controller/customer_controller.dart';
import 'package:modfirstpos/modules/draft_orders/widgets/draft_orders_panel.dart';
import 'package:modfirstpos/modules/home/widgets/cash_payment_panel.dart';
import 'package:modfirstpos/shared/widgets/AppWidgets/product_pin_button.dart';
import 'package:modfirstpos/shared/widgets/AppWidgets/variant_selector.dart';
import 'package:modfirstpos/shared/widgets/Buttons/sync_button_widget.dart';
import 'package:modfirstpos/shared/widgets/DynamicImage/product_image_carousel.dart';
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
      } else if (controller.showDraftOrdersPanel.value) {
        panel = KeyedSubtree(
          key: const ValueKey('draft_orders'),
          child: DraftOrdersPanel(homeController: controller),
        );
      } else if (controller.showPinnedPanel.value) {
        panel = KeyedSubtree(
          key: const ValueKey('pinned'),
          child: _buildPinnedView(context),
        );
      } else if (controller.showCustomerPanel.value) {
        panel = KeyedSubtree(
          key: const ValueKey('customers'),
          child: _buildCustomersView(context),
        );
      } else if (controller.selectedProduct.value != null) {
        panel = KeyedSubtree(
          key: ValueKey('variants-${controller.selectedProduct.value?.id}'),
          child: _buildVariantsSelectionView(
            context,
            controller.selectedProduct.value!,
          ),
        );
      } else if (controller.activePosTab.value == PosScreenTab.products) {
        panel = KeyedSubtree(
          key: const ValueKey('all_products_tab'),
          child: _buildAllProductsView(context),
        );
      } else if (controller.selectedCategory.value == null) {
        panel = KeyedSubtree(
          key: const ValueKey('categories_root'),
          child: _buildCategoriesView(context),
        );
      } else {
        panel = KeyedSubtree(
          key: ValueKey('products-${controller.selectedCategory.value?.id}'),
          child: _buildProductsView(
            context,
            controller.selectedCategory.value!,
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

  Widget _buildPosTopHeader(BuildContext context) {
    return Row(
      children: [
        Obx(() {
          if (!controller.showMobileCatalogue.value) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: IconButton(
              tooltip: 'Back to Cart',
              icon: const Icon(Icons.shopping_cart_outlined, size: 20),
              onPressed: () => controller.showMobileCatalogue.value = false,
            ),
          );
        }),
        Expanded(child: _buildPosTabs(context)),
        const SizedBox(width: 8),
        _DraftOrdersPanelButton(controller: controller),
        const SizedBox(width: 8),
        _PinnedPanelButton(controller: controller),
        const SizedBox(width: 8),
        Obx(
          () => AppSyncButton(
            onPressed: controller.syncCategories,
            isLoading: controller.isCategoriesLoading.value ||
                controller.isProductsLoading.value ||
                controller.isBootstrapSyncing.value,
            label: 'Sync Store Data',
            variant: SyncButtonVariant.iconOnly,
            borderRadius: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildPosTabs(BuildContext context) {
    return Obx(() {
      final activeTab = controller.activePosTab.value;
      return Container(
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Expanded(
              child: _TabButton(
                title: 'Categories',
                icon: Icons.category_outlined,
                isSelected: activeTab == PosScreenTab.categories,
                onTap: () => controller.switchPosTab(PosScreenTab.categories),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _TabButton(
                title: 'Products',
                icon: Icons.inventory_2_outlined,
                isSelected: activeTab == PosScreenTab.products,
                onTap: () => controller.switchPosTab(PosScreenTab.products),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCategoriesView(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Column(
      children: [
        _buildPosTopHeader(context),
        SizedBox(height: context.responsiveHeight(0.012)),
        _CategorySearchField(controller: controller),
        SizedBox(height: context.responsiveHeight(0.012)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveWidth(0.008),
          ),
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
              Obx(
                () => Text(
                  '${controller.filteredCategories.length} categories',
                  style: AppFonts.geistMono(
                    fontSize: context.fontXS * 0.9,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsiveHeight(0.008)),
        Expanded(
          child: Obx(() {
            final _ = controller.categorySearchQuery.value;
            if (controller.isCategoriesLoading.value ||
                controller.isBootstrapSyncing.value) {
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
              controller: controller.categoryScrollController,
              thumbVisibility: true,
              child: GridView.builder(
                controller: controller.categoryScrollController,
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

  Widget _buildAllProductsView(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Column(
      children: [
        _buildPosTopHeader(context),
        SizedBox(height: context.responsiveHeight(0.012)),
        TextField(
          controller: controller.allProductsSearchController,
          onChanged: controller.onAllProductsSearchChanged,
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
              horizontal: context.responsiveWidth(0.015),
              vertical: context.responsiveHeight(0.012),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: ColorResources.cardBorderColor),
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: ColorResources.blackColor,
            ),
            suffixIcon: Obx(() {
              if (controller.allProductsSearchQuery.value.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    controller.allProductsSearchController.clear();
                    controller.onAllProductsSearchChanged('');
                  },
                );
              }
              return const SizedBox.shrink();
            }),
          ),
        ),
        SizedBox(height: context.responsiveHeight(0.012)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveWidth(0.008),
          ),
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
              Obx(
                () => Text(
                  '${controller.filteredAllProducts.length} items',
                  style: AppFonts.geistMono(
                    fontSize: context.fontXS * 0.9,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsiveHeight(0.008)),
        Expanded(
          child: Obx(() {
            if (controller.isProductsLoading.value ||
                controller.isBootstrapSyncing.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.secondaryColor.value,
                  strokeWidth: 3.0,
                ),
              );
            }
            final products = controller.filteredAllProducts;
            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
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
                  controller: controller.categoryDetailProductsScrollController,
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

  /// Pinned (quick access) products list. Persisted locally so pins survive
  /// app restarts; tapping a tile adds the product straight to the cart.
  Widget _buildPinnedView(BuildContext context) {
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
              onPressed: controller.closePinnedPanel,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'PINNED PRODUCTS',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w700,
                  color: ColorResources.labelColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsiveHeight(0.008)),
        Expanded(
          child: Obx(() {
            final pinned = controller.pinnedProducts;
            if (pinned.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.push_pin_outlined,
                      size: 40,
                      color: ColorResources.blackColor.withOpacity(0.3),
                    ),
                    SizedBox(height: context.spacingSM),
                    Text(
                      'No pinned products yet\nPin products for one-tap access',
                      textAlign: TextAlign.center,
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        color: ColorResources.blackColor.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              primary: false,
              itemCount: pinned.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final item = pinned[i];
                return Material(
                  color: theme.secondaryColor.value.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => controller.addToCartFromItem(item),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.imageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: item.imageUrl!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                    errorWidget: (_, __, ___) => Container(
                                      color: const Color(0xFFE5E7EB),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 18,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: const Color(0xFFE5E7EB),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      size: 18,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.geistMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: ColorResources.labelColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyUtils.format(
                                    item.productPrice ?? 0,
                                    decimals: 0,
                                  ),
                                  style: AppFonts.geistMono(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: theme.secondaryColor.value,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Add to cart',
                            icon: Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 18,
                              color: theme.secondaryColor.value,
                            ),
                            onPressed: () => controller.addToCartFromItem(item),
                          ),
                          IconButton(
                            tooltip: 'Unpin',
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: ColorResources.gradientRed,
                            ),
                            onPressed: () =>
                                controller.removePinnedProduct(item),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
                  backgroundColor: theme.secondaryColor.value.withOpacity(0.12),
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
          if (customerController.customers.isEmpty) {
            return const SizedBox.shrink();
          }
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
                      onPressed: customerController.hasPrev.value
                          ? customerController.prevPage
                          : null,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 14,
                      ),
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
                      onPressed: customerController.hasNext.value
                          ? customerController.nextPage
                          : null,
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                      ),
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
        _buildPosTopHeader(context),
        SizedBox(height: context.responsiveHeight(0.01)),
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
            const SizedBox(width: 8),
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
                              while (controller.categoryHierarchyStack.isNotEmpty &&
                                  controller.categoryHierarchyStack.last.id !=
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
                                    ? theme.secondaryColor.value
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
              borderSide:
                  const BorderSide(color: ColorResources.cardBorderColor),
            ),
            suffixIcon: const Icon(
              Icons.search,
              color: ColorResources.blackColor,
            ),
          ),
        ),
        Obx(() {
          final childCategories =
              controller.childCategoriesFor(category.id ?? 0);
          if (childCategories.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildChildCategoriesRow(context, childCategories),
          );
        }),
        SizedBox(height: context.responsiveHeight(0.01)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveWidth(0.008),
          ),
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
              Obx(
                () => Text(
                  '${controller.filteredProducts.length} items',
                  style: AppFonts.geistMono(
                    fontSize: context.fontXS * 0.9,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsiveHeight(0.008)),
        Expanded(
          child: Obx(() {
            if (controller.isProductsLoading.value ||
                controller.isBootstrapSyncing.value) {
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
                  controller: controller.allProductsScrollController,
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

  Widget _buildChildCategoriesRow(
    BuildContext context,
    List<CategoryModel> childCategories,
  ) {
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
                  onTap: () => controller.onCategoryTap(child),
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
            Obx(
              () => IconButton(
                tooltip: 'Pin product',
                icon: Icon(
                  Icons.push_pin_outlined,
                  size: 20,
                  color: theme.secondaryColor.value,
                ),
                onPressed: () => controller.pinProduct(
                  product,
                  variant: controller.selectedInlineVariant.value,
                ),
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
                    // Product images; swaps to the selected variant's own
                    // image when it has one.
                    ProductImageCarousel(
                      imageUrls: product.allImageUrls,
                    ),
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
                        CurrencyUtils.format(price, decimals: 0),
                        style: AppFonts.geistMono(
                          fontSize: context.fontMD,
                          fontWeight: FontWeight.w800,
                          color: theme.secondaryColor.value,
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Obx(
                      () => VariantSelector(
                        product: product,
                        selectedVariant: controller.selectedInlineVariant.value,
                        onVariantSelected: (variant) {
                          controller.selectedInlineVariant.value = variant;
                        },
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
                          backgroundColor: theme.primaryColor.value,
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(9),
                  ),
                  child:
                      category.imageUrl != null && category.imageUrl!.isNotEmpty
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
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

    final hasImage =
        customer.image != null &&
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
                    backgroundColor: theme.secondaryColor.value.withOpacity(
                      0.12,
                    ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          customer.role?.replaceAll('_', ' ').toUpperCase() ??
                              'CUSTOMER',
                          style: AppFonts.geistMono(
                            fontSize: 6,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                      ),
                      if (customer.discountTier != null) ...[
                        const SizedBox(width: 4),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: ColorResources.successGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              customer.discountTier!.label.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.geistMono(
                                fontSize: 6,
                                fontWeight: FontWeight.bold,
                                color: ColorResources.successGreen,
                              ),
                            ),
                          ),
                        ),
                      ],
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

/// Opens the pinned (quick access) products panel.
class _PinnedPanelButton extends StatelessWidget {
  final HomeController controller;
  const _PinnedPanelButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: IconButton(
          tooltip: 'Pinned products',
          icon: Icon(
            Icons.push_pin_rounded,
            size: 20,
            color: theme.secondaryColor.value,
          ),
          onPressed: controller.openPinnedPanel,
        ),
      ),
    );
  }
}

/// Opens the draft orders panel.
class _DraftOrdersPanelButton extends StatelessWidget {
  final HomeController controller;
  const _DraftOrdersPanelButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: IconButton(
          tooltip: 'Draft orders',
          icon: Icon(
            Icons.receipt_long_rounded,
            size: 20,
            color: theme.secondaryColor.value,
          ),
          onPressed: controller.openDraftOrdersPanel,
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
    final homeController = Get.find<HomeController>();
    final productId = product.id?.toString() ?? product.displayName;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: _buildCardBody(context)),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            onTap: onTap,
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
                  CurrencyUtils.format(product.effectivePrice, decimals: 0),
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
            isLoading: controller.isCategoriesLoading.value ||
                controller.isBootstrapSyncing.value,
            label: 'Sync Categories',
            variant: SyncButtonVariant.iconOnly,
            borderRadius: 8,
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
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.secondaryColor.value.withOpacity(0.25),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
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
              size: 15,
              color: isSelected
                  ? theme.onSecondaryColor
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppFonts.geistMono(
                fontSize: 11.5,
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
