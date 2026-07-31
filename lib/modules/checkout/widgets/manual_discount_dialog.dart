import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/checkout/controller/checkout_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';
import 'package:modfirstpos/shared/widgets/dailogs/dialog_transitions.dart';

/// Lets the cashier apply a manual/staff discount (percentage or fixed
/// amount, with an optional reason) to the order being checked out — sent
/// to the backend as `manual_discount` (online order create) or folded into
/// the local totals (offline cash/bank_transfer/without_payment sale).
class ManualDiscountDialog extends StatefulWidget {
  const ManualDiscountDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showAppFadeDialog<void>(
      context,
      barrierLabel: 'Apply Discount',
      builder: (_) => const ManualDiscountDialog(),
    );
  }

  @override
  State<ManualDiscountDialog> createState() => _ManualDiscountDialogState();
}

class _ManualDiscountDialogState extends State<ManualDiscountDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _valueController;
  late final TextEditingController _reasonController;
  String _type = 'percentage';

  @override
  void initState() {
    super.initState();
    final existing = Get.find<CheckoutController>().manualDiscount.value;
    _type = existing?['type'] as String? ?? 'percentage';
    _valueController = TextEditingController(
      text: existing != null ? '${existing['value']}' : '',
    );
    _reasonController = TextEditingController(
      text: existing?['reason'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  String? _validateValue(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Enter a discount value';
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) return 'Enter a valid amount';
    if (_type == 'percentage' && amount > 100) return 'Percentage cannot exceed 100';
    return null;
  }

  void _apply() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Get.find<CheckoutController>().applyManualDiscount(
      type: _type,
      value: double.parse(_valueController.text.trim()),
      reason: _reasonController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  void _remove() {
    Get.find<CheckoutController>().removeManualDiscount();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final hasExisting = Get.find<CheckoutController>().manualDiscount.value != null;

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
                  'Apply Discount',
                  textAlign: TextAlign.center,
                  style: AppFonts.geistMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorResources.labelColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manual/staff discount for this order.',
                  textAlign: TextAlign.center,
                  style: AppFonts.geistMono(fontSize: 11, color: Colors.grey[600]),
                ),
                Divider(
                  height: context.responsiveHeight(0.03),
                  color: ColorResources.cardBorderColor,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _TypeChoiceTile(
                        label: 'Percentage',
                        icon: Icons.percent_rounded,
                        isSelected: _type == 'percentage',
                        theme: theme,
                        onTap: () => setState(() => _type = 'percentage'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TypeChoiceTile(
                        label: 'Fixed Amount',
                        icon: Icons.attach_money_rounded,
                        isSelected: _type == 'fixed_amount',
                        theme: theme,
                        onTap: () => setState(() => _type = 'fixed_amount'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.responsiveHeight(0.018)),
                CustomTextFormField(
                  controller: _valueController,
                  labelText: _type == 'percentage' ? 'Discount % *' : 'Discount Amount *',
                  hintText: _type == 'percentage' ? 'e.g. 10' : 'e.g. 5.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateValue,
                  borderRadius: 10,
                ),
                SizedBox(height: context.responsiveHeight(0.018)),
                CustomTextFormField(
                  controller: _reasonController,
                  labelText: 'Reason (Optional)',
                  hintText: 'e.g. Staff discount',
                  borderRadius: 10,
                ),
                SizedBox(height: context.responsiveHeight(0.028)),
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
                    if (hasExisting) ...[
                      SizedBox(width: context.responsiveWidth(0.015)),
                      Expanded(
                        child: AppButton(
                          backgroundColor: ColorResources.gradientRed,
                          isLoading: false,
                          borderRadius: 10,
                          onPressed: _remove,
                          child: Text(
                            'Remove',
                            style: AppFonts.geistMono(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(width: context.responsiveWidth(0.015)),
                    Expanded(
                      child: AppButton(
                        backgroundColor: theme.secondaryColor.value,
                        isLoading: false,
                        borderRadius: 10,
                        onPressed: _apply,
                        child: Text(
                          'Apply',
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

class _TypeChoiceTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final AppThemeService theme;
  final VoidCallback onTap;

  const _TypeChoiceTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = theme.secondaryColor.value;
    return Material(
      color: isSelected ? accent.withOpacity(0.10) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? accent : ColorResources.cardBorderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? accent : Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppFonts.geistMono(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? accent : ColorResources.labelColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
