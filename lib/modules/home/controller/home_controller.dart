import 'package:modfirstpos/core/utils/currency_utils.dart';
import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/modules/category/service/category_service.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/modules/product/service/product_service.dart';
import 'package:modfirstpos/modules/home/model/cart_item_model.dart';
import 'package:modfirstpos/modules/home/model/product_item.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/home/model/suspended_order_model.dart';
import 'package:modfirstpos/modules/home/repository/sales_local_repository.dart';
import 'package:modfirstpos/modules/home/repository/suspended_order_repository.dart';
import 'package:modfirstpos/core/database/key_value_store.dart';
import 'package:modfirstpos/core/services/sync_service.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class HomeController extends GetxController {
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();

  final Rxn<CustomerModel> selectedCartCustomer = Rxn<CustomerModel>();
  final RxBool showCustomerPanel = false.obs;
  final RxBool showCheckoutPanel = false.obs;

  final TextEditingController scanController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController productSearchController = TextEditingController();

  late ScrollController cartScrollController;
  late ScrollController productScrollController;
  late ScrollController customerListScrollController;
  late ScrollController variantPanelScrollController;

  final RxBool isLoading = false.obs;
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxString discountInput = ''.obs;
  final RxList<ProductItem> _pinnedProducts = <ProductItem>[].obs;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxString categorySearchQuery = ''.obs;

  // New Category-Product flow inline states
  final Rxn<CategoryModel> selectedCategory = Rxn<CategoryModel>();
  final RxList<ProductModel> categoryProducts = <ProductModel>[].obs;
  final RxBool isProductsLoading = false.obs;
  final RxString productSearchQuery = ''.obs;
  final Rxn<ProductModel> selectedProduct = Rxn<ProductModel>();
  final Rxn<ProductVariantModel> selectedInlineVariant = Rxn<ProductVariantModel>();
  final RxInt inlineQuantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    cartScrollController = ScrollController();
    productScrollController = ScrollController();
    customerListScrollController = ScrollController();
    variantPanelScrollController = ScrollController();
    loadCategories();
    _loadPinnedProducts();
  }

  @override
  void onClose() {
    scanController.dispose();
    searchController.dispose();
    productSearchController.dispose();
    cartScrollController.dispose();
    productScrollController.dispose();
    customerListScrollController.dispose();
    variantPanelScrollController.dispose();
    super.onClose();
  }


  Future<void> loadCategories({bool forceSync = false}) async {
    try {
      isCategoriesLoading.value = true;
      final response = await _categoryService.fetchCategories(
        page: 1,
        limit: 20,
        isActive: true,
        forceSync: forceSync,
      );
      if (response.isSuccess) {
        categories.assignAll(response.payload);
        if (forceSync) {
          customSnackBar(
            'Synced Successfully',
            'Fresh categories loaded from server',
            snackBarType: SnackBarType.success,
          );
        }
      }
    } catch (e) {
      log("HomeController loadCategories error: $e");
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> syncCategories() async {
    await loadCategories(forceSync: true);
  }

  Future<void> loadCategoryProducts(int? categoryId, {bool forceSync = false}) async {
    if (categoryId == null) return;
    try {
      isProductsLoading.value = true;
      final response = await _productService.fetchProducts(
        page: 1,
        limit: 50, // fetch a batch of products to show inline
        categoryId: categoryId,
        status: 'published',
        isActive: true,
        forceSync: forceSync,
      );
      if (response.isSuccess) {
        categoryProducts.assignAll(response.payload);
        if (forceSync) {
          customSnackBar(
            'Synced Successfully',
            'Fresh products loaded from server',
            snackBarType: SnackBarType.success,
          );
        }
      } else {
        categoryProducts.clear();
      }
    } catch (e) {
      log("HomeController loadCategoryProducts error: $e");
    } finally {
      isProductsLoading.value = false;
    }
  }

  Future<void> syncCategoryProducts() async {
    if (selectedCategory.value?.id != null) {
      await loadCategoryProducts(selectedCategory.value!.id, forceSync: true);
    }
  }


  List<CategoryModel> get filteredCategories {
    final query = categorySearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return categories;
    return categories
        .where((c) => c.displayName.toLowerCase().contains(query))
        .toList();
  }

  List<ProductModel> get filteredProducts {
    final query = productSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return categoryProducts;
    return categoryProducts
        .where((p) => p.displayName.toLowerCase().contains(query))
        .toList();
  }

  void onCategorySearchChanged(String val) => categorySearchQuery.value = val;

  void onProductSearchChanged(String val) => productSearchQuery.value = val;

  void onCategoryTap(CategoryModel category) {
    selectedCategory.value = category;
    selectedProduct.value = null;
    productSearchController.clear();
    productSearchQuery.value = '';
    loadCategoryProducts(category.id);
  }

  void onProductTap(ProductModel product) {
    if (product.hasVariants) {
      selectedProduct.value = product;
      if (product.variants.isNotEmpty) {
        selectedInlineVariant.value = product.variants.first;
      } else {
        selectedInlineVariant.value = null;
      }
      inlineQuantity.value = 1;
    } else {
      addToCartFromProduct(product);
    }
  }

  void incrementInlineQty() {
    inlineQuantity.value++;
  }

  void decrementInlineQty() {
    if (inlineQuantity.value > 1) {
      inlineQuantity.value--;
    }
  }

  List<ProductItem> get filteredPinnedProducts {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _pinnedProducts;
    return _pinnedProducts
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  void addToCartFromItem(ProductItem product, {int quantity = 1}) {
    _addOrIncrementCartItem(
      name: product.name,
      displayName: product.displayName,
      sku: product.skuCode ?? '--',
      imageUrl: product.imageUrl,
      unitPrice: product.productPrice ?? 0,
      quantity: quantity,
      productId: product.productId,
      variantId: product.variantId,
    );
  }

  void addToCartFromProduct(
    ProductModel product, {
    ProductVariantModel? variant,
    int quantity = 1,
  }) {
    final sku = variant?.sku ?? product.sku ?? '--';
    final price = variant?.effectivePrice ?? product.effectivePrice;
    final displayName = variant != null
        ? '${product.displayName} (${variant.sku})'
        : product.displayName;
    _addOrIncrementCartItem(
      name: displayName,
      displayName: displayName,
      sku: sku,
      imageUrl: product.primaryImageUrl,
      unitPrice: price,
      quantity: quantity,
      productId: product.id,
      variantId: variant?.id,
    );
  }

  /// Adds a line to the cart, or bumps the quantity when the SKU is already
  /// in the cart. Single source of truth for all add-to-cart flows.
  void _addOrIncrementCartItem({
    required String name,
    required String displayName,
    required String sku,
    required String? imageUrl,
    required double unitPrice,
    required int quantity,
    int? productId,
    int? variantId,
  }) {
    final existingIndex =
        cartItems.indexWhere((c) => c.product.skuCode == sku);

    if (existingIndex != -1) {
      cartItems[existingIndex].quantity += quantity;
      cartItems.refresh();
      customSnackBar(
        'Already in Cart',
        '$displayName qty increased to ${cartItems[existingIndex].quantity}',
        snackBarType: SnackBarType.info,
      );
      return;
    }

    cartItems.add(
      CartItemModel(
        product: CartProduct(
          name: name,
          skuCode: sku,
          imageUrl: imageUrl,
          amount: unitPrice,
          unitPrice: unitPrice,
          productId: productId,
          variantId: variantId,
        ),
        quantity: quantity,
      ),
    );

    customSnackBar(
      'Added to Cart',
      '$displayName added successfully',
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

  // ------------------------------------------------------------------------
  // Pinned products (persisted locally, offline-first)
  // ------------------------------------------------------------------------

  static const _pinnedProductsCacheKey = 'pinned_products';

  /// When true, the right-hand panel shows the pinned products list.
  final RxBool showPinnedPanel = false.obs;

  List<ProductItem> get pinnedProducts => _pinnedProducts;

  Future<void> _loadPinnedProducts() async {
    try {
      final cached = await KeyValueStore.getJsonCache(_pinnedProductsCacheKey);
      if (cached != null) {
        _pinnedProducts.assignAll(
          JsonUtils.asModelList(cached['items'], ProductItem.fromJson),
        );
      }
    } catch (e) {
      log('HomeController _loadPinnedProducts error: $e');
    }
  }

  Future<void> _persistPinnedProducts() async {
    await KeyValueStore.setJsonCache(_pinnedProductsCacheKey, {
      'items': _pinnedProducts.map((p) => p.toJson()).toList(),
    });
  }

  bool isPinned(String productId) =>
      _pinnedProducts.any((p) => p.id == productId);

  void removePinnedProduct(ProductItem product) {
    _pinnedProducts.removeWhere((p) => p.id == product.id);
    _persistPinnedProducts();
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
    _persistPinnedProducts();
    customSnackBar(
      'Added',
      '${product.displayName} added to quick access list',
      snackBarType: SnackBarType.success,
    );
  }

  /// Pins a full product (optionally a specific variant) for quick access.
  void pinProduct(ProductModel product, {ProductVariantModel? variant}) {
    final sku = variant?.sku ?? product.sku;
    final price = variant?.effectivePrice ?? product.effectivePrice;
    final name = variant != null
        ? '${product.displayName} (${variant.sku})'
        : product.displayName;
    addPinnedProduct(
      ProductItem(
        id: variant != null
            ? '${product.id ?? ''}-v${variant.id ?? ''}'
            : (product.id?.toString() ?? name),
        name: name,
        skuCode: sku,
        imageUrl: product.primaryImageUrl,
        productPrice: price,
        productId: product.id,
        variantId: variant?.id,
      ),
    );
  }

  void openPinnedPanel() => showPinnedPanel.value = true;

  void closePinnedPanel() => showPinnedPanel.value = false;

  double get productTotal =>
      cartItems.fold(0.0, (sum, item) => sum + item.total);

  double get discount {
    final value = double.tryParse(discountInput.value);
    return value ?? 0.0;
  }

  double get subTotal => productTotal - discount;

  double get balance => subTotal < 0 ? 0 : subTotal;

  void clearCart() {
    cartItems.clear();
    selectedCartCustomer.value = null;
  }

  // ------------------------------------------------------------------------
  // Suspend / Resume / Void
  // ------------------------------------------------------------------------

  final RxList<SuspendedOrderModel> suspendedOrders =
      <SuspendedOrderModel>[].obs;

  /// Parks the current order (customer, cart, discounts, totals) locally so
  /// the cashier can serve another customer and resume later.
  Future<bool> suspendCurrentOrder() async {
    if (cartItems.isEmpty) {
      customSnackBar(
        'Nothing to Suspend',
        'Add items to the cart before suspending an order',
        snackBarType: SnackBarType.warning,
      );
      return false;
    }
    try {
      final order = SuspendedOrderModel(
        customer: selectedCartCustomer.value,
        items: cartItems.map((e) => e).toList(),
        discountInput: discountInput.value,
        taxAmount: 0,
        total: balance,
        createdAt: DateTime.now().toIso8601String(),
      );
      await SuspendedOrderRepository.suspend(order);
      _resetSale();
      customSnackBar(
        'Order Suspended',
        'The order was parked and can be resumed anytime',
        snackBarType: SnackBarType.success,
      );
      return true;
    } catch (e) {
      log('HomeController suspendCurrentOrder error: $e');
      customSnackBar(
        'Suspend Failed',
        'The order could not be saved locally',
        snackBarType: SnackBarType.error,
      );
      return false;
    }
  }

  Future<void> loadSuspendedOrders() async {
    try {
      suspendedOrders.assignAll(await SuspendedOrderRepository.getAll());
    } catch (e) {
      log('HomeController loadSuspendedOrders error: $e');
    }
  }

  /// Restores a suspended session exactly as it was before suspension.
  Future<void> resumeSuspendedOrder(SuspendedOrderModel order) async {
    cartItems.assignAll(order.items);
    selectedCartCustomer.value = order.customer;
    discountInput.value = order.discountInput;
    if (order.id != null) {
      await SuspendedOrderRepository.remove(order.id!);
      suspendedOrders.removeWhere((o) => o.id == order.id);
    }
    customSnackBar(
      'Order Resumed',
      'The suspended order was restored to the cart',
      snackBarType: SnackBarType.success,
    );
  }

  /// Clears the whole sale and returns the POS to its initial state.
  /// Call after explicit confirmation only.
  void voidCurrentOrder() {
    _resetSale();
    customSnackBar(
      'Order Voided',
      'The order was cleared',
      snackBarType: SnackBarType.info,
    );
  }

  void _resetSale() {
    cartItems.clear();
    selectedCartCustomer.value = null;
    discountInput.value = '';
    showCashPanel.value = false;
    showCheckoutPanel.value = false;
    cashReceivedInput.value = '';
  }

  // ------------------------------------------------------------------------
  // Payment (cash)
  // ------------------------------------------------------------------------

  /// When true, the right-hand panel shows the cash payment keypad.
  final RxBool showCashPanel = false.obs;

  /// Amount typed on the POS keypad (kept as a string for display control).
  final RxString cashReceivedInput = ''.obs;

  double get cashReceived => double.tryParse(cashReceivedInput.value) ?? 0.0;

  double get changeDue {
    final change = cashReceived - balance;
    return change > 0 ? change : 0.0;
  }

  bool get canConfirmCashPayment =>
      cartItems.isNotEmpty && cashReceived >= balance && balance > 0;

  void openCashPayment() {
    if (cartItems.isEmpty) {
      customSnackBar(
        'Empty Cart',
        'Add items to the cart before taking a payment',
        snackBarType: SnackBarType.warning,
      );
      return;
    }
    cashReceivedInput.value = '';
    showCashPanel.value = true;
  }

  void closeCashPayment() {
    showCashPanel.value = false;
    cashReceivedInput.value = '';
  }

  void keypadAppend(String digit) {
    final current = cashReceivedInput.value;
    if (digit == '.' && current.contains('.')) return;
    // Cap decimals at 2 places.
    final dotIndex = current.indexOf('.');
    if (dotIndex != -1 && digit != '.' && current.length - dotIndex > 2) {
      return;
    }
    if (current.replaceAll('.', '').length >= 9) return;
    cashReceivedInput.value =
        (current == '0' && digit != '.') ? digit : current + digit;
  }

  void keypadBackspace() {
    final current = cashReceivedInput.value;
    if (current.isEmpty) return;
    cashReceivedInput.value = current.substring(0, current.length - 1);
  }

  void keypadClear() => cashReceivedInput.value = '';

  void setExactCash() =>
      cashReceivedInput.value = balance.toStringAsFixed(2);

  void addQuickAmount(double amount) {
    cashReceivedInput.value = (cashReceived + amount).toStringAsFixed(2);
  }

  /// Completes the cash sale: records it locally (offline-first) with a
  /// locally generated invoice number, then lets the sync service push it.
  Future<void> confirmCashPayment() async {
    if (!canConfirmCashPayment) {
      customSnackBar(
        'Insufficient Cash',
        'Received amount must cover the payable balance',
        snackBarType: SnackBarType.warning,
      );
      return;
    }
    try {
      final customer = selectedCartCustomer.value;
      final invoiceNumber = await SalesLocalRepository.recordSale({
        'channel': 'pos',
        'payment_method': 'cash',
        'customer_id': customer?.id,
        'customer_name': customer?.fullName,
        'customer_email': customer?.email,
        'items': cartItems
            .map((item) => {
                  'name': item.product.name,
                  'sku': item.product.skuCode,
                  'quantity': item.quantity,
                  'unit_price': item.product.unitPrice,
                  'total': item.total,
                })
            .toList(),
        'subtotal': productTotal,
        'discount_amount': discount,
        'total_amount': balance,
        'cash_received': cashReceived,
        'change_due': changeDue,
        'order_date': DateTime.now().toIso8601String(),
      });

      final change = changeDue;
      _resetSale();
      customSnackBar(
        'Payment Complete',
        'Invoice $invoiceNumber'
        '${change > 0 ? ' • Change ${CurrencyUtils.format(change, decimals: 2)}' : ''}',
        snackBarType: SnackBarType.success,
      );

      // Push in the background when online; never blocks the cashier.
      if (Get.isRegistered<SyncService>()) {
        Get.find<SyncService>().syncNow();
      }
    } catch (e) {
      log('HomeController confirmCashPayment error: $e');
      customSnackBar(
        'Payment Failed',
        'The sale could not be recorded. Please try again.',
        snackBarType: SnackBarType.error,
      );
    }
  }
}
