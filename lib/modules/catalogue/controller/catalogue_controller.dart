// lib/modules/catalogue/controller/catalogue_controller.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/modules/category/service/category_service.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';


class CatalogueController extends GetxController {
  final CategoryService _service = CategoryService();

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadCategories({bool forceSync = false}) async {
    try {
      isLoading.value = true;
      final response = await _service.fetchCategories(
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
            'Fresh catalogue data loaded from server',
            snackBarType: SnackBarType.success,
          );
        }
      }
    } catch (e) {
      log("CatalogueController loadCategories error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncCategories() async {
    await loadCategories(forceSync: true);
  }


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