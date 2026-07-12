import 'package:get/get.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/home/model/product_item.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/routes/app_routes.dart';

class ProductVariantController extends GetxController {
  late final ProductModel product;
  final Rx<ProductVariantModel?> selectedVariant = Rx<ProductVariantModel?>(null);
  final RxBool addedToCart = false.obs;
  final RxInt quantity = 1.obs;

  HomeController get _home => Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    product = Get.arguments as ProductModel;
    if (product.variants.isNotEmpty) {
      selectedVariant.value = product.variants.first;
    }
  }

  void selectVariant(ProductVariantModel variant) {
    selectedVariant.value = variant;
  }

  void incrementQty() => quantity.value++;

  void decrementQty() {
    if (quantity.value > 1) quantity.value--;
  }

  double get displayPrice {
    final variant = selectedVariant.value;
    if (variant != null) return variant.effectivePrice;
    return product.effectivePrice;
  }

  String get displaySku => selectedVariant.value?.sku ?? product.sku ?? '--';

  void addToCart() {
    final item = ProductItem(
      id: product.id?.toString() ?? '',
      name: product.displayName,
      skuCode: displaySku,
      oldSkuCode: null,
      imageUrl: product.primaryImageUrl,
      productPrice: displayPrice,
    );
    _home.addToCartFromItem(item, quantity: quantity.value);
    addedToCart.value = true;
  }

  void goToCart() {
    Get.until((route) => route.settings.name == Routes.home);
  }
}