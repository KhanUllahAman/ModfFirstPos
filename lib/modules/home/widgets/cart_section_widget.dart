import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/home/model/cart_item_model.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:flutter_svg/svg.dart';

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
          Obx(() => SvgPicture.asset(
            color: theme.secondaryColor.value,
            ImagesConstant.emptyCartSvg,
            height: context.responsiveHeight(0.18),
          )),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.product.imageUrl != null &&
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
