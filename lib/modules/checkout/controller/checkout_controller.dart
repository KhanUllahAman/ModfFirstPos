import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:modfirstpos/core/database/key_value_store.dart';
import 'package:modfirstpos/core/services/local_receipt_builder.dart';
import 'package:modfirstpos/core/services/print_receipt_helper.dart';
import 'package:modfirstpos/core/services/sync_service.dart';
import 'package:modfirstpos/core/services/thermal_printer_service.dart';
import 'package:modfirstpos/core/utils/client_reference_generator.dart';
import 'package:modfirstpos/modules/bootstrap/controller/bootstrap_controller.dart';
import 'package:modfirstpos/modules/bootstrap/model/bootstrap_model.dart';
import 'package:modfirstpos/modules/checkout/service/checkout_service.dart';
import 'package:modfirstpos/modules/checkout/model/checkout_models.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/modules/order/repository/pending_order_repository.dart';
import 'package:modfirstpos/modules/setting/service/setting_service.dart';
import 'package:modfirstpos/modules/setting/storage/pos_device_cache_storage.dart';
import 'package:modfirstpos/modules/shift/controller/shift_controller.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

/// Payment methods that skip the online order-create + checkout APIs
/// entirely and go straight to the local offline queue (orders/pos/sync).
const _offlinePaymentMethods = {'cash', 'bank_transfer', 'without_payment'};

class CheckoutController extends GetxController {
  final CheckoutService _service = CheckoutService();
  final BootstrapController _bootstrapController = Get.find<BootstrapController>();
  final RxBool isLoading = false.obs;
  final RxBool isCouponLoading = false.obs;
  final RxString deliveryType = ''.obs;
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rxn<AddressModel> selectedAddress = Rxn<AddressModel>();
  final RxBool showNewAddressForm = false.obs;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController countryController = TextEditingController(text: 'United States');
  final RxList<PickupLocationModel> pickupLocations = <PickupLocationModel>[].obs;
  final Rxn<PickupLocationModel> selectedPickupLocation = Rxn<PickupLocationModel>();
  final TextEditingController couponController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final Rxn<CouponValidationResponse> couponValidation = Rxn<CouponValidationResponse>();
  final RxString couponError = ''.obs;
  final Rxn<CreatedOrder> createdOrder = Rxn<CreatedOrder>();
  final RxString paymentMethod = 'without_payment'.obs;
  final RxDouble customOnlineAmount = 0.0.obs;
  final RxDouble customCashAmount = 0.0.obs;

  // Resolved delivery details captured by createOrder(), reused by
  // submitCheckout() — for offline payment methods there's no server order
  // yet to carry these, so they're held here until final submit.
  List<Map<String, dynamic>> _pendingItemsPayload = [];
  int? _pendingAddressId;
  NewAddressInput? _pendingInlineAddress;
  int? _pendingPickupLocationId;

  /// Cash portion of a split payment, typed on the POS keypad (kept as a
  /// string for display control — no device keyboard involved).
  final RxString splitCashInput = ''.obs;

  double get splitCash => double.tryParse(splitCashInput.value) ?? 0.0;

  /// Online portion = remainder of the payable amount after cash.
  double get splitOnline {
    final remainder = payableAmount - splitCash;
    return remainder > 0 ? remainder : 0.0;
  }

  bool get isSplitPayment => paymentMethod.value.endsWith('_and_cash');

  void splitKeypadAppend(String digit) {
    final current = splitCashInput.value;
    if (digit == '.' && current.contains('.')) return;
    final dotIndex = current.indexOf('.');
    if (dotIndex != -1 && digit != '.' && current.length - dotIndex > 2) return;
    if (current.replaceAll('.', '').length >= 9) return;
    splitCashInput.value =
        (current == '0' && digit != '.') ? digit : current + digit;
  }

  void splitKeypadBackspace() {
    final current = splitCashInput.value;
    if (current.isEmpty) return;
    splitCashInput.value = current.substring(0, current.length - 1);
  }

  void splitKeypadClear() => splitCashInput.value = '';

  /// Dedicated controller for the checkout panel scrollbar (a Scrollbar
  /// without its own controller crashes on this multi-scrollable layout).
  late final ScrollController panelScrollController;

  static String _addressCacheKey(int userId) => 'cache_addresses_user_$userId';

  @override
  void onInit() {
    super.onInit();
    panelScrollController = ScrollController();
  }

  @override
  void onClose() {
    panelScrollController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    countryController.dispose();
    couponController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void resetCheckoutState() {
    deliveryType.value = '';
    addresses.clear();
    selectedAddress.value = null;
    showNewAddressForm.value = false;
    fullNameController.clear();
    phoneController.clear();
    emailController.clear();
    address1Controller.clear();
    address2Controller.clear();
    cityController.clear();
    stateController.clear();
    postalCodeController.clear();
    countryController.text = 'United States';
    pickupLocations.clear();
    selectedPickupLocation.value = null;
    couponController.clear();
    notesController.clear();
    couponValidation.value = null;
    couponError.value = '';
    createdOrder.value = null;
    paymentMethod.value = 'without_payment';
    customOnlineAmount.value = 0.0;
    customCashAmount.value = 0.0;
    splitCashInput.value = '';
  }

  Future<void> startCheckoutFlow(int userId) async {
    resetCheckoutState();
    isLoading.value = true;
    try {
      final homeController = Get.find<HomeController>();
      final customer = homeController.selectedCartCustomer.value;
      if (customer != null) {
        fullNameController.text = customer.fullName ?? '';
        emailController.text = customer.email ?? '';
        phoneController.text = customer.phone ?? '';
      }

      // Pickup locations are offline-first via the bootstrap snapshot —
      // instant, no network call.
      _applyPickupLocations(_bootstrapController.pickupLocations);

      // Addresses are per-customer and not part of bootstrap — hydrate from
      // the local cache first so the cashier never waits, then refresh from
      // the network in the background.
      final hadCache = await _hydrateAddressesFromCache(userId);
      if (hadCache) {
        isLoading.value = false;
        unawaited(loadAddresses(userId));
      } else {
        await loadAddresses(userId);
      }
    } catch (e) {
      log("CheckoutController startCheckoutFlow error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads cached addresses. Returns true when anything usable was found.
  Future<bool> _hydrateAddressesFromCache(int userId) async {
    try {
      final cachedAddresses =
          await KeyValueStore.getJsonCache(_addressCacheKey(userId));
      if (cachedAddresses != null) {
        _applyAddresses(AddressListResponse.fromJson(cachedAddresses).payload);
        return true;
      }
    } catch (e) {
      log("CheckoutController _hydrateAddressesFromCache error: $e");
    }
    return false;
  }

  void _applyAddresses(List<AddressModel> list) {
    addresses.assignAll(list);
    if (addresses.isNotEmpty) {
      final previous = selectedAddress.value?.id;
      selectedAddress.value = addresses.firstWhere(
        (a) => a.id == previous,
        orElse: () => addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        ),
      );
    } else {
      selectedAddress.value = null;
    }
  }

  void _applyPickupLocations(List<PickupLocationModel> list) {
    pickupLocations.assignAll(list);
    if (pickupLocations.isNotEmpty) {
      final previous = selectedPickupLocation.value?.id;
      selectedPickupLocation.value = pickupLocations.firstWhere(
        (l) => l.id == previous,
        orElse: () => pickupLocations.first,
      );
    } else {
      selectedPickupLocation.value = null;
    }
  }

  /// Force-refreshes addresses from the server, bypassing the local cache.
  Future<void> syncAddresses() async {
    final customer = Get.find<HomeController>().selectedCartCustomer.value;
    if (customer == null) return;
    isLoading.value = true;
    try {
      await loadAddresses(customer.id);
      customSnackBar(
        'Synced Successfully',
        'Fresh addresses loaded from server',
        snackBarType: SnackBarType.success,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Re-syncs the full offline bootstrap snapshot (pickup locations are
  /// part of it), then re-applies the refreshed list.
  Future<void> syncPickupLocations() async {
    isLoading.value = true;
    try {
      final success = await _bootstrapController.syncBootstrap();
      if (success) {
        _applyPickupLocations(_bootstrapController.pickupLocations);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAddresses(int userId) async {
    final response = await _service.fetchAddresses(userId: userId);
    if (response.isSuccess) {
      _applyAddresses(response.payload);
      await KeyValueStore.setJsonCache(_addressCacheKey(userId), {
        'success': true,
        'payload': response.payload
            .map((a) => {
                  'id': a.id,
                  'user_id': a.userId,
                  'full_name': a.fullName,
                  'phone': a.phone,
                  'email': a.email,
                  'address_line1': a.addressLine1,
                  'address_line2': a.addressLine2,
                  'city': a.city,
                  'state': a.state,
                  'postal_code': a.postalCode,
                  'country': a.country,
                  'is_default': a.isDefault,
                  'type': a.type,
                  'is_active': a.isActive,
                })
            .toList(),
      });
    } else if (addresses.isEmpty) {
      selectedAddress.value = null;
    }
  }

  Future<void> validateCoupon(double orderAmount) async {
    final code = couponController.text.trim();
    if (code.isEmpty) {
      couponError.value = 'Please enter a coupon code';
      return;
    }

    isCouponLoading.value = true;
    couponError.value = '';
    try {
      final response = await _service.validateCoupon(code: code, orderAmount: orderAmount);
      if (response.isSuccess) {
        couponValidation.value = response;
        customSnackBar(
          'Coupon Applied',
          'Coupon is valid! Discount of \$${response.discount.toStringAsFixed(2)} applied.',
          snackBarType: SnackBarType.success,
        );
      } else {
        couponValidation.value = null;
        couponError.value = response.message;
        customSnackBar(
          'Invalid Coupon',
          response.message,
          snackBarType: SnackBarType.error,
        );
      }
    } catch (e) {
      log("CheckoutController validateCoupon error: $e");
      couponError.value = 'Validation failed';
    } finally {
      isCouponLoading.value = false;
    }
  }

  void removeCoupon() {
    couponValidation.value = null;
    couponController.clear();
    couponError.value = '';
  }

  bool validateNewAddressForm() {
    if (fullNameController.text.trim().isEmpty) {
      customSnackBar('Validation Error', 'Full Name is required', snackBarType: SnackBarType.warning);
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      customSnackBar('Validation Error', 'Phone is required', snackBarType: SnackBarType.warning);
      return false;
    }
    if (address1Controller.text.trim().isEmpty) {
      customSnackBar('Validation Error', 'Address Line 1 is required', snackBarType: SnackBarType.warning);
      return false;
    }
    if (address1Controller.text.trim().length < 5) {
      customSnackBar(
        'Validation Error',
        'Address Line 1 must be at least 5 characters',
        snackBarType: SnackBarType.warning,
      );
      return false;
    }
    if (cityController.text.trim().isEmpty) {
      customSnackBar('Validation Error', 'City is required', snackBarType: SnackBarType.warning);
      return false;
    }
    return true;
  }

  /// Resolves delivery details + cart items and moves to the payment step.
  /// Entirely local/instant — no network call. The real online order (for
  /// Stripe/PayPal/split methods) or the offline queue entry (for
  /// cash/bank_transfer/without_payment) is only created at
  /// [submitCheckout] once the payment method is actually known.
  Future<bool> createOrder(HomeController homeController) async {
    final customer = homeController.selectedCartCustomer.value;
    if (customer == null) {
      customSnackBar('Error', 'No customer selected', snackBarType: SnackBarType.error);
      return false;
    }

    if (homeController.cartItems.isEmpty) {
      customSnackBar('Error', 'Cart is empty', snackBarType: SnackBarType.error);
      return false;
    }

    final itemsPayload = homeController.cartItems.map((item) {
      return {
        'product_id': item.product.productId ?? 0,
        if (item.product.variantId != null) 'variant_id': item.product.variantId,
        'quantity': item.quantity,
        'print_method': 'dtf',
        'custom_text': '',
        'design_upload_ids': <int>[]
      };
    }).toList();

    NewAddressInput? inlineAddress;
    int? addressId;

    if (deliveryType.value == 'home_delivery') {
      if (showNewAddressForm.value) {
        if (!validateNewAddressForm()) {
          return false;
        }
        inlineAddress = NewAddressInput(
          fullName: fullNameController.text.trim(),
          phone: phoneController.text.trim(),
          email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
          addressLine1: address1Controller.text.trim(),
          addressLine2: address2Controller.text.trim().isEmpty ? null : address2Controller.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim().isEmpty ? null : stateController.text.trim(),
          postalCode: postalCodeController.text.trim().isEmpty ? null : postalCodeController.text.trim(),
          country: countryController.text.trim().isEmpty ? 'United States' : countryController.text.trim(),
        );
      } else {
        if (selectedAddress.value == null) {
          customSnackBar('Address Required', 'Please select or add a shipping address.', snackBarType: SnackBarType.warning);
          return false;
        }
        addressId = selectedAddress.value!.id;
      }
    } else {
      if (selectedPickupLocation.value == null) {
        customSnackBar('Pickup Location Required', 'Please select a pickup location.', snackBarType: SnackBarType.warning);
        return false;
      }
      // Backend links shipping_address_id even for pickup orders; send the
      // customer's saved address when one exists to avoid FK errors.
      addressId = selectedAddress.value?.id;
    }

    _pendingItemsPayload = itemsPayload;
    _pendingAddressId = addressId;
    _pendingInlineAddress = inlineAddress;
    _pendingPickupLocationId = selectedPickupLocation.value?.id;

    // Local estimate for the payment-step preview — the real total (tax,
    // shipping) is only known once the real order is created online, or is
    // computed exactly the same way for the offline receipt at submit time.
    final subtotal = homeController.productTotal;
    final taxPercent =
        double.tryParse(_bootstrapController.data.value?.store.taxPercentage ?? '') ?? 0;
    final tax = subtotal * taxPercent / 100;
    createdOrder.value = CreatedOrder(
      id: 0,
      totalAmount: subtotal + tax,
      subtotal: subtotal,
      taxAmount: tax,
      shippingFee: 0,
      discountAmount: 0,
    );
    customOnlineAmount.value = createdOrder.value!.totalAmount;
    customCashAmount.value = 0.0;
    return true;
  }

  double get payableAmount {
    if (createdOrder.value == null) return 0.0;
    if (couponValidation.value != null) {
      return couponValidation.value!.finalAmount;
    }
    return createdOrder.value!.totalAmount;
  }

  double get couponDiscount {
    if (couponValidation.value != null) {
      return couponValidation.value!.discount;
    }
    return 0.0;
  }

  Future<void> submitCheckout(HomeController homeController) async {
    if (createdOrder.value == null) {
      customSnackBar('Error', 'Order not created yet', snackBarType: SnackBarType.error);
      return;
    }

    final method = paymentMethod.value;
    if (_offlinePaymentMethods.contains(method)) {
      await _submitOfflineSale(homeController, method);
    } else {
      await _submitOnlineCheckout(homeController, method);
    }
  }

  /// Cash / bank_transfer / without_payment — entirely local, no network
  /// call. Queued for `orders/pos/sync`, receipt printed immediately from
  /// local data.
  Future<void> _submitOfflineSale(
    HomeController homeController,
    String method,
  ) async {
    final customer = homeController.selectedCartCustomer.value;
    if (customer == null) return;

    isLoading.value = true;
    try {
      final clientReference = await ClientReferenceGenerator.generate('order');
      final shift = Get.isRegistered<ShiftController>()
          ? Get.find<ShiftController>().currentShift.value
          : null;

      final customerHasEmail =
          customer.email != null && customer.email!.isNotEmpty;

      final syncPayload = <String, dynamic>{
        // Prefer email/phone/full_name — the sync endpoint finds-or-creates
        // the customer from these, which self-heals if the cached customer
        // record is stale (e.g. synced before a backend reset). A locally
        // cached `user_id` can't be verified without a network round trip
        // (defeating the point of offline mode), so it's only sent as a
        // last resort when we have no contact info to identify them by.
        if (customerHasEmail) ...{
          'email': customer.email,
          if (customer.phone != null && customer.phone!.isNotEmpty)
            'phone': customer.phone,
          if (customer.fullName != null && customer.fullName!.isNotEmpty)
            'full_name': customer.fullName,
        } else if (customer.id > 0)
          'user_id': customer.id,
        'client_reference': clientReference,
        'offline_created_at': DateTime.now().toUtc().toIso8601String(),
        'payment_method': method,
        'delivery_type': deliveryType.value,
        if (deliveryType.value == 'store_pickup' && _pendingPickupLocationId != null)
          'pickup_location_id': _pendingPickupLocationId,
        if (deliveryType.value == 'home_delivery' && _pendingAddressId != null)
          'shipping_address_id': _pendingAddressId,
        if (deliveryType.value == 'home_delivery' && _pendingInlineAddress != null)
          'shipping_address': _pendingInlineAddress!.toJson(),
        'items': _pendingItemsPayload,
        if (shift != null && shift.id > 0) 'shift_id': shift.id,
        if (shift != null && shift.id <= 0)
          'shift_client_reference': shift.shiftCode.startsWith('PENDING-')
              ? shift.shiftCode.substring('PENDING-'.length)
              : null,
      };

      final grandTotal = payableAmount;
      final localPayload = <String, dynamic>{
        'grand_total': grandTotal,
        'subtotal': createdOrder.value!.subtotal,
        'tax': createdOrder.value!.taxAmount,
        'discount': couponDiscount,
        'customer_name': customer.fullName,
        'customer_phone': customer.phone,
        'customer_email': customer.email,
        'notes': notesController.text.trim(),
      };

      await PendingOrderRepository.add(
        clientReference: clientReference,
        shiftClientReference: syncPayload['shift_client_reference'] as String?,
        orderJson: {'sync': syncPayload, 'local': localPayload},
      );

      customSnackBar(
        'Sale Complete',
        'Order saved. It will sync automatically once online.',
        snackBarType: SnackBarType.success,
      );

      // Fire-and-forget: printing/sync must never block clearing the cart.
      final bootstrap = _bootstrapController.data.value;
      if (bootstrap != null) {
        unawaited(_printLocalReceipt(
          bootstrap: bootstrap,
          homeController: homeController,
          customer: customer,
          receiptId: clientReference,
          grandTotal: grandTotal,
        ));
      }
      if (Get.isRegistered<SyncService>()) {
        final sync = Get.find<SyncService>();
        await sync.refreshPendingCount();
        unawaited(sync.syncOrdersNow());
      }

      homeController.clearCart();
      homeController.showCheckoutPanel.value = false;
      resetCheckoutState();
    } catch (e) {
      log("CheckoutController _submitOfflineSale error: $e");
      customSnackBar('Error', 'Could not save the sale: $e', snackBarType: SnackBarType.error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _printLocalReceipt({
    required BootstrapPayload bootstrap,
    required HomeController homeController,
    required CustomerModel? customer,
    required String receiptId,
    required double grandTotal,
  }) async {
    try {
      final receipt = LocalReceiptBuilder.build(
        bootstrap: bootstrap,
        cartItems: homeController.cartItems,
        receiptId: receiptId,
        customer: customer,
        subtotal: createdOrder.value?.subtotal ?? 0,
        discount: couponDiscount,
        tax: createdOrder.value?.taxAmount ?? 0,
        grandTotal: grandTotal,
        deliveryInfo: deliveryType.value == 'store_pickup'
            ? selectedPickupLocation.value?.displayName
            : selectedAddress.value?.summaryLine,
        notes: notesController.text.trim(),
      );

      var device = await PosDeviceCacheStorage.getDevice();
      if (device == null) {
        final devicesResponse = await SettingService().getMyBranchDevices();
        if (devicesResponse.isSuccess && devicesResponse.payload.isNotEmpty) {
          device = devicesResponse.payload.first;
          await PosDeviceCacheStorage.saveDevice(device);
        }
      }
      if (device == null || device.ipAddress.trim().isEmpty) {
        customSnackBar(
          'Print Receipt',
          'No printer IP configured. Please set it up in Settings.',
          snackBarType: SnackBarType.warning,
        );
        return;
      }

      final printed = await ThermalPrinterService()
          .printReceipt(receipt, printerIp: device.ipAddress);
      if (!printed) {
        customSnackBar(
          'Print Receipt',
          'Could not reach the printer at ${device.ipAddress}.',
          snackBarType: SnackBarType.error,
        );
      }
    } catch (e) {
      log("CheckoutController _printLocalReceipt error: $e");
    }
  }

  /// Stripe / PayPal / split methods — real online order create + checkout,
  /// exactly as before (unchanged online flow).
  Future<void> _submitOnlineCheckout(
    HomeController homeController,
    String method,
  ) async {
    final customer = homeController.selectedCartCustomer.value;
    if (customer == null) return;

    isLoading.value = true;
    try {
      final notes = notesController.text.trim();
      final createResponse = await _service.createOrder(
        userId: customer.id,
        email: customer.email ?? '',
        phone: customer.phone ?? '',
        fullName: customer.fullName ?? 'Guest',
        deliveryType: deliveryType.value,
        shippingAddressId: _pendingAddressId,
        billingAddressId: _pendingAddressId,
        shippingAddress: _pendingInlineAddress,
        pickupLocationId: _pendingPickupLocationId,
        items: _pendingItemsPayload,
        notes: notes.isEmpty ? 'POS Checkout order' : notes,
      );

      if (!createResponse.isSuccess || createResponse.order == null) {
        customSnackBar('Order Creation Failed', createResponse.message, snackBarType: SnackBarType.error);
        return;
      }
      createdOrder.value = createResponse.order;

      final orderId = createdOrder.value!.id;
      double? online;
      double? cash;
      if (method == 'stripe_and_cash' || method == 'paypal_and_cash') {
        cash = splitCash;
        online = splitOnline;
        if (cash <= 0 || cash >= payableAmount) {
          customSnackBar(
            'Invalid Split Amount',
            'Cash must be more than 0 and less than the payable total '
            '(${payableAmount.toStringAsFixed(2)})',
            snackBarType: SnackBarType.warning,
          );
          return;
        }
      }

      final response = await _service.checkoutOrder(
        orderId: orderId,
        paymentMethod: method,
        onlineAmount: online,
        cashAmount: cash,
      );

      if (response.isSuccess) {
        customSnackBar(
          'Checkout Success',
          'Order checked out successfully.',
          snackBarType: SnackBarType.success,
        );
        if (response.sessionUrl != null && response.sessionUrl!.isNotEmpty) {
          final uri = Uri.tryParse(response.sessionUrl!);
          if (uri != null && await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            customSnackBar(
              'Checkout Redirect',
              'Please open this link to pay: ${response.sessionUrl}',
              durationSeconds: 10,
            );
          }
        }
        // Fire-and-forget: printing must never block clearing the cart.
        unawaited(PrintReceiptHelper.printOrderReceipt(orderId));
        homeController.clearCart();
        homeController.showCheckoutPanel.value = false;
        resetCheckoutState();
      } else {
        customSnackBar(
          'Checkout Error',
          response.message,
          snackBarType: SnackBarType.error,
        );
      }
    } catch (e) {
      log("CheckoutController _submitOnlineCheckout error: $e");
      customSnackBar('Error', 'An error occurred during checkout: $e', snackBarType: SnackBarType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
