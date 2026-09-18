import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/database/key_value_store.dart';
import 'package:modfirstpos/core/services/local_receipt_builder.dart';
import 'package:modfirstpos/core/services/print_receipt_helper.dart';
import 'package:modfirstpos/core/services/sync_service.dart';
import 'package:modfirstpos/core/services/thermal_printer_service.dart';
import 'package:modfirstpos/core/services/website_settings_storage_service.dart';
import 'package:modfirstpos/core/storage/stripe_terminal_settings_storage.dart';
import 'package:modfirstpos/core/utils/client_reference_generator.dart';
import 'package:modfirstpos/core/utils/currency_utils.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
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

const _offlinePaymentMethods = {'cash', 'bank_transfer', 'without_payment'};

class CheckoutController extends GetxController {
  final CheckoutService _service = CheckoutService();
  final BootstrapController _bootstrapController =
      Get.find<BootstrapController>();
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
  final TextEditingController countryController = TextEditingController(
    text: 'United States',
  );
  final RxList<PickupLocationModel> pickupLocations =
      <PickupLocationModel>[].obs;
  final Rxn<PickupLocationModel> selectedPickupLocation =
      Rxn<PickupLocationModel>();
  final TextEditingController couponController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final Rxn<CouponValidationResponse> couponValidation =
      Rxn<CouponValidationResponse>();
  final RxString couponError = ''.obs;
  final Rxn<CreatedOrder> createdOrder = Rxn<CreatedOrder>();
  final RxString paymentMethod = 'cash'.obs;
  final RxDouble customOnlineAmount = 0.0.obs;
  final RxDouble customCashAmount = 0.0.obs;
  final Rxn<Map<String, dynamic>> manualDiscount = Rxn<Map<String, dynamic>>();
  final RxString terminalStatusMessage = ''.obs;
  bool _isTerminalCancelled = false;
  int? _activeTerminalReaderId;
  List<Map<String, dynamic>> _pendingItemsPayload = [];
  int? _pendingAddressId;
  NewAddressInput? _pendingInlineAddress;
  int? _pendingPickupLocationId;
  final RxString splitCashInput = ''.obs;
  final RxString splitTenderedInput = ''.obs;
  final RxString splitActiveField = 'portion'.obs;
  final RxString cashTenderedInput = ''.obs;

  double get splitCash => double.tryParse(splitCashInput.value) ?? 0.0;

  double get splitOnline {
    final remainder = payableAmount - splitCash;
    return remainder > 0 ? remainder : 0.0;
  }

  double get splitCashCollect {
    if (splitTenderedInput.value.isEmpty) {
      return splitCash;
    }
    return double.tryParse(splitTenderedInput.value) ?? splitCash;
  }

  double get splitCashReturn {
    if (splitTenderedInput.value.isEmpty) {
      return 0.0;
    }
    final collect = double.tryParse(splitTenderedInput.value) ?? 0.0;
    final diff = collect - splitCash;
    return diff > 0 ? double.parse(diff.toStringAsFixed(2)) : 0.0;
  }

  double get splitCashShortage {
    if (splitTenderedInput.value.isEmpty) {
      return 0.0;
    }
    final collect = double.tryParse(splitTenderedInput.value) ?? 0.0;
    final diff = splitCash - collect;
    return diff > 0 ? double.parse(diff.toStringAsFixed(2)) : 0.0;
  }

  void setSplitActiveField(String field) {
    splitActiveField.value = field;
  }

  void setSplitTenderedExact() {
    splitTenderedInput.value = splitCash.toStringAsFixed(2);
  }

  bool get isSplitPayment =>
      paymentMethod.value == 'cash_bank_transfer' ||
      paymentMethod.value == 'cash_stripe_terminal';

  bool get isCashPayment => paymentMethod.value == 'cash';

  bool get isTerminalPayment =>
      paymentMethod.value == 'stripe_terminal' ||
      paymentMethod.value == 'cash_stripe_terminal';

  double get cashCollect {
    if (cashTenderedInput.value.isEmpty) {
      return payableAmount;
    }
    return double.tryParse(cashTenderedInput.value) ?? payableAmount;
  }

  double get cashReturn {
    if (cashTenderedInput.value.isEmpty) {
      return 0.0;
    }
    final collect = double.tryParse(cashTenderedInput.value) ?? 0.0;
    final diff = collect - payableAmount;
    return diff > 0 ? double.parse(diff.toStringAsFixed(2)) : 0.0;
  }

  double get cashShortage {
    if (cashTenderedInput.value.isEmpty) {
      return 0.0;
    }
    final collect = double.tryParse(cashTenderedInput.value) ?? 0.0;
    final diff = payableAmount - collect;
    return diff > 0 ? double.parse(diff.toStringAsFixed(2)) : 0.0;
  }

  void cashKeypadAppend(String digit) {
    final current = cashTenderedInput.value;
    if (digit == '.' && current.contains('.')) return;
    final dotIndex = current.indexOf('.');
    if (dotIndex != -1 && digit != '.' && current.length - dotIndex > 2) return;
    if (current.replaceAll('.', '').length >= 9) return;
    cashTenderedInput.value =
        (current == '0' && digit != '.') ? digit : current + digit;
  }

  void cashKeypadBackspace() {
    final current = cashTenderedInput.value;
    if (current.isEmpty) return;
    cashTenderedInput.value = current.substring(0, current.length - 1);
  }

  void cashKeypadClear() => cashTenderedInput.value = '';

  void setCashExact() {
    cashTenderedInput.value = payableAmount.toStringAsFixed(2);
  }

  void addCashPreset(double amount) {
    final current = double.tryParse(cashTenderedInput.value) ?? 0.0;
    cashTenderedInput.value = (current + amount).toStringAsFixed(2);
  }

  void splitKeypadAppend(String digit) {
    final isTendered = splitActiveField.value == 'tendered';
    final current = isTendered ? splitTenderedInput.value : splitCashInput.value;

    if (digit == '.' && current.contains('.')) return;
    final dotIndex = current.indexOf('.');
    if (dotIndex != -1 && digit != '.' && current.length - dotIndex > 2) return;
    if (current.replaceAll('.', '').length >= 9) return;
    final nextVal = (current == '0' && digit != '.') ? digit : current + digit;

    if (isTendered) {
      splitTenderedInput.value = nextVal;
    } else {
      splitCashInput.value = nextVal;
    }
  }

  void splitKeypadBackspace() {
    final isTendered = splitActiveField.value == 'tendered';
    final current = isTendered ? splitTenderedInput.value : splitCashInput.value;
    if (current.isEmpty) return;
    final nextVal = current.substring(0, current.length - 1);
    if (isTendered) {
      splitTenderedInput.value = nextVal;
    } else {
      splitCashInput.value = nextVal;
    }
  }

  void splitKeypadClear() {
    if (splitActiveField.value == 'tendered') {
      splitTenderedInput.value = '';
    } else {
      splitCashInput.value = '';
      splitTenderedInput.value = '';
    }
  }

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
    paymentMethod.value = 'cash';
    customOnlineAmount.value = 0.0;
    customCashAmount.value = 0.0;
    splitCashInput.value = '';
    splitTenderedInput.value = '';
    splitActiveField.value = 'portion';
    cashTenderedInput.value = '';
    manualDiscount.value = null;
  }

  void applyManualDiscount({
    required String type,
    required double value,
    String? reason,
  }) {
    manualDiscount.value = {
      'type': type,
      'value': value,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    };
  }

  void removeManualDiscount() => manualDiscount.value = null;

  double get manualDiscountAmount {
    final discount = manualDiscount.value;
    if (discount == null || createdOrder.value == null) return 0.0;
    final value = JsonUtils.asDouble(discount['value']);
    if (discount['type'] == 'percentage') {
      return createdOrder.value!.subtotal * value / 100;
    }
    return value;
  }

  /// Automatic wholesale discount from the selected customer's discount
  /// tier (`account_type: wholesale`) — applied the same way for every
  /// payment method, since it comes from the customer's own record, not a
  /// manual entry. Backend applies this itself for online orders; this is
  /// only a local estimate so the checkout preview matches, and it's the
  /// real calculation used for offline orders (no server involved there).
  double get customerTierDiscountAmount {
    if (createdOrder.value == null) return 0.0;
    final tier = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>().selectedCartCustomer.value?.discountTier
        : null;
    if (tier == null) return 0.0;
    final value = JsonUtils.asDouble(tier.discountValue);
    if (tier.discountType == 'percentage') {
      return createdOrder.value!.subtotal * value / 100;
    }
    return value;
  }

  double get totalDiscount =>
      couponDiscount + manualDiscountAmount + customerTierDiscountAmount;

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
      _applyPickupLocations(_bootstrapController.pickupLocations);
      if (homeController.activeDraftOrder.value != null) {
        final draft = homeController.activeDraftOrder.value!;
        if (draft.deliveryType.isNotEmpty) {
          deliveryType.value = draft.deliveryType;
        }
      }
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

  Future<bool> _hydrateAddressesFromCache(int userId) async {
    try {
      final cachedAddresses = await KeyValueStore.getJsonCache(
        _addressCacheKey(userId),
      );
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
            .map(
              (a) => {
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
              },
            )
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
      final response = await _service.validateCoupon(
        code: code,
        orderAmount: orderAmount,
      );
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
      customSnackBar(
        'Validation Error',
        'Full Name is required',
        snackBarType: SnackBarType.warning,
      );
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      customSnackBar(
        'Validation Error',
        'Phone is required',
        snackBarType: SnackBarType.warning,
      );
      return false;
    }
    if (address1Controller.text.trim().isEmpty) {
      customSnackBar(
        'Validation Error',
        'Address Line 1 is required',
        snackBarType: SnackBarType.warning,
      );
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
      customSnackBar(
        'Validation Error',
        'City is required',
        snackBarType: SnackBarType.warning,
      );
      return false;
    }
    return true;
  }

  Future<bool> createOrder(HomeController homeController) async {
    final customer = homeController.selectedCartCustomer.value;
    if (customer == null) {
      customSnackBar(
        'Error',
        'No customer selected',
        snackBarType: SnackBarType.error,
      );
      return false;
    }

    if (homeController.cartItems.isEmpty) {
      customSnackBar(
        'Error',
        'Cart is empty',
        snackBarType: SnackBarType.error,
      );
      return false;
    }

    final itemsPayload = homeController.cartItems.map((item) {
      return {
        'product_id': item.product.productId ?? 0,
        if (item.product.variantId != null)
          'variant_id': item.product.variantId,
        'quantity': item.quantity,
        'print_method': 'dtf',
        // These values are sent only for a cashier-created custom sale.
        if (item.product.customText != null)
          'custom_text': item.product.customText,
        if (item.product.isAppliedTax != null)
          'is_applied_tax': item.product.isAppliedTax,
        // The backend contract uses this spelling intentionally.
        if (item.product.customPrice != null)
          'cutome_price': item.product.customPrice,
        'design_upload_ids': <int>[],
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
          email: emailController.text.trim().isEmpty
              ? null
              : emailController.text.trim(),
          addressLine1: address1Controller.text.trim(),
          addressLine2: address2Controller.text.trim().isEmpty
              ? null
              : address2Controller.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim().isEmpty
              ? null
              : stateController.text.trim(),
          postalCode: postalCodeController.text.trim().isEmpty
              ? null
              : postalCodeController.text.trim(),
          country: countryController.text.trim().isEmpty
              ? 'United States'
              : countryController.text.trim(),
        );
      } else {
        if (selectedAddress.value == null) {
          customSnackBar(
            'Address Required',
            'Please select or add a shipping address.',
            snackBarType: SnackBarType.warning,
          );
          return false;
        }
        addressId = selectedAddress.value!.id;
      }
    } else {
      if (selectedPickupLocation.value == null) {
        customSnackBar(
          'Pickup Location Required',
          'Please select a pickup location.',
          snackBarType: SnackBarType.warning,
        );
        return false;
      }
      addressId = selectedAddress.value?.id;
    }

    _pendingItemsPayload = itemsPayload;
    _pendingAddressId = addressId;
    _pendingInlineAddress = inlineAddress;
    _pendingPickupLocationId = selectedPickupLocation.value?.id;
    final subtotal = homeController.productTotal;
    final taxPercent =
        double.tryParse(
          _bootstrapController.data.value?.store.taxPercentage ?? '',
        ) ??
        0;
    final taxableSubtotal = homeController.cartItems
        .where((item) => item.product.isAppliedTax != false)
        .fold<double>(0, (sum, item) => sum + item.total);
    final tax = taxableSubtotal * taxPercent / 100;
    final shipping = await calculateShippingFee(
      homeController: homeController,
      subtotal: subtotal,
    );

    createdOrder.value = CreatedOrder(
      id: 0,
      totalAmount: subtotal + tax + shipping,
      subtotal: subtotal,
      taxAmount: tax,
      shippingFee: shipping,
      discountAmount: 0,
    );
    if (customCashAmount.value == 0.0 || customOnlineAmount.value > 0) {
      customOnlineAmount.value = payableAmount;
    }
    return true;
  }

  Future<double> calculateShippingFee({
    required HomeController homeController,
    required double subtotal,
  }) async {
    // 1. If active draft order has an explicit shipping fee, use it
    final draftFee = homeController.activeDraftOrder.value?.shippingFee;
    if (draftFee != null && draftFee > 0) {
      return draftFee;
    }

    // 2. Store pickup has no shipping fee
    if (deliveryType.value == 'store_pickup') {
      return 0.0;
    }

    // 3. For home delivery (or unspecified):
    String? defaultFeeStr =
        _bootstrapController.data.value?.store.defaultShippingFee;
    if (defaultFeeStr == null || defaultFeeStr.trim().isEmpty) {
      defaultFeeStr =
          await WebsiteSettingsStorageService.getDefaultShippingFee();
    }

    String? freeThresholdStr =
        _bootstrapController.data.value?.store.freeShippingThreshold;
    if (freeThresholdStr == null || freeThresholdStr.trim().isEmpty) {
      freeThresholdStr =
          await WebsiteSettingsStorageService.getFreeShippingThreshold();
    }

    final defaultFee = double.tryParse(defaultFeeStr ?? '') ?? 0.0;
    final freeThreshold = double.tryParse(freeThresholdStr ?? '');

    if (freeThreshold != null &&
        freeThreshold > 0 &&
        subtotal >= freeThreshold) {
      return 0.0;
    }

    return defaultFee;
  }

  void syncCartWithCreatedOrder(HomeController homeController) {
    if (createdOrder.value == null) return;
    if (homeController.cartItems.isEmpty) {
      createdOrder.value = null;
      homeController.showCheckoutPanel.value = false;
      return;
    }

    _pendingItemsPayload = homeController.cartItems.map((item) {
      return {
        'product_id': item.product.productId ?? 0,
        if (item.product.variantId != null)
          'variant_id': item.product.variantId,
        'quantity': item.quantity,
        'print_method': 'dtf',
        if (item.product.customText != null)
          'custom_text': item.product.customText,
        if (item.product.isAppliedTax != null)
          'is_applied_tax': item.product.isAppliedTax,
        if (item.product.customPrice != null)
          'cutome_price': item.product.customPrice,
        'design_upload_ids': <int>[],
      };
    }).toList();

    final subtotal = homeController.productTotal;
    final taxPercent =
        double.tryParse(
          _bootstrapController.data.value?.store.taxPercentage ?? '',
        ) ??
        0;
    final taxableSubtotal = homeController.cartItems
        .where((item) => item.product.isAppliedTax != false)
        .fold<double>(0, (sum, item) => sum + item.total);
    final tax = taxableSubtotal * taxPercent / 100;

    double shipping = createdOrder.value?.shippingFee ?? 0.0;
    if (homeController.activeDraftOrder.value?.shippingFee != null &&
        homeController.activeDraftOrder.value!.shippingFee > 0) {
      shipping = homeController.activeDraftOrder.value!.shippingFee;
    } else if (deliveryType.value == 'home_delivery') {
      final defaultFeeStr =
          _bootstrapController.data.value?.store.defaultShippingFee;
      final freeThresholdStr =
          _bootstrapController.data.value?.store.freeShippingThreshold;
      final defaultFee = double.tryParse(defaultFeeStr ?? '') ??
          (createdOrder.value?.shippingFee ?? 0.0);
      final freeThreshold = double.tryParse(freeThresholdStr ?? '');
      if (freeThreshold != null &&
          freeThreshold > 0 &&
          subtotal >= freeThreshold) {
        shipping = 0.0;
      } else {
        shipping = defaultFee;
      }
    } else if (deliveryType.value == 'store_pickup') {
      shipping = 0.0;
    }

    final discount = createdOrder.value?.discountAmount ?? 0.0;

    createdOrder.value = CreatedOrder(
      id: createdOrder.value?.id ?? 0,
      orderNumber: createdOrder.value?.orderNumber,
      orderCode: createdOrder.value?.orderCode,
      totalAmount: subtotal + tax + shipping - discount,
      subtotal: subtotal,
      taxAmount: tax,
      shippingFee: shipping,
      discountAmount: discount,
    );

    if (customCashAmount.value == 0.0 || customOnlineAmount.value > 0) {
      customOnlineAmount.value = payableAmount;
    }
  }

  Future<void> cancelTerminal() async {
    _isTerminalCancelled = true;
    int? readerId = _activeTerminalReaderId;
    if (readerId == null) {
      final readerIdText = await StripeTerminalSettingsStorage.getReaderId();
      readerId = int.tryParse(readerIdText ?? '');
    }
    if (readerId != null) {
      await _service.cancelTerminalAction(readerId);
    }
    terminalStatusMessage.value = '';
    isLoading.value = false;
    customSnackBar(
      'Terminal Cancelled',
      'Terminal action has been cancelled.',
      snackBarType: SnackBarType.info,
    );
  }

  double get payableAmount {
    if (createdOrder.value == null) return 0.0;
    final base = couponValidation.value != null
        ? couponValidation.value!.finalAmount
        : createdOrder.value!.totalAmount;
    final afterDiscounts =
        base - manualDiscountAmount - customerTierDiscountAmount;
    return afterDiscounts > 0 ? afterDiscounts : 0.0;
  }

  double get couponDiscount {
    if (couponValidation.value != null) {
      return couponValidation.value!.discount;
    }
    return 0.0;
  }

  Future<void> submitCheckout(HomeController homeController) async {
    if (createdOrder.value == null) {
      customSnackBar(
        'Error',
        'Order not created yet',
        snackBarType: SnackBarType.error,
      );
      return;
    }

    final method = paymentMethod.value;
    if (_offlinePaymentMethods.contains(method)) {
      await _submitOfflineSale(homeController, method);
    } else {
      await _submitPosPayment(homeController, method);
    }
  }

  Future<void> _submitOfflineSale(
    HomeController homeController,
    String method,
  ) async {
    final customer = homeController.selectedCartCustomer.value;
    if (customer == null) return;

    final grandTotal = payableAmount;
    if (method == 'cash' &&
        cashTenderedInput.value.isNotEmpty &&
        cashCollect < grandTotal) {
      customSnackBar(
        'Insufficient Cash',
        'Cash collected (${CurrencyUtils.format(cashCollect)}) is less than total payable (${CurrencyUtils.format(grandTotal)})',
        snackBarType: SnackBarType.warning,
      );
      return;
    }

    if (isSplitPayment) {
      if (splitCash <= 0 || splitCash >= grandTotal) {
        customSnackBar(
          'Invalid Split Amount',
          'Cash portion must be more than 0 and less than total payable (${CurrencyUtils.format(grandTotal)})',
          snackBarType: SnackBarType.warning,
        );
        return;
      }
      if (splitTenderedInput.value.isNotEmpty && splitCashCollect < splitCash) {
        customSnackBar(
          'Insufficient Cash Handed',
          'Cash handed (${CurrencyUtils.format(splitCashCollect)}) is less than the cash portion (${CurrencyUtils.format(splitCash)})',
          snackBarType: SnackBarType.warning,
        );
        return;
      }
    }

    isLoading.value = true;
    try {
      final clientReference = await ClientReferenceGenerator.generate('order');
      final shift = Get.isRegistered<ShiftController>()
          ? Get.find<ShiftController>().currentShift.value
          : null;

      final customerHasEmail =
          customer.email != null && customer.email!.isNotEmpty;

      final cashCollectVal = method == 'cash'
          ? double.parse(cashCollect.toStringAsFixed(2))
          : (isSplitPayment
              ? double.parse(splitCashCollect.toStringAsFixed(2))
              : null);
      final cashReturnVal = method == 'cash'
          ? double.parse(cashReturn.toStringAsFixed(2))
          : (isSplitPayment
              ? double.parse(splitCashReturn.toStringAsFixed(2))
              : null);

      final syncPayload = <String, dynamic>{
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
        'payment_method': method == 'bank_transfer' ? 'bank_transfer' : 'cash',
        'delivery_type': deliveryType.value,
        if (deliveryType.value == 'store_pickup' &&
            _pendingPickupLocationId != null)
          'pickup_location_id': _pendingPickupLocationId,
        if (deliveryType.value == 'home_delivery' && _pendingAddressId != null)
          'shipping_address_id': _pendingAddressId,
        if (deliveryType.value == 'home_delivery' &&
            _pendingInlineAddress != null)
          'shipping_address': _pendingInlineAddress!.toJson(),
        'items': _pendingItemsPayload,
        if (shift != null && shift.id > 0) 'shift_id': shift.id,
        if (shift != null && shift.id <= 0)
          'shift_client_reference': shift.shiftCode.startsWith('PENDING-')
              ? shift.shiftCode.substring('PENDING-'.length)
              : null,
        if (manualDiscount.value != null)
          'manual_discount': manualDiscount.value,
        if (homeController.activeDraftOrder.value?.id != null)
          'draft_order_id': homeController.activeDraftOrder.value!.id,
        if (cashCollectVal != null) 'cash_collect': cashCollectVal,
        if (cashReturnVal != null) 'cash_return': cashReturnVal,
      };

      final localPayload = <String, dynamic>{
        'grand_total': grandTotal,
        'subtotal': createdOrder.value!.subtotal,
        'tax': createdOrder.value!.taxAmount,
        'shipping': createdOrder.value!.shippingFee,
        'discount': totalDiscount,
        'customer_name': customer.fullName,
        'customer_phone': customer.phone,
        'customer_email': customer.email,
        'notes': notesController.text.trim(),
        if (homeController.activeDraftOrder.value?.id != null)
          'draft_order_id': homeController.activeDraftOrder.value!.id,
        if (cashCollectVal != null) 'cash_collect': cashCollectVal,
        if (cashReturnVal != null) 'cash_return': cashReturnVal,
      };

      await PendingOrderRepository.add(
        clientReference: clientReference,
        shiftClientReference: syncPayload['shift_client_reference'] as String?,
        orderJson: {'sync': syncPayload, 'local': localPayload},
      );
      for (final item in _pendingItemsPayload) {
        final productId = JsonUtils.asIntOrNull(item['product_id']);
        if (productId == null) continue;
        unawaited(
          _bootstrapController.decrementStockLocally(
            productId: productId,
            variantId: JsonUtils.asIntOrNull(item['variant_id']),
            quantitySold: JsonUtils.asInt(item['quantity'], fallback: 1),
          ),
        );
      }

      customSnackBar(
        'Sale Complete',
        'Order saved. It will sync automatically once online.',
        snackBarType: SnackBarType.success,
      );

      final bootstrap = _bootstrapController.data.value;
      if (bootstrap != null) {
        unawaited(
          _printLocalReceipt(
            bootstrap: bootstrap,
            homeController: homeController,
            customer: customer,
            receiptId: clientReference,
            grandTotal: grandTotal,
          ),
        );
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
      customSnackBar(
        'Error',
        'Could not save the sale: $e',
        snackBarType: SnackBarType.error,
      );
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
        discount: totalDiscount,
        tax: createdOrder.value?.taxAmount ?? 0,
        shipping: createdOrder.value?.shippingFee ?? 0,
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

      final printed = await ThermalPrinterService().printReceipt(
        receipt,
        printerIp: device.ipAddress,
      );
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

  Future<void> _submitPosPayment(
    HomeController homeController,
    String method,
  ) async {
    final customer = homeController.selectedCartCustomer.value;
    if (customer == null) return;
    final splitCashAmount = isSplitPayment ? splitCash : null;

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
        manualDiscount: manualDiscount.value,
        draftOrderId: homeController.activeDraftOrder.value?.id,
      );

      if (!createResponse.isSuccess || createResponse.order == null) {
        customSnackBar(
          'Order Creation Failed',
          createResponse.message,
          snackBarType: SnackBarType.error,
        );
        return;
      }
      createdOrder.value = createResponse.order;

      final orderCode = createdOrder.value!.orderCode;
      if (orderCode == null || orderCode.isEmpty) {
        customSnackBar(
          'Error',
          'Order was created but no order code was returned by the server.',
          snackBarType: SnackBarType.error,
        );
        return;
      }

      final realTotal = double.parse(
        createdOrder.value!.totalAmount.toStringAsFixed(2),
      );

      double? cashAmount;
      double? bankAmount;
      double? terminalAmount;
      double? cashCollectVal;
      double? cashReturnVal;

      if (method == 'cash') {
        if (cashTenderedInput.value.isNotEmpty && cashCollect < realTotal) {
          customSnackBar(
            'Insufficient Cash',
            'Cash collected (${CurrencyUtils.format(cashCollect)}) is less than total payable (${CurrencyUtils.format(realTotal)})',
            snackBarType: SnackBarType.warning,
          );
          return;
        }
        cashAmount = realTotal;
        cashCollectVal = double.parse(cashCollect.toStringAsFixed(2));
        cashReturnVal = double.parse(cashReturn.toStringAsFixed(2));
      } else if (splitCashAmount != null) {
        cashAmount = double.parse(splitCashAmount.toStringAsFixed(2));
        if (cashAmount <= 0 || cashAmount >= realTotal) {
          customSnackBar(
            'Invalid Split Amount',
            'Cash portion must be more than 0 and less than the order total '
                '(${CurrencyUtils.format(realTotal)})',
            snackBarType: SnackBarType.warning,
          );
          return;
        }
        if (splitTenderedInput.value.isNotEmpty && splitCashCollect < cashAmount) {
          customSnackBar(
            'Insufficient Cash Handed',
            'Cash handed (${CurrencyUtils.format(splitCashCollect)}) is less than the cash portion (${CurrencyUtils.format(cashAmount)})',
            snackBarType: SnackBarType.warning,
          );
          return;
        }
        cashCollectVal = double.parse(splitCashCollect.toStringAsFixed(2));
        cashReturnVal = double.parse(splitCashReturn.toStringAsFixed(2));

        // Computed as the remainder so the two parts always sum to exactly
        // realTotal, even with floating-point rounding.
        final otherPart = double.parse(
          (realTotal - cashAmount).toStringAsFixed(2),
        );
        if (method == 'cash_bank_transfer') {
          bankAmount = otherPart;
        } else {
          terminalAmount = otherPart;
        }
      } else if (method == 'stripe_terminal') {
        terminalAmount = realTotal;
      }

      int? readerId;
      if (method == 'stripe_terminal' || method == 'cash_stripe_terminal') {
        readerId = await _ensureTerminalReady();
        if (readerId == null) return;
        _isTerminalCancelled = false;
        _activeTerminalReaderId = readerId;
      }

      final payResponse = await _service.payPos(
        orderCode: orderCode,
        paymentType: method,
        cashAmount: cashAmount,
        bankAmount: bankAmount,
        terminalAmount: terminalAmount,
        readerId: readerId,
        cashCollect: cashCollectVal,
        cashReturn: cashReturnVal,
      );

      if (_isTerminalCancelled) return;

      if (!payResponse.isSuccess) {
        customSnackBar(
          'Payment Failed',
          payResponse.message,
          snackBarType: SnackBarType.error,
        );
        return;
      }

      if (payResponse.requiresAction && payResponse.terminal != null) {
        await _runTerminalCaptureFlow(
          homeController,
          createdOrder.value!.id,
          payResponse.terminal!.paymentReference,
        );
      } else {
        await _completeCheckout(homeController, createdOrder.value!.id);
      }
    } catch (e) {
      log("CheckoutController _submitPosPayment error: $e");
      if (!_isTerminalCancelled) {
        final errorStr = e.toString().toLowerCase();
        final friendlyMsg = errorStr.contains('timeout') ||
                errorStr.contains('socket') ||
                errorStr.contains('readercommunicationerror')
            ? 'Card reader is offline or unreachable. Please check that the reader is powered on and connected to Wi-Fi.'
            : 'An error occurred during payment. Please try again.';
        customSnackBar(
          'Payment Error',
          friendlyMsg,
          snackBarType: SnackBarType.error,
        );
      }
    } finally {
      isLoading.value = false;
      terminalStatusMessage.value = '';
    }
  }

  Future<int?> _ensureTerminalReady() async {
    // Cloud reader (WisePOS E / S700): backend pushes payment directly to the
    // reader via Stripe Cloud API. Reader ID is fixed to 1.
    // Bypass local SDK discovery so payPos is called immediately without timing out.
    const readerId = 1;
    terminalStatusMessage.value = 'Sending payment to card reader...';
    return readerId;
  }

  Future<void> _runTerminalCaptureFlow(
    HomeController homeController,
    int orderId,
    String paymentReference,
  ) async {
    const pollInterval = Duration(seconds: 2);
    const maxAttempts = 60; // ~2 minutes before giving up

    terminalStatusMessage.value = 'Present the card on the reader now...';

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      if (_isTerminalCancelled) return;
      await Future.delayed(pollInterval);
      if (_isTerminalCancelled) return;
      final status = await _service.pollTerminalPaymentStatus(paymentReference);
      if (_isTerminalCancelled) return;
      if (!status.isSuccess) continue;

      terminalStatusMessage.value = switch (status.state) {
        'waiting_for_card' => 'Waiting for card... (present it on the reader)',
        _ => 'Card status: ${status.state ?? 'checking'}...',
      };

      if (status.isDeclinedOrFailed) {
        customSnackBar(
          'Card Declined',
          status.failureMessage ?? 'The card payment was declined.',
          snackBarType: SnackBarType.error,
        );
        return;
      }

      if (status.isCaptured) {
        await _completeCheckout(homeController, orderId);
        return;
      }

      if (status.canCapture || status.isSucceeded) {
        final capture = await _service.captureTerminalPayment(paymentReference);
        if (_isTerminalCancelled) return;
        if (!capture.isSuccess) {
          customSnackBar(
            'Capture Failed',
            capture.message,
            snackBarType: SnackBarType.error,
          );
          return;
        }
        await _completeCheckout(homeController, orderId);
        return;
      }
    }

    if (!_isTerminalCancelled) {
      customSnackBar(
        'Card Payment Timed Out',
        'No card was presented in time. You can retry payment for this order.',
        snackBarType: SnackBarType.warning,
      );
    }
  }

  Future<void> _completeCheckout(
    HomeController homeController,
    int orderId,
  ) async {
    customSnackBar(
      'Checkout Success',
      'Order paid successfully.',
      snackBarType: SnackBarType.success,
    );
    unawaited(PrintReceiptHelper.printOrderReceipt(orderId));
    homeController.clearCart();
    homeController.showCheckoutPanel.value = false;
    resetCheckoutState();
  }
}
