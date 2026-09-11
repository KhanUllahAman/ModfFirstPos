import 'dart:developer';
import 'package:get/get.dart';
import 'package:modfirstpos/core/storage/stripe_terminal_settings_storage.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/modules/bootstrap/model/bootstrap_model.dart';
import 'package:modfirstpos/modules/bootstrap/service/bootstrap_service.dart';
import 'package:modfirstpos/modules/bootstrap/storage/bootstrap_cache_storage.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/modules/checkout/model/checkout_models.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';
import 'package:modfirstpos/modules/setting/storage/pos_device_cache_storage.dart';
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

  List<ProductModel> get allProducts {
    final list = List<ProductModel>.from(data.value?.products ?? const []);
    list.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    return list;
  }

  List<ProductModel> productsForCategory(int categoryId) {
    final list = allProducts.where((p) => p.categoryId == categoryId).toList();
    list.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    return list;
  }

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
      await _autoSyncDeviceAndTerminal(payload);
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
        await _autoSyncDeviceAndTerminal(response.payload!);

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

  Future<void> _autoSyncDeviceAndTerminal(BootstrapPayload payload) async {
    try {
      if (payload.devices.isNotEmpty) {
        final device = payload.devices.first;
        final cached = await PosDeviceCacheStorage.getDevice();
        if (cached == null) {
          await PosDeviceCacheStorage.saveDevice(device);
        }
        await StripeTerminalSettingsStorage.saveReaderId(device.id.toString());
      }
      await StripeTerminalSettingsStorage.ensureDefaults();
    } catch (e) {
      log("BootstrapController _autoSyncDeviceAndTerminal error: $e");
    }
  }

  /// Decrements a product/variant's cached stock right after an offline
  /// sale, so a second offline sale on this same device (before the next
  /// sync) sees the reduced number instead of over-selling stock that's
  /// already spoken for. Clamped at 0 — never goes negative locally.
  Future<void> decrementStockLocally({
    required int productId,
    int? variantId,
    required int quantitySold,
  }) async {
    final product = allProducts.firstWhereOrNull((p) => p.id == productId);
    if (product == null) return;

    final currentStock = variantId != null
        ? product.variants.firstWhereOrNull((v) => v.id == variantId)?.stockQuantity
        : product.stock;
    if (currentStock == null) return;

    final newStock = currentStock - quantitySold;
    await patchInventory(
      productId: productId,
      variantId: variantId,
      newQuantity: newStock < 0 ? 0 : newStock,
    );
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
    // No cache yet on this device (e.g. adjusted before any bootstrap sync
    // ever completed) — pull a full snapshot instead of silently no-op'ing.
    if (raw == null) {
      await syncBootstrap(showSnackbar: false);
      return;
    }

    try {
      final products = raw['products'];
      if (products is! List) {
        await syncBootstrap(showSnackbar: false);
        return;
      }

      var matched = false;
      var productFound = false;

      for (final productJson in products) {
        if (productJson is! Map<String, dynamic>) continue;
        if (JsonUtils.asIntOrNull(productJson['id']) != productId) continue;
        productFound = true;

        // Product-level `stock` only applies to variant-less products.
        // `variantId` here is the stock push's `entity_id` — meaningful
        // only when the product actually has variants; for a variant-less
        // product it doesn't correspond to anything and is ignored.
        final variants = productJson['variants'];
        final hasVariants = variants is List && variants.isNotEmpty;

        if (!hasVariants) {
          productJson['stock'] = newQuantity;
          matched = true;
        } else if (variantId != null) {
          for (final variantJson in variants) {
            if (variantJson is! Map<String, dynamic>) continue;
            if (JsonUtils.asIntOrNull(variantJson['id']) != variantId) continue;
            variantJson['stock'] = newQuantity;
            final inventory = variantJson['inventory'];
            if (inventory is Map<String, dynamic>) {
              inventory['quantity'] = newQuantity;
            } else {
              variantJson['inventory'] = {'quantity': newQuantity};
            }
            matched = true;
          }
        } else if (variants.length == 1) {
          // No variant id given, but unambiguous — only one it could be.
          final variantJson = variants.first;
          if (variantJson is Map<String, dynamic>) {
            variantJson['stock'] = newQuantity;
            final inventory = variantJson['inventory'];
            if (inventory is Map<String, dynamic>) {
              inventory['quantity'] = newQuantity;
            } else {
              variantJson['inventory'] = {'quantity': newQuantity};
            }
            matched = true;
          }
        }
        // Genuinely ambiguous (no variant id, more than one variant) —
        // nothing safe to patch, and no API call either. Left stale until
        // the next manual/periodic sync.
        break;
      }

      if (!matched) {
        // Genuinely ambiguous (product has multiple variants and the push
        // didn't say which one) is left as-is, no API call. Only a truly
        // unknown product (not in the cached catalogue at all) falls back
        // to a full re-sync, so the local snapshot catches up instead of
        // quietly dropping a change for something it doesn't even know
        // about.
        if (!productFound) {
          await syncBootstrap(showSnackbar: false);
        }
        return;
      }

      data.value = BootstrapPayload.fromJson(raw);
      await BootstrapCacheStorage.saveBootstrap(raw);
    } catch (e) {
      log("BootstrapController patchInventory error: $e");
      await syncBootstrap(showSnackbar: false);
    }
  }

  /// Patches a product's base price in place from a `product.price_increased`
  /// / `product.price_decreased` push notification — no API call, the
  /// notification payload already carries the new price.
  Future<void> patchProductPrice({
    required int productId,
    required double newPrice,
  }) async {
    final raw = _rawPayload;
    if (raw == null) return;
    try {
      final products = raw['products'];
      if (products is! List) return;

      for (final productJson in products) {
        if (productJson is! Map<String, dynamic>) continue;
        if (JsonUtils.asIntOrNull(productJson['id']) != productId) continue;
        productJson['base_price'] = newPrice;
        data.value = BootstrapPayload.fromJson(raw);
        await BootstrapCacheStorage.saveBootstrap(raw);
        return;
      }
    } catch (e) {
      log("BootstrapController patchProductPrice error: $e");
    }
  }

  /// Same as [patchProductPrice] but for a variant — the push doesn't give
  /// us `product_id` for variant events, so this searches every product's
  /// variant list for a matching variant id.
  Future<void> patchVariantPrice({
    required int variantId,
    required double newPrice,
  }) async {
    final raw = _rawPayload;
    if (raw == null) return;
    try {
      final products = raw['products'];
      if (products is! List) return;

      for (final productJson in products) {
        if (productJson is! Map<String, dynamic>) continue;
        final variants = productJson['variants'];
        if (variants is! List) continue;
        for (final variantJson in variants) {
          if (variantJson is! Map<String, dynamic>) continue;
          if (JsonUtils.asIntOrNull(variantJson['id']) != variantId) continue;
          variantJson['price'] = newPrice;
          data.value = BootstrapPayload.fromJson(raw);
          await BootstrapCacheStorage.saveBootstrap(raw);
          return;
        }
      }
    } catch (e) {
      log("BootstrapController patchVariantPrice error: $e");
    }
  }

  /// Removes a product from the cached catalogue in place — used for
  /// `product.deleted` pushes, which carry no data beyond the id.
  Future<void> removeProductLocally(int productId) async {
    final raw = _rawPayload;
    if (raw == null) return;
    try {
      final products = raw['products'];
      if (products is! List) return;
      final removed = products.any(
        (p) => p is Map<String, dynamic> && JsonUtils.asIntOrNull(p['id']) == productId,
      );
      if (!removed) return;
      products.removeWhere(
        (p) => p is Map<String, dynamic> && JsonUtils.asIntOrNull(p['id']) == productId,
      );
      data.value = BootstrapPayload.fromJson(raw);
      await BootstrapCacheStorage.saveBootstrap(raw);
    } catch (e) {
      log("BootstrapController removeProductLocally error: $e");
    }
  }

  /// Removes a variant from its parent product's cached variant list — used
  /// for `variant.deleted` pushes (no `product_id` in the payload, so every
  /// product's variants are searched).
  Future<void> removeVariantLocally(int variantId) async {
    final raw = _rawPayload;
    if (raw == null) return;
    try {
      final products = raw['products'];
      if (products is! List) return;
      for (final productJson in products) {
        if (productJson is! Map<String, dynamic>) continue;
        final variants = productJson['variants'];
        if (variants is! List) continue;
        final removed = variants.any(
          (v) => v is Map<String, dynamic> && JsonUtils.asIntOrNull(v['id']) == variantId,
        );
        if (!removed) continue;
        variants.removeWhere(
          (v) => v is Map<String, dynamic> && JsonUtils.asIntOrNull(v['id']) == variantId,
        );
        data.value = BootstrapPayload.fromJson(raw);
        await BootstrapCacheStorage.saveBootstrap(raw);
        return;
      }
    } catch (e) {
      log("BootstrapController removeVariantLocally error: $e");
    }
  }
}
