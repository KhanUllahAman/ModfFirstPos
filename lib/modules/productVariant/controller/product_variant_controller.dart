import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/home/model/product_item.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class ProductVariantController extends GetxController {
  late final ProductModel product;
  final Rx<ProductVariantModel?> selectedVariant = Rx<ProductVariantModel?>(null);
  final RxBool addedToCart = false.obs;
  final RxInt quantity = 1.obs;

  /// Dedicated controller for the variant list scrollbar; a Scrollbar without
  /// its own controller falls back to the PrimaryScrollController, which can
  /// be attached to multiple scroll views on this layout.
  late final ScrollController variantScrollController;

  HomeController get _home => Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    variantScrollController = ScrollController();
    product = Get.arguments as ProductModel;
    if (product.variants.isNotEmpty) {
      selectedVariant.value = product.variants.first;
    }
  }

  @override
  void onClose() {
    variantScrollController.dispose();
    super.onClose();
  }

  void selectVariant(ProductVariantModel variant) {
    selectedVariant.value = variant;
    addedToCart.value = false;
  }

  void incrementQty() {
    quantity.value++;
    addedToCart.value = false;
  }

  void decrementQty() {
    if (quantity.value > 1) quantity.value--;
    addedToCart.value = false;
  }

  double get displayPrice {
    final variant = selectedVariant.value;
    if (variant != null) return variant.effectivePrice;
    return product.effectivePrice;
  }

  String get displaySku => selectedVariant.value?.sku ?? product.sku ?? '--';

  /// Current stock for the selected variant, or the product itself when it
  /// has no variants; null means untracked (never blocks the add).
  int? get availableStock {
    final variant = selectedVariant.value;
    return variant != null ? variant.stockQuantity : product.stock;
  }

  void addToCart() {
    final stock = availableStock;
    if (stock != null && quantity.value > stock) {
      customSnackBar(
        stock <= 0 ? 'Out of Stock' : 'Insufficient Stock',
        stock <= 0
            ? '${product.displayName} is out of stock.'
            : 'Only $stock unit(s) of ${product.displayName} available.',
        snackBarType: SnackBarType.error,
      );
      return;
    }
    final variant = selectedVariant.value;
    final item = ProductItem(
      id: product.id?.toString() ?? '',
      name: product.displayName,
      skuCode: displaySku,
      oldSkuCode: null,
      imageUrl: product.primaryImageUrl,
      productPrice: displayPrice,
      productId: product.id,
      variantId: variant?.id,
    );
    _home.addToCartFromItem(item, quantity: quantity.value);
    addedToCart.value = true;
  }

  /// Pins the product (with the selected variant) for quick access on the
  /// POS home screen. Pins are persisted locally.
  void pinProduct() {
    _home.pinProduct(product, variant: selectedVariant.value);
  }

  void goToCart() {
    Get.until((route) => route.settings.name == Routes.home);
  }
}