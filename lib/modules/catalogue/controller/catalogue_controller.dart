import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/bootstrap/controller/bootstrap_controller.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/routes/app_routes.dart';

class CatalogueController extends GetxController {
  final BootstrapController _bootstrapController =
      Get.find<BootstrapController>();

  // Two tabs
  final Rx<PosScreenTab> activeTab = PosScreenTab.categories.obs;

  // Search controllers
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final allProductsSearchController = TextEditingController();
  final RxString allProductsSearchQuery = ''.obs;

  final productSearchController = TextEditingController();
  final RxString productSearchQuery = ''.obs;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final Rxn<CategoryModel> selectedCategory = Rxn<CategoryModel>();
  final RxList<CategoryModel> categoryHierarchyStack = <CategoryModel>[].obs;
  final RxList<ProductModel> categoryProducts = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _refreshFromBootstrap();
    ever(_bootstrapController.data, (_) => _refreshFromBootstrap());
  }

  @override
  void onClose() {
    searchController.dispose();
    allProductsSearchController.dispose();
    productSearchController.dispose();
    super.onClose();
  }

  void switchTab(PosScreenTab tab) {
    activeTab.value = tab;
  }

  void _refreshFromBootstrap() {
    categories.assignAll(_bootstrapController.categories);
    _refreshCategoryProducts();
  }

  RxBool get isLoading => _bootstrapController.isSyncing;

  Future<void> syncCategories() => _bootstrapController.syncBootstrap();

  /// Top-level categories where parent_id == null or 0.
  List<CategoryModel> get topLevelCategories {
    return categories
        .where((c) => c.parentId == null || c.parentId == 0)
        .toList();
  }

  /// Direct child categories for [parentId].
  List<CategoryModel> childCategoriesFor(int parentId) {
    return categories.where((c) => c.parentId == parentId).toList();
  }

  /// Collects root ID and all descendant category IDs.
  Set<int> getDescendantCategoryIds(int rootCategoryId) {
    final ids = <int>{rootCategoryId};
    void collect(int parentId) {
      for (final cat in categories) {
        if (cat.parentId == parentId && cat.id != null) {
          if (ids.add(cat.id!)) {
            collect(cat.id!);
          }
        }
      }
    }
    collect(rootCategoryId);
    return ids;
  }

  /// Refreshes products for the currently selected category hierarchy, sorted by id ascending.
  void _refreshCategoryProducts() {
    final cat = selectedCategory.value;
    if (cat?.id == null) {
      categoryProducts.clear();
      return;
    }
    final descendantIds = getDescendantCategoryIds(cat!.id!);
    final all = _bootstrapController.allProducts;
    final matched = all
        .where((p) => p.categoryId != null && descendantIds.contains(p.categoryId))
        .toList();
    matched.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    categoryProducts.assignAll(matched);
  }

  /// Filtered categories for initial view.
  List<CategoryModel> get filteredCategories {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return topLevelCategories;
    return categories
        .where((c) => c.displayName.toLowerCase().contains(query))
        .toList();
  }

  /// Filtered products inside selected category, sorted by id ascending.
  List<ProductModel> get filteredProducts {
    final query = productSearchQuery.value.trim().toLowerCase();
    final list = (query.isEmpty
            ? categoryProducts
            : categoryProducts.where((p) =>
                p.displayName.toLowerCase().contains(query) ||
                (p.sku != null && p.sku!.toLowerCase().contains(query))))
        .toList();
    list.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    return list;
  }

  /// Filtered ALL products for Products tab, sorted by id ascending.
  List<ProductModel> get filteredAllProducts {
    final all = _bootstrapController.allProducts;
    final query = allProductsSearchQuery.value.trim().toLowerCase();
    final list = (query.isEmpty
            ? all
            : all.where((p) =>
                p.displayName.toLowerCase().contains(query) ||
                (p.sku != null && p.sku!.toLowerCase().contains(query))))
        .toList();
    list.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    return list;
  }

  void onSearch(String val) => searchQuery.value = val;

  void onAllProductsSearch(String val) => allProductsSearchQuery.value = val;

  void onProductSearch(String val) => productSearchQuery.value = val;

  void onCategoryTap(CategoryModel category) {
    if (!categoryHierarchyStack.contains(category)) {
      categoryHierarchyStack.add(category);
    }
    selectedCategory.value = category;
    productSearchController.clear();
    productSearchQuery.value = '';
    _refreshCategoryProducts();
  }

  void onCategoryBack() {
    if (categoryHierarchyStack.isNotEmpty) {
      categoryHierarchyStack.removeLast();
      selectedCategory.value = categoryHierarchyStack.isNotEmpty
          ? categoryHierarchyStack.last
          : null;
      productSearchController.clear();
      productSearchQuery.value = '';
      _refreshCategoryProducts();
    } else {
      selectedCategory.value = null;
      categoryProducts.clear();
    }
  }

  void onProductTap(ProductModel product) {
    if (product.hasVariants) {
      Get.toNamed(Routes.productVariant, arguments: product);
    } else {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().addToCartFromProduct(product);
      } else {
        Get.toNamed(Routes.productVariant, arguments: product);
      }
    }
  }
}
