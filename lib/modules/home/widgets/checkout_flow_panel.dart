import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/currency_utils.dart';
import 'package:modfirstpos/modules/checkout/controller/checkout_controller.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';

class CheckoutFlowPanel extends StatelessWidget {
  final HomeController homeController;
  final CheckoutController checkoutController = Get.find<CheckoutController>();

  CheckoutFlowPanel({super.key, required this.homeController});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Obx(() {
      final currentType = checkoutController.deliveryType.value;
      final isOrderCreated = checkoutController.createdOrder.value != null;

      Widget body;
      String title;

      if (isOrderCreated) {
        title = 'COMPLETE CHECKOUT';
        body = _buildPaymentStep(context, theme);
      } else if (currentType.isEmpty) {
        title = 'DELIVERY OPTION';
        body = _buildDeliveryTypeStep(context, theme);
      } else if (currentType == 'home_delivery') {
        title = checkoutController.showNewAddressForm.value
            ? 'NEW ADDRESS'
            : 'SHIPPING ADDRESS';
        body = _buildAddressStep(context, theme);
      } else {
        title = 'PICKUP LOCATION';
        body = _buildPickupLocationStep(context, theme);
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header Bar matching side panel layout
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: ColorResources.blackColor,
                  ),
                  onPressed: () {
                    if (isOrderCreated) {
                      // Once order is created, clicking back takes back to delivery selection
                      checkoutController.createdOrder.value = null;
                    } else if (checkoutController.showNewAddressForm.value) {
                      checkoutController.showNewAddressForm.value = false;
                    } else if (currentType.isNotEmpty) {
                      checkoutController.deliveryType.value = '';
                    } else {
                      homeController.showCheckoutPanel.value = false;
                    }
                  },
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: AppFonts.geistMono(
                      fontSize: context.fontSM,
                      fontWeight: FontWeight.w700,
                      color: ColorResources.labelColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                  onPressed: () {
                    homeController.showCheckoutPanel.value = false;
                  },
                ),
              ],
            ),
            const Divider(height: 12, color: ColorResources.cardBorderColor),
            const SizedBox(height: 8),
            // Panel Body
            if (checkoutController.isLoading.value)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: ColorResources.appAccentColor,
                  ),
                ),
              )
            else
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    primary: false,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: body,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  // --- Step 1: Delivery Option Selection ---
  Widget _buildDeliveryTypeStep(BuildContext context, AppThemeService theme) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildChoiceCard(
          icon: Iconsax.truck_fast,
          title: 'Home Delivery',
          description: 'Ship order directly to customer home address.',
          isSelected: false,
          onTap: () {
            checkoutController.deliveryType.value = 'home_delivery';
          },
          theme: theme,
        ),
        const SizedBox(height: 16),
        _buildChoiceCard(
          icon: Iconsax.shop,
          title: 'Store Pickup',
          description: 'Hold order for pickup at retail branch.',
          isSelected: false,
          onTap: () {
            checkoutController.deliveryType.value = 'store_pickup';
          },
          theme: theme,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildChoiceCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
    required AppThemeService theme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.secondaryColor.value.withOpacity(0.08)
                : ColorResources.backgroundColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? theme.secondaryColor.value : ColorResources.cardBorderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? theme.secondaryColor.value : ColorResources.labelColor.withOpacity(0.6),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.geistMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ColorResources.labelColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppFonts.geistMono(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // --- Step 2 (A): Home Delivery Address Selection & Form ---
  Widget _buildAddressStep(BuildContext context, AppThemeService theme) {
    if (checkoutController.showNewAddressForm.value) {
      return _buildNewAddressForm(context, theme);
    }

    final addressList = checkoutController.addresses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select a Saved Address:',
              style: AppFonts.geistMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700],
              ),
            ),
            TextButton.icon(
              onPressed: () {
                checkoutController.showNewAddressForm.value = true;
              },
              icon: Icon(Icons.add_location_alt_rounded, size: 14, color: theme.secondaryColor.value),
              label: Text(
                'Add New',
                style: AppFonts.geistMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: theme.secondaryColor.value,
                ),
              ),
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (addressList.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Icon(Icons.location_off_rounded, size: 32, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  'No saved addresses found.',
                  style: AppFonts.geistMono(fontSize: 10, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: () => checkoutController.showNewAddressForm.value = true,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.secondaryColor.value,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Create Address', style: AppFonts.geistMono(fontSize: 10, color: Colors.white)),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: addressList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final addr = addressList[index];
              final isSelected = checkoutController.selectedAddress.value?.id == addr.id;

              return InkWell(
                onTap: () {
                  checkoutController.selectedAddress.value = addr;
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.secondaryColor.value.withOpacity(0.04) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? theme.secondaryColor.value : ColorResources.cardBorderColor,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: addr.id,
                        groupValue: checkoutController.selectedAddress.value?.id,
                        activeColor: theme.secondaryColor.value,
                        onChanged: (val) {
                          checkoutController.selectedAddress.value = addr;
                        },
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    addr.fullName ?? 'Unnamed Address',
                                    style: AppFonts.geistMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: ColorResources.labelColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (addr.isDefault)
                                  Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.value.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      'Default',
                                      style: AppFonts.geistMono(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              addr.summaryLine,
                              style: AppFonts.geistMono(fontSize: 9, color: Colors.grey[600]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (addr.phone != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Phone: ${addr.phone}',
                                style: AppFonts.geistMono(fontSize: 8, color: Colors.grey[500]),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 20),
        AppButton(
          onPressed: () => checkoutController.createOrder(homeController),
          isLoading: checkoutController.isLoading.value,
          backgroundColor: theme.secondaryColor.value,
          borderRadius: 8,
          child: Text(
            'Confirm Address & Create Order',
            style: AppFonts.geistMono(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: theme.onSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewAddressForm(BuildContext context, AppThemeService theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextFormField(
          controller: checkoutController.fullNameController,
          labelText: 'Full Name *',
          hintText: 'Enter receiver name',
          borderRadius: 10,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: checkoutController.phoneController,
          labelText: 'Phone *',
          hintText: 'Enter phone number',
          keyboardType: TextInputType.phone,
          borderRadius: 10,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: checkoutController.emailController,
          labelText: 'Email',
          hintText: 'Enter email address (optional)',
          keyboardType: TextInputType.emailAddress,
          borderRadius: 10,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: checkoutController.address1Controller,
          labelText: 'Address Line 1 *',
          hintText: 'Street address, P.O. box',
          borderRadius: 10,
        ),
        const SizedBox(height: 10),
        CustomTextFormField(
          controller: checkoutController.address2Controller,
          labelText: 'Address Line 2 (Optional)',
          hintText: 'Apartment, suite, unit',
          borderRadius: 10,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: checkoutController.cityController,
                labelText: 'City *',
                hintText: 'City name',
                borderRadius: 10,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextFormField(
                controller: checkoutController.stateController,
                labelText: 'State',
                hintText: 'State/Region',
                borderRadius: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: checkoutController.postalCodeController,
                labelText: 'Postal Code',
                hintText: 'Zip Code',
                borderRadius: 10,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextFormField(
                controller: checkoutController.countryController,
                labelText: 'Country',
                hintText: 'Country',
                borderRadius: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  checkoutController.showNewAddressForm.value = false;
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: const BorderSide(color: ColorResources.cardBorderColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Cancel', style: AppFonts.geistMono(fontSize: 11, color: Colors.black)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                onPressed: () => checkoutController.createOrder(homeController),
                isLoading: checkoutController.isLoading.value,
                backgroundColor: theme.secondaryColor.value,
                borderRadius: 8,
                child: Text(
                  'Place Order',
                  style: AppFonts.geistMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.onSecondaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // --- Step 2 (B): Store Pickup Location Selection ---
  Widget _buildPickupLocationStep(BuildContext context, AppThemeService theme) {
    final locationList = checkoutController.pickupLocations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select a branch for pickup:',
          style: AppFonts.geistMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 10),
        if (locationList.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                'No locations configured.',
                style: AppFonts.geistMono(fontSize: 10, color: Colors.grey[600]),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: locationList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final loc = locationList[index];
              final isSelected = checkoutController.selectedPickupLocation.value?.id == loc.id;

              return InkWell(
                onTap: () {
                  checkoutController.selectedPickupLocation.value = loc;
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? theme.secondaryColor.value.withOpacity(0.04) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? theme.secondaryColor.value : ColorResources.cardBorderColor,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: loc.id,
                        groupValue: checkoutController.selectedPickupLocation.value?.id,
                        activeColor: theme.secondaryColor.value,
                        onChanged: (val) {
                          checkoutController.selectedPickupLocation.value = loc;
                        },
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.displayName,
                              style: AppFonts.geistMono(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: ColorResources.labelColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loc.address ?? '',
                              style: AppFonts.geistMono(fontSize: 9, color: Colors.grey[600]),
                            ),
                            if (loc.phone != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Phone: ${loc.phone}',
                                style: AppFonts.geistMono(fontSize: 8, color: Colors.grey[500]),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 20),
        AppButton(
          onPressed: () => checkoutController.createOrder(homeController),
          isLoading: checkoutController.isLoading.value,
          backgroundColor: theme.secondaryColor.value,
          borderRadius: 8,
          child: Text(
            'Confirm Location & Create Order',
            style: AppFonts.geistMono(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: theme.onSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // --- Step 3: Coupon Validate & Checkout Payment ---
  Widget _buildPaymentStep(BuildContext context, AppThemeService theme) {
    final order = checkoutController.createdOrder.value!;
    final validation = checkoutController.couponValidation.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Order info summary
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ColorResources.backgroundColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColorResources.cardBorderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ID: #${order.id}',
                    style: AppFonts.geistMono(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  if (order.orderNumber != null)
                    Expanded(
                      child: Text(
                        order.orderNumber!,
                        style: AppFonts.geistMono(fontSize: 9, color: Colors.grey[600]),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const Divider(height: 12),
              _buildAmountRow('Subtotal', order.subtotal),
              _buildAmountRow('Tax', order.taxAmount),
              _buildAmountRow('Shipping Fee', order.shippingFee),
              if (checkoutController.couponDiscount > 0)
                _buildAmountRow('Coupon Discount', -checkoutController.couponDiscount, isDiscount: true),
              const Divider(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Payable',
                    style: AppFonts.geistMono(fontSize: 12, fontWeight: FontWeight.bold, color: ColorResources.labelColor),
                  ),
                  Text(
                    CurrencyUtils.format(checkoutController.payableAmount, decimals: 2),
                    style: AppFonts.geistMono(fontSize: 13, fontWeight: FontWeight.bold, color: theme.secondaryColor.value),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Coupon Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: checkoutController.couponController,
                labelText: 'Coupon / Promo Code',
                hintText: 'Apply coupon code',
                readOnly: validation != null || checkoutController.isCouponLoading.value,
                borderRadius: 10,
              ),
            ),
            const SizedBox(width: 8),
            if (validation != null)
              IconButton(
                icon: const Icon(Icons.delete_forever_rounded, color: ColorResources.gradientRed),
                onPressed: () => checkoutController.removeCoupon(),
              )
            else
              SizedBox(
                width: 80,
                child: AppButton(
                  onPressed: () => checkoutController.validateCoupon(order.totalAmount),
                  isLoading: checkoutController.isCouponLoading.value,
                  backgroundColor: theme.primaryColor.value,
                  borderRadius: 10,
                  height: 48,
                  child: Text(
                    'Apply',
                    style: AppFonts.geistMono(fontSize: 11, fontWeight: FontWeight.bold, color: theme.onPrimaryColor),
                  ),
                ),
              ),
          ],
        ),
        if (checkoutController.couponError.value.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              checkoutController.couponError.value,
              style: AppFonts.geistMono(fontSize: 9, color: ColorResources.gradientRed, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Payment Method Selector
        Text(
          'Select Payment Method:',
          style: AppFonts.geistMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[700]),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColorResources.cardBorderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: checkoutController.paymentMethod.value,
              isExpanded: true,
              style: AppFonts.geistMono(fontSize: 11, color: Colors.black),
              onChanged: (val) {
                if (val != null) {
                  checkoutController.paymentMethod.value = val;
                  checkoutController.customOnlineAmount.value = checkoutController.payableAmount;
                  checkoutController.customCashAmount.value = 0.0;
                }
              },
              items: const [
                DropdownMenuItem(value: 'without_payment', child: Text('Manual / Pay Later')),
                DropdownMenuItem(value: 'stripe', child: Text('Stripe Card Payment')),
                DropdownMenuItem(value: 'paypal', child: Text('PayPal Payment')),
                DropdownMenuItem(value: 'stripe_and_cash', child: Text('Split (Stripe + Cash)')),
                DropdownMenuItem(value: 'paypal_and_cash', child: Text('Split (PayPal + Cash)')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Split payment input section
        if (checkoutController.paymentMethod.value.endsWith('_and_cash')) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.yellow[50]!.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.yellow[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Split payment details:',
                  style: AppFonts.geistMono(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildSplitAmountField(
                        label: 'Online Amount',
                        value: checkoutController.customOnlineAmount.value,
                        onChanged: (val) {
                          final parsed = double.tryParse(val) ?? 0.0;
                          checkoutController.customOnlineAmount.value = parsed;
                          final remainder = checkoutController.payableAmount - parsed;
                          checkoutController.customCashAmount.value = remainder > 0 ? remainder : 0.0;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSplitAmountField(
                        label: 'Cash Amount',
                        value: checkoutController.customCashAmount.value,
                        onChanged: (val) {
                          final parsed = double.tryParse(val) ?? 0.0;
                          checkoutController.customCashAmount.value = parsed;
                          final remainder = checkoutController.payableAmount - parsed;
                          checkoutController.customOnlineAmount.value = remainder > 0 ? remainder : 0.0;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        AppButton(
          onPressed: () => checkoutController.submitCheckout(homeController),
          isLoading: checkoutController.isLoading.value,
          backgroundColor: theme.secondaryColor.value,
          borderRadius: 8,
          child: Text(
            'Confirm & Pay',
            style: AppFonts.geistMono(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: theme.onSecondaryColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppFonts.geistMono(fontSize: 9, color: Colors.grey[700])),
          Text(
            isDiscount
                ? '-\$${(-amount).toStringAsFixed(2)}'
                : amount >= 0
                    ? '\$${amount.toStringAsFixed(2)}'
                    : '-\$${(-amount).toStringAsFixed(2)}',
            style: AppFonts.geistMono(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isDiscount ? ColorResources.successGreen : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitAmountField({
    required String label,
    required double value,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: value.toStringAsFixed(2),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: AppFonts.geistMono(fontSize: 10),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppFonts.geistMono(fontSize: 8, color: Colors.black54),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
