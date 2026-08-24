import 'package:modfirstpos/core/utils/currency_utils.dart';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/bootstrap/controller/bootstrap_controller.dart';
import 'package:modfirstpos/core/services/app_update_service.dart';
import 'package:modfirstpos/core/services/customer_display_service.dart';
import 'package:modfirstpos/core/storage/customer_display_settings_storage.dart';
import 'package:modfirstpos/modules/setting/storage/pos_device_cache_storage.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
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
  final BootstrapController _bootstrapController =
      Get.find<BootstrapController>();
  final CustomerDisplayClientService _customerDisplay =
      Get.find<CustomerDisplayClientService>();

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
  final Rxn<ProductVariantModel> selectedInlineVariant =
      Rxn<ProductVariantModel>();
  final RxInt inlineQuantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    cartScrollController = ScrollController();
    productScrollController = ScrollController();
    customerListScrollController = ScrollController();
    variantPanelScrollController = ScrollController();
    _bootstrapController.hydrateFromCache().then(
      (_) => _refreshFromBootstrap(),
    );
    ever(_bootstrapController.data, (_) => _refreshFromBootstrap());
    _loadPinnedProducts();
    _connectCustomerDisplay();
    ever(cartItems, (_) => _pushCustomerDisplay());
    ever(discountInput, (_) => _pushCustomerDisplay());
    unawaited(AppUpdateService.checkForUpdate());
  }

  /// Connects to the customer-facing tab (Settings > Customer IP) so cart
  /// changes can be mirrored there in real time.
  Future<void> _connectCustomerDisplay() async {
    final device = await PosDeviceCacheStorage.getDevice();
    final ip = device?.customerIp;
    if (ip != null && ip.trim().isNotEmpty) {
      final code = await CustomerDisplaySettingsStorage.getPairingCode();
      await _customerDisplay.connect(ip, pairingCode: code);
    }
  }

  void _pushCustomerDisplay() {
    final store = _bootstrapController.data.value?.store;
    _customerDisplay.pushCartUpdate(
      items: cartItems
          .map(
            (c) => CustomerDisplayItem(
              name: c.product.name,
              quantity: c.quantity,
              unitPrice: c.product.unitPrice,
              total: c.total,
              imageUrl: c.product.imageUrl,
            ),
          )
          .toList(),
      subtotal: productTotal,
      discount: discount,
      total: balance,
      currencySymbol: store?.currencySymbol,
      storeName: store?.siteName,
    );
  }

  /// Categories/products come straight from the offline-first bootstrap
  /// snapshot (synced on shift-open) — no network call, always instant.
  void _refreshFromBootstrap() {
    categories.assignAll(_bootstrapController.categories);
    final categoryId = selectedCategory.value?.id;
    if (categoryId != null) {
      categoryProducts.assignAll(
        _bootstrapController.productsForCategory(categoryId),
      );
    }

    // Keeps an already-open variant-selection panel live too — otherwise a
    // stock/price push patching the catalogue in the background wouldn't
    // show up here until the cashier re-taps the product.
    final selectedProductId = selectedProduct.value?.id;
    if (selectedProductId != null) {
      final refreshed = _bootstrapController.allProducts.firstWhereOrNull(
        (p) => p.id == selectedProductId,
      );
      if (refreshed != null) {
        selectedProduct.value = refreshed;
        final variantId = selectedInlineVariant.value?.id;
        if (variantId != null) {
          selectedInlineVariant.value = refreshed.variants.firstWhereOrNull(
            (v) => v.id == variantId,
          );
        }
      }
    }
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

  /// Full re-sync of the offline bootstrap snapshot (categories, products,
  /// variants, inventory, pickup locations, etc — one call refreshes all of
  /// it). Kept under both names since existing UI wires "Sync Categories"
  /// and "Sync Products" buttons to whichever one is in scope.
  Future<void> syncCategories() => _bootstrapController.syncBootstrap();

  Future<void> syncCategoryProducts() => _bootstrapController.syncBootstrap();

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

  /// Handles the "Scan Product" field — a barcode-gun input or manual
  /// search that resolves across categories, products, and variants, and
  /// adds straight to the cart when there's an unambiguous match.
  void submitScan() {
    final query = scanController.text.trim();
    if (query.isEmpty) return;
    final lower = query.toLowerCase();
    final allProducts = _bootstrapController.allProducts;

    // 1. Exact variant SKU/barcode match — most specific, adds directly.
    for (final product in allProducts) {
      final variant = product.variants.firstWhereOrNull(
        (v) => v.sku != null && v.sku!.toLowerCase() == lower,
      );
      if (variant != null) {
        _focusProductInCatalogue(product);
        addToCartFromProduct(product, variant: variant);
        scanController.clear();
        return;
      }
    }

    // 2. Exact product SKU match.
    final skuMatch = allProducts.firstWhereOrNull(
      (p) => p.sku != null && p.sku!.toLowerCase() == lower,
    );
    if (skuMatch != null) {
      _focusProductInCatalogue(skuMatch);
      onProductTap(skuMatch);
      scanController.clear();
      return;
    }

    // 3. Exact product name match.
    final nameMatches = allProducts
        .where((p) => p.displayName.toLowerCase() == lower)
        .toList();
    if (nameMatches.length == 1) {
      _focusProductInCatalogue(nameMatches.first);
      onProductTap(nameMatches.first);
      scanController.clear();
      return;
    }

    // 4. Exact category name match — jump straight into that category.
    final categoryMatch = categories.firstWhereOrNull(
      (c) => c.displayName.toLowerCase() == lower,
    );
    if (categoryMatch != null) {
      onCategoryTap(categoryMatch);
      scanController.clear();
      return;
    }

    // 5. Fallback: partial match across category/product/variant name & SKU
    // — shown as a filtered product list rather than guessed at.
    final matches = allProducts.where((p) {
      if (p.displayName.toLowerCase().contains(lower)) return true;
      if (p.sku != null && p.sku!.toLowerCase().contains(lower)) return true;
      final category = categories.firstWhereOrNull((c) => c.id == p.categoryId);
      if (category != null &&
          category.displayName.toLowerCase().contains(lower)) {
        return true;
      }
      return p.variants.any(
        (v) => v.sku != null && v.sku!.toLowerCase().contains(lower),
      );
    }).toList();

    if (matches.isEmpty) {
      customSnackBar(
        'Scan',
        'No product found for "$query"',
        snackBarType: SnackBarType.warning,
      );
      return;
    }

    if (matches.length == 1) {
      _focusProductInCatalogue(matches.first);
      onProductTap(matches.first);
      scanController.clear();
      return;
    }

    selectedCategory.value = null;
    selectedProduct.value = null;
    categoryProducts.assignAll(matches);
    productSearchController.text = query;
    productSearchQuery.value = query;
  }

  /// Puts [product]'s category in view (so the catalogue panel shows where
  /// it came from) before adding/selecting it.
  void _focusProductInCatalogue(ProductModel product) {
    final category = categories.firstWhereOrNull(
      (c) => c.id == product.categoryId,
    );
    selectedCategory.value = category;
    categoryProducts.assignAll(
      product.categoryId != null
          ? _bootstrapController.productsForCategory(product.categoryId!)
          : [product],
    );
    productSearchController.clear();
    productSearchQuery.value = '';
  }

  void onCategorySearchChanged(String val) => categorySearchQuery.value = val;

  void onProductSearchChanged(String val) => productSearchQuery.value = val;

  void onCategoryTap(CategoryModel category) {
    selectedCategory.value = category;
    selectedProduct.value = null;
    productSearchController.clear();
    productSearchQuery.value = '';
    categoryProducts.assignAll(
      category.id != null
          ? _bootstrapController.productsForCategory(category.id!)
          : const [],
    );
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
      imageUrl: variant?.imageUrl ?? product.primaryImageUrl,
      unitPrice: price,
      quantity: quantity,
      productId: product.id,
      variantId: variant?.id,
    );
  }

  /// Adds a cashier-created line without linking it to catalogue stock.
  void addCustomSale({
    required double price,
    required int quantity,
    String? title,
    required bool applyTax,
  }) {
    final customTitle = title?.trim();
    final name = (customTitle == null || customTitle.isEmpty)
        ? 'Custom Sale'
        : customTitle;

    cartItems.add(
      CartItemModel(
        product: CartProduct(
          name: name,
          skuCode: 'CUSTOM-${DateTime.now().microsecondsSinceEpoch}',
          imageUrl: null,
          amount: price,
          unitPrice: price,
          customText: (customTitle == null || customTitle.isEmpty)
              ? null
              : customTitle,
          isAppliedTax: applyTax,
          customPrice: price,
        ),
        quantity: quantity,
      ),
    );

    customSnackBar(
      'Added to Cart',
      '$name added successfully',
      snackBarType: SnackBarType.success,
    );
  }

  /// Current stock for a product/variant from the cached bootstrap
  /// catalogue (kept in sync with inventory adjustments), or null when it
  /// can't be resolved — treated as unlimited/untracked so it never blocks
  /// the add.
  int? _liveStock({int? productId, int? variantId}) {
    if (productId == null) return null;
    final product = _bootstrapController.allProducts.firstWhereOrNull(
      (p) => p.id == productId,
    );
    if (product == null) return null;
    if (variantId != null) {
      final variant = product.variants.firstWhereOrNull(
        (v) => v.id == variantId,
      );
      return variant?.stockQuantity;
    }
    return product.stock;
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
    final existingIndex = cartItems.indexWhere((c) => c.product.skuCode == sku);

    final stock = _liveStock(productId: productId, variantId: variantId);
    if (stock != null) {
      final alreadyInCart = existingIndex != -1
          ? cartItems[existingIndex].quantity
          : 0;
      if (stock <= 0) {
        customSnackBar(
          'Out of Stock',
          '$displayName is out of stock.',
          snackBarType: SnackBarType.error,
        );
        return;
      }
      if (alreadyInCart + quantity > stock) {
        customSnackBar(
          'Insufficient Stock',
          'Only $stock unit(s) of $displayName available.',
          snackBarType: SnackBarType.error,
        );
        return;
      }
    }

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
    final stock = _liveStock(
      productId: item.product.productId,
      variantId: item.product.variantId,
    );
    if (stock != null && item.quantity + 1 > stock) {
      customSnackBar(
        'Insufficient Stock',
        'Only $stock unit(s) of ${item.product.name} available.',
        snackBarType: SnackBarType.error,
      );
      return;
    }
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

  /// Sets the quantity directly (from the editable qty field) instead of
  /// stepping it one tap at a time.
  void setQty(CartItemModel item, int quantity) {
    if (quantity <= 0) {
      removeFromCart(item);
      return;
    }
    final stock = _liveStock(
      productId: item.product.productId,
      variantId: item.product.variantId,
    );
    if (stock != null && quantity > stock) {
      customSnackBar(
        'Insufficient Stock',
        'Only $stock unit(s) of ${item.product.name} available.',
        snackBarType: SnackBarType.error,
      );
      item.quantity = stock;
      cartItems.refresh();
      return;
    }
    item.quantity = quantity;
    cartItems.refresh();
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
        imageUrl: variant?.imageUrl ?? product.primaryImageUrl,
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
    cashReceivedInput.value = (current == '0' && digit != '.')
        ? digit
        : current + digit;
  }

  void keypadBackspace() {
    final current = cashReceivedInput.value;
    if (current.isEmpty) return;
    cashReceivedInput.value = current.substring(0, current.length - 1);
  }

  void keypadClear() => cashReceivedInput.value = '';

  void setExactCash() => cashReceivedInput.value = balance.toStringAsFixed(2);

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
            .map(
              (item) => {
                'name': item.product.name,
                'sku': item.product.skuCode,
                'quantity': item.quantity,
                'unit_price': item.product.unitPrice,
                'total': item.total,
              },
            )
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
