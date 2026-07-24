import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/modules/bootstrap/model/bootstrap_model.dart';
import 'package:modfirstpos/modules/bootstrap/service/bootstrap_service.dart';
import 'package:modfirstpos/modules/bootstrap/storage/bootstrap_cache_storage.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/modules/checkout/model/checkout_models.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

/// Single offline-first source of truth for reference data synced via
/// pos/bootstrap (categories, products+variants+inventory, pickup locations,
/// coupons, devices, branch/store info) while a shift is open.
class BootstrapController extends GetxController {
  final BootstrapService _service = BootstrapService();

  final Rxn<BootstrapPayload> data = Rxn<BootstrapPayload>();
  final Rx<DateTime?> syncedAt = Rx<DateTime?>(null);
  final RxBool isSyncing = false.obs;

  /// The raw JSON of the last-synced payload, kept around so a local
  /// inventory adjustment can patch it in place and re-cache it without a
  /// full server round trip.
  Map<String, dynamic>? _rawPayload;

  List<CategoryModel> get categories => data.value?.categories ?? const [];

  List<ProductModel> get allProducts => data.value?.products ?? const [];

  List<ProductModel> productsForCategory(int categoryId) =>
      allProducts.where((p) => p.categoryId == categoryId).toList();

  List<PickupLocationModel> get pickupLocations =>
      data.value?.pickupLocations ?? const [];

  List<BootstrapCouponModel> get coupons => data.value?.coupons ?? const [];

  CustomerModel? get walkInCustomer => data.value?.walkInCustomer;

  /// Instant, offline-first load from the local cache — no network call.
  /// Safe to call at app startup even if no shift has been opened yet in
  /// this session (e.g. resuming after the app was killed mid-shift).
  Future<void> hydrateFromCache() async {
    try {
      final cached = await BootstrapCacheStorage.getBootstrap();
      if (cached == null) return;
      _rawPayload = cached;
      final payload = BootstrapPayload.fromJson(cached);
      data.value = payload;
      syncedAt.value = _parseSyncedAt(payload.syncedAt);
    } catch (e) {
      log("BootstrapController hydrateFromCache error: $e");
    }
  }

  Future<bool> syncBootstrap({bool showSnackbar = true}) async {
    try {
      isSyncing.value = true;
      final (response, rawPayload) = await _service.fetchBootstrap();

      if (response.isSuccess && response.payload != null && rawPayload != null) {
        _rawPayload = rawPayload;
        data.value = response.payload;
        syncedAt.value = _parseSyncedAt(response.payload!.syncedAt);
        await BootstrapCacheStorage.saveBootstrap(rawPayload);

        if (showSnackbar) {
          customSnackBar(
            'Synced Successfully',
            'Store data refreshed from server.',
            snackBarType: SnackBarType.success,
          );
        }
        return true;
      }

      if (showSnackbar) {
        customSnackBar(
          'Sync Failed',
          response.message.isNotEmpty
              ? response.message
              : 'Could not refresh store data.',
          snackBarType: SnackBarType.error,
        );
      }
      return false;
    } catch (e) {
      log("BootstrapController syncBootstrap error: $e");
      if (showSnackbar) {
        customSnackBar(
          'Sync Failed',
          'Something went wrong while syncing store data.',
          snackBarType: SnackBarType.error,
        );
      }
      return false;
    } finally {
      isSyncing.value = false;
    }
  }

  DateTime? _parseSyncedAt(String? value) {
    if (value == null) return null;
    return DateTime.tryParse(value)?.toLocal();
  }

  /// Patches a product/variant's cached stock quantity in place after a
  /// successful online inventory increase/decrease/adjust call, so the UI
  /// reflects the new stock immediately without a full re-sync.
  Future<void> patchInventory({
    required int productId,
    int? variantId,
    required int newQuantity,
  }) async {
    final raw = _rawPayload;
    if (raw == null) return;

    try {
      final products = raw['products'];
      if (products is! List) return;

      for (final productJson in products) {
        if (productJson is! Map<String, dynamic>) continue;
        if (JsonUtils.asIntOrNull(productJson['id']) != productId) continue;

        if (variantId == null) {
          productJson['stock'] = newQuantity;
        } else {
          final variants = productJson['variants'];
          if (variants is List) {
            for (final variantJson in variants) {
              if (variantJson is! Map<String, dynamic>) continue;
              if (JsonUtils.asIntOrNull(variantJson['id']) != variantId) {
                continue;
              }
              variantJson['stock'] = newQuantity;
              final inventory = variantJson['inventory'];
              if (inventory is Map<String, dynamic>) {
                inventory['quantity'] = newQuantity;
              } else {
                variantJson['inventory'] = {'quantity': newQuantity};
              }
            }
          }
        }
        break;
      }

      data.value = BootstrapPayload.fromJson(raw);
      await BootstrapCacheStorage.saveBootstrap(raw);
    } catch (e) {
      log("BootstrapController patchInventory error: $e");
    }
  }
}
