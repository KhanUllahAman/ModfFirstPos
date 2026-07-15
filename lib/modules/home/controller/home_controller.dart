import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/modules/category/service/category_service.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/modules/product/service/product_service.dart';
import 'package:modfirstpos/modules/home/model/cart_item_model.dart';
import 'package:modfirstpos/modules/home/model/product_item.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class HomeController extends GetxController {
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();

  final TextEditingController scanController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController productSearchController = TextEditingController();

  late ScrollController cartScrollController;
  late ScrollController productScrollController;

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
    loadCategories();
  }

  @override
  void onClose() {
    scanController.dispose();
    searchController.dispose();
    productSearchController.dispose();
    cartScrollController.dispose();
    productScrollController.dispose();
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
    final existingIndex = cartItems.indexWhere(
      (c) => c.product.skuCode == product.skuCode,
    );

    if (existingIndex != -1) {
      cartItems[existingIndex].quantity += quantity;
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
        quantity: quantity,
      ),
    );

    customSnackBar(
      'Added to Cart',
      '${product.displayName} added successfully',
      snackBarType: SnackBarType.success,
    );
  }

  void addToCartFromProduct(ProductModel product, {ProductVariantModel? variant, int quantity = 1}) {
    final sku = variant != null ? (variant.sku ?? product.sku ?? '--') : (product.sku ?? '--');
    final price = variant != null ? variant.effectivePrice : product.effectivePrice;
    final displayName = variant != null ? '${product.displayName} (${variant.sku})' : product.displayName;

    final existingIndex = cartItems.indexWhere(
      (c) => c.product.skuCode == sku,
    );

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
          name: displayName,
          skuCode: sku,
          imageUrl: product.primaryImageUrl,
          amount: price,
          unitPrice: price,
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
