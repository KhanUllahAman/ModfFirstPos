import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/customer/controller/customer_controller.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
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
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    final controller = Get.find<CustomerController>();
    final customer = await controller.addCustomer(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
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

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (value.trim().length < 7) return 'Enter a valid phone number';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return null; // optional
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
                CustomTextFormField(
                  controller: _phoneController,
                  labelText: 'Phone Number *',
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  borderRadius: 10,
                ),
                SizedBox(height: context.responsiveHeight(0.018)),
                CustomTextFormField(
                  controller: _emailController,
                  labelText: 'Email (Optional)',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  borderRadius: 10,
                ),
                SizedBox(height: context.responsiveHeight(0.018)),
                CustomTextFormField(
                  controller: _addressController,
                  labelText: 'Address (Optional)',
                  borderRadius: 10,
                ),
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
