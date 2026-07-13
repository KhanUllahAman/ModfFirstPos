import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/home/model/cart_item_model.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class ScanField extends StatelessWidget {
  final HomeController controller;
  const ScanField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorResources.cardBorderColor),
      ),
      child: TextField(
        controller: controller.scanController,
        // onSubmitted: ,
        style: AppFonts.geistMono(fontSize: context.fontSM),
        decoration: InputDecoration(
          hintText: 'Scan Product',
          hintStyle: AppFonts.geistMono(
            color: ColorResources.blackColor,
            fontSize: context.fontSM,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.responsiveWidth(0.02),
            vertical: context.responsiveHeight(0.018),
          ),
          border: InputBorder.none,
          suffixIcon: Padding(
            padding: EdgeInsets.all(context.responsiveWidth(0.012)),
            child: Icon(Iconsax.scan_barcode, color: ColorResources.blackColor),
          ),
        ),
      ),
    );
  }
}

class CartSection extends StatelessWidget {
  final HomeController controller;
  const CartSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.cartItems.isEmpty) return const _EmptyCart();

      return Scrollbar(
        controller: controller.cartScrollController,
        thumbVisibility: true,
        thickness: 5,
        radius: const Radius.circular(8),
        scrollbarOrientation: ScrollbarOrientation.right,
        child: ListView.separated(
          controller: controller.cartScrollController,
          padding: EdgeInsets.only(right: context.responsiveWidth(0.018)),
          itemCount: controller.cartItems.length,
          separatorBuilder: (_, __) =>
              SizedBox(height: context.responsiveHeight(0.010)),
          itemBuilder: (_, index) => _CartItemTile(
            item: controller.cartItems[index],
            controller: controller,
          ),
        ),
      );
    });
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            color: theme.secondaryColor.value,
            ImagesConstant.emptyCartSvg,
            height: context.responsiveHeight(0.18),
          ),
          SizedBox(height: context.spacingMD),
          Text(
            'Empty Cart',
            style: AppFonts.geistMono(
              fontSize: context.fontMD,
              fontWeight: FontWeight.w800,
              color: ColorResources.blackColor,
            ),
          ),
          SizedBox(height: context.spacingXS),
          Text(
            'Scan a product to add it to your cart or browse\nfrom the listings below.',
            textAlign: TextAlign.center,
            style: AppFonts.geistMono(
              fontSize: context.fontSM,
              color: ColorResources.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final HomeController controller;
  const _CartItemTile({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final imgSize = context.responsiveHeight(0.075);

    return Container(
      padding: EdgeInsets.all(context.responsiveHeight(0.012)),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorResources.cardBorderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                item.product.imageUrl != null &&
                    item.product.imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.product.imageUrl!,
                    width: imgSize,
                    height: imgSize,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => Container(
                      width: imgSize,
                      height: imgSize,
                      color: const Color(0xFFE5E7EB),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 1.5),
                      ),
                    ),
                    errorWidget: (_, __, ___) =>
                        _CartImagePlaceholder(size: imgSize),
                  )
                : _CartImagePlaceholder(size: imgSize),
          ),

          SizedBox(width: context.responsiveWidth(0.012)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.geistMono(
                    fontSize: context.fontSM,
                    fontWeight: FontWeight.w600,
                    color: ColorResources.blackColor,
                  ),
                ),

                SizedBox(height: context.responsiveHeight(0.004)),

                Text(
                  'SKU: ${item.product.skuCode}',
                  style: AppFonts.geistMono(
                    fontSize: context.fontXS,
                    color: ColorResources.labelColor,
                  ),
                ),

                Text(
                  'Amount: Rs. ${item.product.amount.toStringAsFixed(0)}',
                  style: AppFonts.geistMono(
                    fontSize: context.fontXS,
                    color: ColorResources.labelColor,
                  ),
                ),

                Text(
                  'Unit Price: Rs. ${item.product.unitPrice.toStringAsFixed(0)}',
                  style: AppFonts.geistMono(
                    fontSize: context.fontXS,
                    color: ColorResources.labelColor,
                  ),
                ),

                SizedBox(height: context.responsiveHeight(0.004)),

                Row(
                  children: [
                    QtyBtn(
                      icon: Icons.remove,
                      onTap: () => controller.decrementQty(item),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.responsiveWidth(0.007),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: AppFonts.geistMono(
                          fontSize: context.fontSM,
                          fontWeight: FontWeight.w600,
                          color: ColorResources.blackColor,
                        ),
                      ),
                    ),
                    QtyBtn(
                      icon: Icons.add,
                      onTap: () => controller.incrementQty(item),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => controller.removeFromCart(item),
                      child: const Icon(
                        Iconsax.trash,
                        color: ColorResources.gradientRed,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartImagePlaceholder extends StatelessWidget {
  final double size;
  const _CartImagePlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_outlined, color: Colors.grey, size: 20),
    );
  }
}

class QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const QtyBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(
      () => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: theme.secondaryColor.value,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.onSecondaryColor, size: 14),
        ),
      ),
    );
  }
}

class SummarySection extends StatelessWidget {
  final HomeController controller;
  const SummarySection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final _ = controller.discountInput.value;
      if (controller.cartItems.isEmpty) return const SizedBox.shrink(); // hide

      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(
                  'Discount:',
                  'Rs. ${controller.discount.toStringAsFixed(2)}',
                ),
                _SummaryRow('GST:', 'Rs. 0.00'),
                _SummaryRow('C.Voucher:', 'Rs. 0.00'),
                _SummaryRow('G.Voucher:', 'Rs. 0.00'),
                _SummaryRow('Service:', 'Rs. 0.00'),
              ],
            ),
          ),
          SizedBox(width: context.responsiveWidth(0.03)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryRow(
                  'Total Amount:',
                  'Rs. ${controller.productTotal.toStringAsFixed(0)}',
                  isBold: true,
                ),
                _SummaryRow(
                  'Paid Amount:',
                  'Rs. ${controller.subTotal.toStringAsFixed(2)}',
                  isBold: true,
                ),
                _SummaryRow(
                  'Balance:',
                  'Rs. ${controller.balance.toStringAsFixed(0)}',
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _SummaryRow(this.label, this.value, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final style = AppFonts.geistMono(
      fontSize: context.fontXS,
      fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
      color: ColorResources.blackColor,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class BottomButtons extends StatelessWidget {
  final HomeController controller;
  const BottomButtons({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Obx(
      () => Row(
        children: [
          Expanded(
            child: AppButton(
              onPressed: () => controller.getOptions(),
              isLoading: false,
              backgroundColor: theme.primaryColor.value,
              borderRadius: 10,
              child: Text(
                'Options',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w600,
                  color: theme.onPrimaryColor, // auto contrast
                ),
              ),
            ),
          ),
          SizedBox(width: context.responsiveWidth(0.015)),
          Expanded(
            child: AppButton(
              backgroundColor: theme.secondaryColor.value,
              onPressed: () {},
              isLoading: false,
              borderRadius: 10,
              child: Text(
                'Payment',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w500,
                  color: theme.onSecondaryColor, // auto contrast
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductListPanel extends StatelessWidget {
  final HomeController controller;
  const ProductListPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.selectedCategory.value == null) {
        return _buildCategoriesView(context);
      } else if (controller.selectedProduct.value == null) {
        return _buildProductsView(context, controller.selectedCategory.value!);
      } else {
        return _buildVariantsSelectionView(context, controller.selectedProduct.value!);
      }
    });
  }

  Widget _buildCategoriesView(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Column(
      children: [
        _CategorySearchField(controller: controller),
        SizedBox(height: context.responsiveHeight(0.015)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(0.008)),
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
            final _ = controller.categorySearchQuery.value; // rebuild trigger
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
              child: ListView.separated(
                controller: controller.productScrollController,
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: context.responsiveHeight(0.008)),
                itemBuilder: (_, index) => _CategoryRow(
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

  Widget _buildProductsView(BuildContext context, CategoryModel category) {
    final theme = Get.find<AppThemeService>();
    return Column(
      children: [
        // Back Button & Category Title Header
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: ColorResources.blackColor),
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
          ],
        ),
        SizedBox(height: context.responsiveHeight(0.008)),
        // Product Search Field
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
            suffixIcon: const Icon(Icons.search, color: ColorResources.blackColor),
          ),
        ),
        SizedBox(height: context.responsiveHeight(0.015)),
        // Products Grid
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

            return GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (_, i) => _InlineProductCard(
                product: products[i],
                onTap: () => controller.onProductTap(products[i]),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildVariantsSelectionView(BuildContext context, ProductModel product) {
    final theme = Get.find<AppThemeService>();
    final pageController = PageController();
    final currentPage = 0.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: ColorResources.blackColor),
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

        // Scrollable Content (Carousel + Price + Variants list)
        Expanded(
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // PageView Image Carousel
                    if (product.images.isNotEmpty) ...[
                      SizedBox(
                        height: 160,
                        child: PageView.builder(
                          controller: pageController,
                          onPageChanged: (idx) => currentPage.value = idx,
                          itemCount: product.images.length,
                          itemBuilder: (context, index) {
                            final imgUrl = product.images[index].imageUrl ?? '';
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: imgUrl,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                errorWidget: (_, __, ___) => Container(
                                  color: const Color(0xFFE5E7EB),
                                  child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (product.images.length > 1) ...[
                        const SizedBox(height: 8),
                        Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(product.images.length, (index) {
                            final isCurrent = currentPage.value == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isCurrent ? 12 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isCurrent ? theme.secondaryColor.value : Colors.grey[300],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        )),
                      ],
                    ] else ...[
                      Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Pricing
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
                      final price = controller.selectedInlineVariant.value != null
                          ? controller.selectedInlineVariant.value!.effectivePrice
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

                    // Variant Selection
                    Text(
                      'SELECT VARIANT',
                      style: AppFonts.geistMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.variants.map((variant) {
                        final isSelected = controller.selectedInlineVariant.value?.id == variant.id;
                        return ChoiceChip(
                          label: Text(
                            'SKU: ${variant.sku ?? '--'} (${variant.effectivePrice.toStringAsFixed(0)} Rs)',
                            style: AppFonts.geistMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? theme.onSecondaryColor : ColorResources.labelColor,
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
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Fixed bottom buttons pane
        Container(
          padding: const EdgeInsets.only(top: 12.0),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: ColorResources.cardBorderColor, width: 1.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quantity Selector
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
                        icon: const Icon(Icons.remove_circle_outline, size: 22, color: ColorResources.gradientRed),
                        onPressed: controller.decrementInlineQty,
                      ),
                      const SizedBox(width: 8),
                      Obx(() => Text(
                        '${controller.inlineQuantity.value}',
                        style: AppFonts.geistMono(
                          fontSize: context.fontSM,
                          fontWeight: FontWeight.bold,
                          color: ColorResources.labelColor,
                        ),
                      )),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 22, color: ColorResources.successGreen),
                        onPressed: controller.incrementInlineQty,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.selectedProduct.value = null;
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: ColorResources.cardBorderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        foregroundColor: ColorResources.labelColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppFonts.geistMono(fontWeight: FontWeight.bold, fontSize: context.fontXS),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        'Add to Cart',
                        style: AppFonts.geistMono(fontWeight: FontWeight.bold, fontSize: context.fontXS),
                      ),
                    )),
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

class _CategoryRow extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  const _CategoryRow({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return GestureDetector(
      onTap: onTap,
      child: Obx(() => Container(
        margin: EdgeInsets.symmetric(horizontal: context.responsiveWidth(0.006)),
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(0.014),
          vertical: context.responsiveHeight(0.012),
        ),
        decoration: BoxDecoration(
          color: ColorResources.whiteColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorResources.cardBorderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: theme.secondaryColor.value.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Text(
                category.displayName.isNotEmpty
                    ? category.displayName[0].toUpperCase()
                    : '?',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w700,
                  color: theme.secondaryColor.value,
                ),
              ),
            ),
            SizedBox(width: context.responsiveWidth(0.012)),
            Expanded(
              child: Text(
                category.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w600,
                  color: ColorResources.blackColor,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
          ],
        ),
      )),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: product.primaryImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.primaryImageUrl!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFE5E7EB),
                          child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 20),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFE5E7EB),
                        child: const Icon(Icons.image_outlined, color: Colors.grey, size: 20),
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
    return TextField(
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
        suffixIcon: const Icon(Icons.search, color: ColorResources.blackColor),
      ),
    );
  }
}





