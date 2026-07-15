import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/modules/product/service/product_service.dart';
import 'package:modfirstpos/routes/app_routes.dart';

import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class CategoryProductsController extends GetxController {
  final ProductService _service = ProductService();
  late final CategoryModel category;

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    category = Get.arguments as CategoryModel;
    fetchProducts();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchProducts({bool forceSync = false}) async {
    try {
      isLoading.value = true;
      final response = await _service.fetchProducts(
        page: 1,
        limit: 20,
        categoryId: category.id,
        status: 'published',
        isActive: true,
        forceSync: forceSync,
      );
      if (response.isSuccess) {
        products.assignAll(response.payload);
        if (forceSync) {
          customSnackBar(
            'Synced Successfully',
            'Fresh products for ${category.displayName} loaded from server',
            snackBarType: SnackBarType.success,
          );
        }
      }
    } catch (e) {
      log("CategoryProductsController fetch error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncProducts() async {
    await fetchProducts(forceSync: true);
  }


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