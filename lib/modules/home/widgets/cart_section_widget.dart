import 'package:modfirstpos/core/utils/currency_utils.dart';
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
import 'package:modfirstpos/modules/home/widgets/add_custom_sale_dialog.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:flutter_svg/svg.dart';

class CartSection extends StatelessWidget {
  final HomeController controller;
  const CartSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(() {
      final hasCustomer = controller.selectedCartCustomer.value != null;
      final customer = controller.selectedCartCustomer.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (hasCustomer)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.secondaryColor.value.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.secondaryColor.value.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.user_tag,
                          size: 18,
                          color: theme.secondaryColor.value,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer?.fullName ?? 'Unnamed Customer',
                                style: AppFonts.geistMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: ColorResources.labelColor,
                                ),
                              ),
                              Text(
                                customer?.email ?? 'No Email',
                                style: AppFonts.geistMono(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            controller.selectedCartCustomer.value = null;
                          },
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                )
              else
                TextButton.icon(
                  onPressed: () {
                    controller.showCustomerPanel.value = true;
                  },
                  icon: const Icon(
                    Iconsax.user_add,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Add Customer',
                    style: AppFonts.geistMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: theme.secondaryColor.value,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => AddCustomSaleDialog.show(context),
                icon: const Icon(
                  Icons.add_shopping_cart_rounded,
                  size: 17,
                  color: Colors.white,
                ),
                label: Text(
                  'Add Custom Sale',
                  style: AppFonts.geistMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: theme.secondaryColor.value,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 1,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              if (controller.cartItems.isNotEmpty) const SizedBox(width: 8),
              if (controller.cartItems.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    controller.clearCart();
                  },
                  icon: const Icon(
                    Icons.delete_sweep_rounded,
                    size: 16,
                    color: ColorResources.gradientRed,
                  ),
                  label: Text(
                    'Delete All',
                    style: AppFonts.geistMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ColorResources.gradientRed,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: ColorResources.gradientRed.withOpacity(
                      0.12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: controller.cartItems.isEmpty
                ? const _EmptyCart()
                : Scrollbar(
                    controller: controller.cartScrollController,
                    thumbVisibility: true,
                    thickness: 5,
                    radius: const Radius.circular(8),
                    scrollbarOrientation: ScrollbarOrientation.right,
                    child: ListView.separated(
                      controller: controller.cartScrollController,
                      padding: EdgeInsets.only(
                        right: context.responsiveWidth(0.018),
                      ),
                      itemCount: controller.cartItems.length,
                      separatorBuilder: (_, __) =>
                          SizedBox(height: context.responsiveHeight(0.010)),
                      itemBuilder: (_, index) => _CartItemTile(
                        item: controller.cartItems[index],
                        controller: controller,
                      ),
                    ),
                  ),
          ),
        ],
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
          Obx(
            () => SvgPicture.asset(
              color: theme.secondaryColor.value,
              ImagesConstant.emptyCartSvg,
              height: context.responsiveHeight(0.18),
            ),
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

class _CartItemTile extends StatefulWidget {
  final CartItemModel item;
  final HomeController controller;
  const _CartItemTile({required this.item, required this.controller});

  @override
  State<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<_CartItemTile> {
  late final TextEditingController _qtyController;
  late final FocusNode _qtyFocusNode;

  CartItemModel get item => widget.item;
  HomeController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '${item.quantity}');
    _qtyFocusNode = FocusNode();
    _qtyFocusNode.addListener(() {
      if (_qtyFocusNode.hasFocus) {
        _qtyController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _qtyController.text.length,
        );
      } else {
        _submitQty();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _CartItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_qtyFocusNode.hasFocus && _qtyController.text != '${item.quantity}') {
      _qtyController.text = '${item.quantity}';
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _qtyFocusNode.dispose();
    super.dispose();
  }

  void _submitQty() {
    final parsed = int.tryParse(_qtyController.text.trim());
    if (parsed == null) {
      _qtyController.text = '${item.quantity}';
      return;
    }
    controller.setQty(item, parsed);
    _qtyController.text = '${item.quantity}';
  }

  @override
  Widget build(BuildContext context) {
    final imgSize = context.responsiveHeight(0.075);
    final theme = Get.find<AppThemeService>();
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
            child: item.product.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: item.product.imageUrl!,
                    width: imgSize,
                    height: imgSize,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      width: imgSize,
                      height: imgSize,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 20,
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[200],
                    width: imgSize,
                    height: imgSize,
                    child: const Icon(Icons.image_outlined, size: 20),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.geistMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ColorResources.labelColor,
                  ),
                ),
                if (item.product.skuCode.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'SKU: ${item.product.skuCode}',
                    style: AppFonts.geistMono(
                      fontSize: 8,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CurrencyUtils.format(item.product.unitPrice, decimals: 0),
                      style: AppFonts.geistMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.secondaryColor.value,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            size: 16,
                          ),
                          onPressed: () => controller.decrementQty(item),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          color: ColorResources.gradientRed,
                        ),
                        Container(
                          width: 34,
                          height: 26,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: theme.secondaryColor.value.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: theme.secondaryColor.value.withOpacity(
                                0.3,
                              ),
                            ),
                          ),
                          child: TextField(
                            controller: _qtyController,
                            focusNode: _qtyFocusNode,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: AppFonts.geistMono(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: ColorResources.blackColor,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _submitQty(),
                            onTapOutside: (_) => _qtyFocusNode.unfocus(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          onPressed: () => controller.incrementQty(item),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          color: ColorResources.successGreen,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                          ),
                          onPressed: () => controller.removeFromCart(item),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.only(left: 6.0),
                          color: Colors.grey[600],
                          tooltip: 'Remove item',
                        ),
                      ],
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
