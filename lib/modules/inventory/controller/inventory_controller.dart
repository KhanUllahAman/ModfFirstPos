import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/bootstrap/controller/bootstrap_controller.dart';
import 'package:modfirstpos/modules/inventory/model/inventory_model.dart';
import 'package:modfirstpos/modules/inventory/service/inventory_service.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

enum InventoryAction { increase, decrease, adjust }

class InventoryController extends GetxController {
  final InventoryService _service = InventoryService();
  final BootstrapController _bootstrapController = Get.find<BootstrapController>();

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final Rxn<ProductModel> selectedProduct = Rxn<ProductModel>();
  final Rxn<ProductVariantModel> selectedVariant = Rxn<ProductVariantModel>();

  final Rx<InventoryAction> action = InventoryAction.increase.obs;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final Rx<InventoryReason> reason = InventoryReason.stockIn.obs;

  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Keeps an already-open product/variant panel live too — otherwise a
    // stock/price push patching the catalogue in the background wouldn't
    // show up here until the cashier re-taps the product.
    ever(_bootstrapController.data, (_) => _resyncSelection());
  }

  void _resyncSelection() {
    final productId = selectedProduct.value?.id;
    if (productId == null) return;
    final refreshed =
        _bootstrapController.allProducts.firstWhereOrNull((p) => p.id == productId);
    if (refreshed == null) return;
    selectedProduct.value = refreshed;
    final variantId = selectedVariant.value?.id;
    if (variantId != null) {
      selectedVariant.value =
          refreshed.variants.firstWhereOrNull((v) => v.id == variantId);
    }
  }

  List<ProductModel> get products {
    final query = searchQuery.value.trim().toLowerCase();
    final all = _bootstrapController.allProducts;
    if (query.isEmpty) return all;
    return all
        .where((p) =>
            p.displayName.toLowerCase().contains(query) ||
            (p.sku?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  /// Current stock for whatever is selected right now (variant if the
  /// product has variants, otherwise the product-level quantity).
  int? get currentStock {
    final product = selectedProduct.value;
    if (product == null) return null;
    if (product.hasVariants) return selectedVariant.value?.stockQuantity;
    return product.stock;
  }

  void onSearchChanged(String val) => searchQuery.value = val;

  void selectProduct(ProductModel product) {
    selectedProduct.value = product;
    selectedVariant.value = product.variants.isNotEmpty ? product.variants.first : null;
    quantityController.clear();
    notesController.clear();
  }

  void selectVariant(ProductVariantModel variant) {
    selectedVariant.value = variant;
  }

  void selectAction(InventoryAction newAction) {
    action.value = newAction;
    quantityController.clear();
  }

  String? validateQuantity(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Quantity is required';
    final qty = int.tryParse(text);
    if (qty == null || qty < 0) return 'Enter a valid quantity';
    if (action.value != InventoryAction.adjust && qty <= 0) {
      return 'Quantity must be greater than 0';
    }
    return null;
  }

  Future<bool> submit() async {
    final product = selectedProduct.value;
    if (product?.id == null) {
      customSnackBar('Inventory', 'Select a product first.', snackBarType: SnackBarType.warning);
      return false;
    }
    if (product!.hasVariants && selectedVariant.value == null) {
      customSnackBar('Inventory', 'Select a variant first.', snackBarType: SnackBarType.warning);
      return false;
    }
    final quantity = int.tryParse(quantityController.text.trim());
    if (quantity == null) {
      customSnackBar('Inventory', 'Enter a valid quantity.', snackBarType: SnackBarType.warning);
      return false;
    }

    final productId = product.id!;
    final variantId = selectedVariant.value?.id;
    final notes = notesController.text.trim();

    try {
      isSubmitting.value = true;
      InventoryResponse response;

      switch (action.value) {
        case InventoryAction.increase:
          response = await _service.increase(
            productId: productId,
            variantId: variantId,
            quantity: quantity,
            reason: reason.value,
            notes: notes,
          );
          break;
        case InventoryAction.decrease:
          response = await _service.decrease(
            productId: productId,
            variantId: variantId,
            quantity: quantity,
            reason: reason.value,
            notes: notes,
          );
          break;
        case InventoryAction.adjust:
          response = await _service.adjust(
            productId: productId,
            variantId: variantId,
            quantity: quantity,
            notes: notes,
          );
          break;
      }

      if (response.isSuccess && response.payload != null) {
        await _bootstrapController.patchInventory(
          productId: productId,
          variantId: variantId,
          newQuantity: response.payload!.quantity,
        );
        // Re-select the freshly patched product/variant so the UI reflects
        // the new stock immediately.
        final refreshedProduct = _bootstrapController.allProducts
            .firstWhereOrNull((p) => p.id == productId);
        if (refreshedProduct != null) {
          selectedProduct.value = refreshedProduct;
          if (variantId != null) {
            selectedVariant.value = refreshedProduct.variants
                .firstWhereOrNull((v) => v.id == variantId);
          }
        }
        quantityController.clear();
        notesController.clear();
        customSnackBar(
          'Inventory Updated',
          response.message.isNotEmpty
              ? response.message
              : 'Stock updated successfully.',
          snackBarType: SnackBarType.success,
        );
        return true;
      }

      customSnackBar(
        'Could Not Update Stock',
        response.message.isNotEmpty ? response.message : 'Something went wrong.',
        snackBarType: SnackBarType.error,
      );
      return false;
    } catch (e) {
      log("InventoryController submit error: $e");
      customSnackBar(
        'Could Not Update Stock',
        'Something went wrong. Please try again.',
        snackBarType: SnackBarType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    quantityController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
