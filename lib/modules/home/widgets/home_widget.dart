import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/home/model/cart_item_model.dart';
import 'package:modfirstpos/modules/home/model/product_item.dart';
import 'package:modfirstpos/routes/app_routes.dart';
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
                    fit: BoxFit.cover,
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
                    _QtyBtn(
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
                    _QtyBtn(
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

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

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
    final theme = Get.find<AppThemeService>();
    return Column(
      children: [
        _ProductSearchField(controller: controller),
        SizedBox(height: context.responsiveHeight(0.015)),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.secondaryColor.value,
                  strokeWidth: 3.0,
                ),
              );
            }

            final products = controller.filteredPinnedProducts;

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
                      'Add Products From Catalogue to \n save them here for quick access',
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        color: ColorResources.blackColor.withOpacity(0.4),
                      ),
                    ),
                    SizedBox(height: context.spacingSM),
                    SizedBox(
                      width: context.responsiveWidth(0.2),
                      child: AppButton(
                        onPressed: () => Get.toNamed(Routes.catalogue),
                        backgroundColor: theme.secondaryColor.value,
                        borderRadius: 8,
                        isLoading: false,
                        child: Text(
                          'Go to Catalogue',
                          style: AppFonts.geistMono(
                            fontSize: context.fontSM,
                            fontWeight: FontWeight.w600,
                            color: theme.onSecondaryColor,
                          ),
                        ),
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
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox.shrink(),
                itemBuilder: (_, index) => _PinnedProductRow(
                  product: products[index],
                  onTap: () => controller.addToCartFromItem(products[index]),
                  onRemove: () =>
                      controller.removePinnedProduct(products[index]),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PinnedProductRow extends StatelessWidget {
  final ProductItem product;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PinnedProductRow({
    required this.product,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final imgSize = context.responsiveWidth(0.042);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: context.responsiveHeight(0.004),
          horizontal: context.responsiveWidth(0.006),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(0.012),
          vertical: context.responsiveHeight(0.010),
        ),
        decoration: BoxDecoration(
          color: ColorResources.whiteColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorResources.cardBorderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      width: imgSize,
                      height: imgSize,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _ImgPlaceholder(size: imgSize),
                      errorWidget: (_, __, ___) =>
                          _ImgPlaceholder(size: imgSize),
                    )
                  : _ImgPlaceholder(size: imgSize),
            ),

            SizedBox(width: context.responsiveWidth(0.010)),

            // ── Name + SKU info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product name
                  Text(
                    product.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.geistMono(
                      fontSize: context.fontXS,
                      fontWeight: FontWeight.w600,
                      color: ColorResources.blackColor,
                    ),
                  ),

                  SizedBox(height: context.responsiveHeight(0.003)),

                  Row(
                    children: [
                      _MetaChip(label: 'SKU', value: product.skuCode ?? '--'),
                      SizedBox(width: context.responsiveWidth(0.012)),
                      _MetaChip(
                        label: 'Old SKU',
                        value: product.oldSkuCode ?? '--',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: context.responsiveWidth(0.008)),

            // ── Price
            Text(
              'Rs.${(product.productPrice ?? 0).toStringAsFixed(0)}',
              style: AppFonts.geistMono(
                fontSize: context.fontXS,
                fontWeight: FontWeight.w500,
                color: ColorResources.blackColor,
              ),
            ),

            SizedBox(width: context.responsiveWidth(0.010)),

            // ── Add to cart button
            Obx(
              () => GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveWidth(0.008),
                    vertical: context.responsiveHeight(0.006),
                  ),
                  decoration: BoxDecoration(
                    color: theme.secondaryColor.value,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.shopping_cart,
                        size: 11,
                        color: theme.onSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Add',
                        style: AppFonts.geistMono(
                          fontSize: context.fontXS - 1,
                          fontWeight: FontWeight.w500,
                          color: theme.onSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: context.responsiveWidth(0.005)),

            // ── Remove button
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  border: Border.all(color: ColorResources.cardBorderColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.close, size: 13, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;
  const _MetaChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppFonts.geistMono(
            fontSize: context.fontXS - 2,
            color: ColorResources.labelColor.withOpacity(0.45),
            height: 1.2,
          ),
        ),
        Text(
          value,
          style: AppFonts.geistMono(
            fontSize: context.fontXS - 1,
            color: ColorResources.greyColor,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _ImgPlaceholder extends StatelessWidget {
  final double size;
  const _ImgPlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_outlined, size: 16, color: Colors.grey),
    );
  }
}

class _ProductSearchField extends StatelessWidget {
  final HomeController controller;
  const _ProductSearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.searchController,
      style: AppFonts.geistMono(fontSize: context.fontSM),
      decoration: InputDecoration(
        filled: true,
        fillColor: ColorResources.whiteColor,
        hintText: 'Search Product',
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
