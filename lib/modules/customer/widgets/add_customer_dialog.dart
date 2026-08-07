import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/customer/controller/customer_controller.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/customer/model/discount_tier_model.dart';
import 'package:modfirstpos/modules/customer/service/discount_tier_service.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';
import 'package:modfirstpos/shared/widgets/dailogs/dialog_transitions.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';

/// Dialog for creating a new customer directly from the POS home screen.
///
/// Saves offline-first (SQLite) and returns the created [CustomerModel] so
/// the caller can auto-select it. No screen navigation happens.
class AddCustomerDialog extends StatefulWidget {
  const AddCustomerDialog({super.key});

  /// Shows the dialog with the app-standard fade/scale transition and
  /// resolves with the created customer (or null if cancelled).
  static Future<CustomerModel?> show(BuildContext context) {
    return showAppFadeDialog<CustomerModel?>(
      context,
      barrierLabel: 'Add Customer',
      builder: (_) => const AddCustomerDialog(),
    );
  }

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final DiscountTierService _tierService = DiscountTierService();
  bool _isSaving = false;

  /// Full E.164 number (with country code) from IntlPhoneField.
  String _fullPhoneNumber = '';

  String _accountType = 'retail';
  List<DiscountTierModel> _tiers = [];
  bool _isLoadingTiers = false;
  DiscountTierModel? _selectedTier;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadTiersIfNeeded() async {
    if (_tiers.isNotEmpty || _isLoadingTiers) return;
    setState(() => _isLoadingTiers = true);
    final response = await _tierService.fetchDiscountTiers();
    if (!mounted) return;
    setState(() {
      _isLoadingTiers = false;
      if (response.isSuccess) _tiers = response.payload;
    });
  }

  Future<void> _createNewTier() async {
    final created = await _CreateDiscountTierDialog.show(context);
    if (created == null || !mounted) return;
    setState(() {
      _tiers = [created, ..._tiers];
      _selectedTier = created;
    });
  }

  Future<void> _save() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (_isSaving || !formValid || _fullPhoneNumber.trim().isEmpty) return;
    if (_accountType == 'wholesale' && _selectedTier == null) {
      customSnackBar(
        'Discount Tier Required',
        'Select a discount tier for this wholesale customer.',
        snackBarType: SnackBarType.warning,
      );
      return;
    }
    setState(() => _isSaving = true);

    final controller = Get.find<CustomerController>();
    final customer = await controller.addCustomer(
      fullName: _nameController.text.trim(),
      phone: _fullPhoneNumber.trim(),
      email: _emailController.text.trim(),
      accountType: _accountType,
      discountTier: _accountType == 'wholesale' ? _selectedTier : null,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (customer != null) {
      Navigator.of(context).pop(customer);
      customSnackBar(
        'Customer Added',
        '${customer.displayName} saved and selected',
        snackBarType: SnackBarType.success,
      );
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w\.\-\+]+@[\w\-]+(\.[\w\-]+)+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: ColorResources.whiteColor,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.responsiveWidth(0.30),
        vertical: context.responsiveHeight(0.06),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(0.025),
          vertical: context.responsiveHeight(0.025),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Customer',
                  textAlign: TextAlign.center,
                  style: AppFonts.geistMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorResources.labelColor,
                  ),
                ),
                Divider(
                  height: context.responsiveHeight(0.03),
                  color: ColorResources.cardBorderColor,
                ),
                CustomTextFormField(
                  controller: _nameController,
                  labelText: 'Name *',
                  validator: _validateName,
                  borderRadius: 10,
                ),
                SizedBox(height: context.responsiveHeight(0.018)),
                IntlPhoneField(
                  initialCountryCode: 'US',
                  disableLengthCheck: false,
                  style: AppFonts.geistMono(
                    color: ColorResources.labelColor,
                    fontSize: 14,
                  ),
                  dropdownTextStyle: AppFonts.geistMono(
                    color: ColorResources.labelColor,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    labelStyle: AppFonts.geistMono(
                      fontSize: 13,
                      color: ColorResources.labelColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: ColorResources.labelBorderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: ColorResources.labelBorderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: ColorResources.labelColor, width: 2.0),
                    ),
                  ),
                  pickerDialogStyle: PickerDialogStyle(
                    backgroundColor: ColorResources.whiteColor,
                  ),
                  onChanged: (phone) {
                    _fullPhoneNumber = phone.completeNumber;
                  },
                  validator: (phone) {
                    if (phone == null || phone.number.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.responsiveHeight(0.018)),
                CustomTextFormField(
                  controller: _emailController,
                  labelText: 'Email *',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  borderRadius: 10,
                ),
                SizedBox(height: context.responsiveHeight(0.018)),
                Text(
                  'Account Type',
                  style: AppFonts.geistMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: context.responsiveHeight(0.008)),
                Row(
                  children: [
                    Expanded(
                      child: _AccountTypeChoice(
                        label: 'Retail',
                        isSelected: _accountType == 'retail',
                        onTap: () => setState(() {
                          _accountType = 'retail';
                          _selectedTier = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AccountTypeChoice(
                        label: 'Wholesale',
                        isSelected: _accountType == 'wholesale',
                        onTap: () {
                          setState(() => _accountType = 'wholesale');
                          _loadTiersIfNeeded();
                        },
                      ),
                    ),
                  ],
                ),
                if (_accountType == 'wholesale') ...[
                  SizedBox(height: context.responsiveHeight(0.018)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _isLoadingTiers
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              )
                            : Builder(builder: (context) {
                                final theme = Get.find<AppThemeService>();
                                return DropdownButtonFormField<DiscountTierModel>(
                                  initialValue: _selectedTier,
                                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                                      color: theme.secondaryColor.value),
                                  dropdownColor: ColorResources.whiteColor,
                                  borderRadius: BorderRadius.circular(10),
                                  style: AppFonts.geistMono(
                                    fontSize: 13,
                                    color: ColorResources.labelColor,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Discount Tier *',
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 14),
                                    labelStyle: AppFonts.geistMono(
                                      fontSize: 13,
                                      color: ColorResources.labelColor,
                                    ),
                                    floatingLabelStyle: AppFonts.geistMono(
                                      fontSize: 13,
                                      color: theme.secondaryColor.value,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: ColorResources.labelBorderColor),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: ColorResources.labelBorderColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: theme.secondaryColor.value,
                                          width: 2.0),
                                    ),
                                  ),
                                  items: _tiers
                                      .map((tier) => DropdownMenuItem(
                                            value: tier,
                                            child: Text(
                                              tier.label,
                                              style: AppFonts.geistMono(fontSize: 13),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (tier) =>
                                      setState(() => _selectedTier = tier),
                                  validator: (value) => value == null
                                      ? 'Select a discount tier'
                                      : null,
                                );
                              }),
                      ),
                      const SizedBox(width: 8),
                      Builder(builder: (context) {
                        final theme = Get.find<AppThemeService>();
                        return IconButton(
                          onPressed: _createNewTier,
                          icon: Icon(Icons.add_circle_rounded,
                              color: theme.secondaryColor.value),
                          tooltip: 'Create new discount tier',
                        );
                      }),
                    ],
                  ),
                ],
                SizedBox(height: context.responsiveHeight(0.028)),
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          backgroundColor: theme.primaryColor.value,
                          isLoading: false,
                          borderRadius: 10,
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: AppFonts.geistMono(
                              color: theme.onPrimaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.responsiveWidth(0.015)),
                      Expanded(
                        child: AppButton(
                          backgroundColor: theme.secondaryColor.value,
                          isLoading: _isSaving,
                          borderRadius: 10,
                          onPressed: _save,
                          child: Text(
                            'Save',
                            style: AppFonts.geistMono(
                              color: theme.onSecondaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Themed retail/wholesale selector chip.
class _AccountTypeChoice extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeChoice({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final accent = theme.secondaryColor.value;
    return Material(
      color: isSelected ? accent.withOpacity(0.10) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? accent : ColorResources.cardBorderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppFonts.geistMono(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? accent : ColorResources.labelColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small sub-dialog for creating a new discount tier on the fly, without
/// leaving the Add Customer flow. Resolves with the created tier (or null
/// if cancelled).
class _CreateDiscountTierDialog extends StatefulWidget {
  const _CreateDiscountTierDialog();

  static Future<DiscountTierModel?> show(BuildContext context) {
    return showAppFadeDialog<DiscountTierModel?>(
      context,
      barrierLabel: 'Create Discount Tier',
      builder: (_) => const _CreateDiscountTierDialog(),
    );
  }

  @override
  State<_CreateDiscountTierDialog> createState() =>
      _CreateDiscountTierDialogState();
}

class _CreateDiscountTierDialogState extends State<_CreateDiscountTierDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  final DiscountTierService _service = DiscountTierService();
  String _discountType = 'percentage';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    final response = await _service.createDiscountTier(
      name: _nameController.text.trim(),
      discountType: _discountType,
      discountValue: double.parse(_valueController.text.trim()),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (response.isSuccess && response.payload != null) {
      Navigator.of(context).pop(response.payload);
    } else {
      customSnackBar(
        'Could Not Create Tier',
        response.message.isNotEmpty
            ? response.message
            : 'Something went wrong.',
        snackBarType: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: ColorResources.whiteColor,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.responsiveWidth(0.32),
        vertical: context.responsiveHeight(0.1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Discount Tier',
                textAlign: TextAlign.center,
                style: AppFonts.geistMono(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ColorResources.labelColor,
                ),
              ),
              const Divider(height: 24, color: ColorResources.cardBorderColor),
              CustomTextFormField(
                controller: _nameController,
                labelText: 'Tier Name *',
                hintText: 'e.g. Discount Tier 2',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                borderRadius: 10,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _AccountTypeChoice(
                      label: 'Percentage',
                      isSelected: _discountType == 'percentage',
                      onTap: () => setState(() => _discountType = 'percentage'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AccountTypeChoice(
                      label: 'Fixed Amount',
                      isSelected: _discountType == 'fixed_amount',
                      onTap: () => setState(() => _discountType = 'fixed_amount'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextFormField(
                controller: _valueController,
                labelText:
                    _discountType == 'percentage' ? 'Percentage *' : 'Amount *',
                hintText: _discountType == 'percentage' ? 'e.g. 10' : 'e.g. 5.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final value = double.tryParse(v?.trim() ?? '');
                  if (value == null || value <= 0) return 'Enter a valid value';
                  return null;
                },
                borderRadius: 10,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      backgroundColor: theme.primaryColor.value,
                      isLoading: false,
                      borderRadius: 10,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: AppFonts.geistMono(
                          color: theme.onPrimaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      backgroundColor: theme.secondaryColor.value,
                      isLoading: _isSaving,
                      borderRadius: 10,
                      onPressed: _save,
                      child: Text(
                        'Create',
                        style: AppFonts.geistMono(
                          color: theme.onSecondaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
