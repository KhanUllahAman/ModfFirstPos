import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/bootstrap/controller/bootstrap_controller.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/routes/app_routes.dart';

class CategoryProductsController extends GetxController {
  final BootstrapController _bootstrapController = Get.find<BootstrapController>();
  late final CategoryModel category;

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    category = Get.arguments as CategoryModel;
    _refreshFromBootstrap();
    ever(_bootstrapController.data, (_) => _refreshFromBootstrap());
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _refreshFromBootstrap() {
    final categoryId = category.id;
    products.assignAll(
      categoryId != null
          ? _bootstrapController.productsForCategory(categoryId)
          : const [],
    );
  }

  /// Only true while a manual sync is in flight — normal loads are instant.
  RxBool get isLoading => _bootstrapController.isSyncing;

  Future<void> syncProducts() => _bootstrapController.syncBootstrap();

  void onSearchChanged(String val) => searchQuery.value = val;

  List<ProductModel> get filteredProducts {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return products;
    return products.where((p) => p.displayName.toLowerCase().contains(q)).toList();
  }

  void onProductTap(ProductModel product) {
    Get.toNamed(Routes.productVariant, arguments: product);
  }
}
