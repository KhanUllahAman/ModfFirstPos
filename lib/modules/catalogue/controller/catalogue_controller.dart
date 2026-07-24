// lib/modules/catalogue/controller/catalogue_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/bootstrap/controller/bootstrap_controller.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/routes/app_routes.dart';

class CatalogueController extends GetxController {
  final BootstrapController _bootstrapController = Get.find<BootstrapController>();

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _refreshFromBootstrap();
    ever(_bootstrapController.data, (_) => _refreshFromBootstrap());
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _refreshFromBootstrap() {
    categories.assignAll(_bootstrapController.categories);
  }

  /// Only true while a manual sync is in flight — normal loads are
  /// instant (read from the offline bootstrap cache), so this stays false
  /// on first load.
  RxBool get isLoading => _bootstrapController.isSyncing;

  Future<void> syncCategories() => _bootstrapController.syncBootstrap();

  List<CategoryModel> get filteredCategories {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return categories;
    return categories
        .where((c) => c.displayName.toLowerCase().contains(query))
        .toList();
  }

  void onSearch(String val) => searchQuery.value = val;

  void onCategoryTap(CategoryModel category) {
    Get.toNamed(Routes.categoryProducts, arguments: category);
  }
}
