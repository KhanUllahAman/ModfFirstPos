import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/home/model/cart_item_model.dart';
import 'package:modfirstpos/modules/home/model/product_item.dart';
import 'package:modfirstpos/modules/home/service/home_service.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class HomeController extends GetxController {
  final HomeService _service = HomeService();
  final TextEditingController scanController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final ScrollController cartScrollController = ScrollController();
  final ScrollController productScrollController = ScrollController();
  final RxBool isLoading = false.obs;
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxString discountInput = ''.obs;
  final RxList<ProductItem> _pinnedProducts = <ProductItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    // _loadStaticData();
  }

  @override
  void onClose() {
    scanController.dispose();
    searchController.dispose();
    cartScrollController.dispose();
    productScrollController.dispose();
    super.onClose();
  }

  List<ProductItem> get filteredPinnedProducts {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _pinnedProducts;
    return _pinnedProducts
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  void addToCartFromItem(ProductItem product) {
    final existingIndex = cartItems.indexWhere(
      (c) => c.product.skuCode == product.skuCode,
    );

    if (existingIndex != -1) {
      cartItems[existingIndex].quantity++;
      cartItems.refresh();
      customSnackBar(
        'Already in Cart',
        '${product.displayName} qty increased to ${cartItems[existingIndex].quantity}',
        snackBarType: SnackBarType.info,
      );
      return;
    }

    cartItems.add(
      CartItemModel(
        product: CartProduct(
          name: product.name,
          skuCode: product.skuCode ?? '--',
          imageUrl: product.imageUrl,
          amount: product.productPrice ?? 0,
          unitPrice: product.productPrice ?? 0,
        ),
      ),
    );

    customSnackBar(
      'Added to Cart',
      '${product.displayName} added successfully',
      snackBarType: SnackBarType.success,
    );
  }

  void incrementQty(CartItemModel item) {
    item.quantity++;
    cartItems.refresh();
  }

  void decrementQty(CartItemModel item) {
    if (item.quantity <= 1) {
      removeFromCart(item);
      return;
    }
    item.quantity--;
    cartItems.refresh();
  }

  void removeFromCart(CartItemModel item) {
    cartItems.remove(item);
  }

  void removePinnedProduct(ProductItem product) {
    _pinnedProducts.removeWhere((p) => p.id == product.id);
  }

  void addPinnedProduct(ProductItem product) {
    final alreadyPinned = _pinnedProducts.any((p) => p.id == product.id);
    if (alreadyPinned) {
      customSnackBar(
        'Already Added',
        '${product.displayName} is already in your quick access list',
        snackBarType: SnackBarType.warning,
      );
      return;
    }
    _pinnedProducts.add(product);
    customSnackBar(
      'Added',
      '${product.displayName} added to quick access list',
      snackBarType: SnackBarType.success,
    );
  }

  double get productTotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.total);

  double get discount {
    final value = double.tryParse(discountInput.value);
    return value ?? 0.0;
  }

  double get subTotal => productTotal - discount;

  double get balance => subTotal < 0 ? 0 : subTotal;

  void getOptions() {}
}