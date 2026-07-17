import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:modfirstpos/modules/checkout/service/checkout_service.dart';
import 'package:modfirstpos/modules/checkout/model/checkout_models.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class CheckoutController extends GetxController {
  final CheckoutService _service = CheckoutService();
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
  final Rxn<CouponValidationResponse> couponValidation = Rxn<CouponValidationResponse>();
  final RxString couponError = ''.obs;
  final Rxn<CreatedOrder> createdOrder = Rxn<CreatedOrder>();
  final RxString paymentMethod = 'without_payment'.obs;
  final RxDouble customOnlineAmount = 0.0.obs;
  final RxDouble customCashAmount = 0.0.obs;

  @override
  void onClose() {
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
    couponValidation.value = null;
    couponError.value = '';
    createdOrder.value = null;
    paymentMethod.value = 'without_payment';
    customOnlineAmount.value = 0.0;
    customCashAmount.value = 0.0;
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

      await loadAddresses(userId);
      await loadPickupLocations();
    } catch (e) {
      log("CheckoutController startCheckoutFlow error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAddresses(int userId) async {
    final response = await _service.fetchAddresses(userId: userId);
    if (response.isSuccess) {
      addresses.assignAll(response.payload);
      if (addresses.isNotEmpty) {
        selectedAddress.value = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
      }
    } else {
      addresses.clear();
      selectedAddress.value = null;
    }
  }

  Future<void> loadPickupLocations() async {
    final response = await _service.fetchPickupLocations();
    if (response.isSuccess) {
      pickupLocations.assignAll(response.payload);
      if (pickupLocations.isNotEmpty) {
        selectedPickupLocation.value = pickupLocations.first;
      }
    } else {
      pickupLocations.clear();
      selectedPickupLocation.value = null;
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
    if (cityController.text.trim().isEmpty) {
      customSnackBar('Validation Error', 'City is required', snackBarType: SnackBarType.warning);
      return false;
    }
    return true;
  }

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

    isLoading.value = true;
    try {
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
      }

      final response = await _service.createOrder(
        userId: customer.id,
        email: customer.email ?? '',
        phone: customer.phone ?? '',
        fullName: customer.fullName ?? 'Guest',
        deliveryType: deliveryType.value,
        shippingAddressId: addressId,
        billingAddressId: addressId,
        shippingAddress: inlineAddress,
        pickupLocationId: selectedPickupLocation.value?.id,
        items: itemsPayload,
        notes: 'POS Checkout order placed',
      );

      if (response.isSuccess && response.order != null) {
        createdOrder.value = response.order;
        customOnlineAmount.value = response.order!.totalAmount;
        customCashAmount.value = 0.0;
        return true;
      } else {
        customSnackBar('Order Creation Failed', response.message, snackBarType: SnackBarType.error);
        return false;
      }
    } catch (e) {
      log("CheckoutController createOrder error: $e");
      customSnackBar('Error', 'An error occurred while placing order: $e', snackBarType: SnackBarType.error);
      return false;
    } finally {
      isLoading.value = false;
    }
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
    isLoading.value = true;
    try {
      final orderId = createdOrder.value!.id;
      final method = paymentMethod.value;
      double? online;
      double? cash;
      if (method == 'stripe_and_cash' || method == 'paypal_and_cash') {
        online = customOnlineAmount.value;
        cash = customCashAmount.value;
        if ((online + cash) < payableAmount) {
          customSnackBar(
            'Insufficient Amount',
            'Split payment amounts must total \$${payableAmount.toStringAsFixed(2)}',
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
      log("CheckoutController submitCheckout error: $e");
      customSnackBar('Error', 'An error occurred during checkout: $e', snackBarType: SnackBarType.error);
    } finally {
      isLoading.value = false;
    }
  }
}
