import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';
import 'package:modfirstpos/shared/widgets/dailogs/dialog_transitions.dart';

/// Cashier input for an item that does not exist in the product catalogue.
class AddCustomSaleDialog extends StatefulWidget {
  const AddCustomSaleDialog({super.key});

  static Future<void> show(BuildContext context) => showAppFadeDialog<void>(
    context,
    barrierLabel: 'Add Custom Sale',
    builder: (_) => const AddCustomSaleDialog(),
  );

  @override
  State<AddCustomSaleDialog> createState() => _AddCustomSaleDialogState();
}

class _AddCustomSaleDialogState extends State<AddCustomSaleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _titleController = TextEditingController();
  int _quantity = 1;
  bool _applyTax = false;

  @override
  void dispose() {
    _priceController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  String? _validatePrice(String? value) {
    final price = double.tryParse(value?.trim() ?? '');
    if (price == null || price <= 0) return 'Enter a valid price';
    return null;
  }

  void _addToCart() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Get.find<HomeController>().addCustomSale(
      price: double.parse(_priceController.text.trim()),
      quantity: _quantity,
      title: _titleController.text,
      applyTax: _applyTax,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final spacing = context.responsiveHeight(0.018);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: ColorResources.whiteColor,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.responsiveWidth(0.30),
        vertical: context.responsiveHeight(0.08),
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
                  'Add Custom Sale',
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
                _sectionTitle('Item Detail'),
                SizedBox(height: spacing * 0.65),
                CustomTextFormField(
                  controller: _priceController,
                  labelText: 'Price *',
                  hintText: '0.00',
                  validator: _validatePrice,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  borderRadius: 10,
                ),
                SizedBox(height: spacing),
                CustomTextFormField(
                  controller: _titleController,
                  labelText: 'Title (optional)',
                  borderRadius: 10,
                ),
                SizedBox(height: spacing * 1.15),
                _sectionTitle('Quantity'),
                SizedBox(height: spacing * 0.65),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _quantityButton(
                      icon: Icons.remove_rounded,
                      onTap: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                      color: ColorResources.gradientRed,
                    ),
                    Container(
                      width: 78,
                      height: 42,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: ColorResources.labelBorderColor,
                        ),
                      ),
                      child: Text(
                        '$_quantity',
                        style: AppFonts.geistMono(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ColorResources.labelColor,
                        ),
                      ),
                    ),
                    _quantityButton(
                      icon: Icons.add_rounded,
                      onTap: () => setState(() => _quantity++),
                      color: ColorResources.successGreen,
                    ),
                  ],
                ),
                SizedBox(height: spacing * 1.15),
                _sectionTitle('Taxes'),
                SizedBox(height: spacing * 0.35),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Charge taxes on this item',
                        style: AppFonts.geistMono(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: _applyTax,
                      activeColor: theme.secondaryColor.value,
                      onChanged: (value) => setState(() => _applyTax = value),
                    ),
                  ],
                ),
                SizedBox(height: spacing * 1.2),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        backgroundColor: theme.primaryColor.value,
                        height: 46,
                        borderRadius: 10,
                        isLoading: false,
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
                        height: 46,
                        borderRadius: 10,
                        isLoading: false,
                        onPressed: _addToCart,
                        child: const AppButtonLabel(
                          text: 'Add to Cart',
                          fontSize: 12,
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

  Widget _sectionTitle(String text) => Text(
    text,
    style: AppFonts.geistMono(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: ColorResources.labelColor,
    ),
  );

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
  }) => SizedBox(
    width: 42,
    height: 42,
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        side: BorderSide(color: color.withOpacity(0.45)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Icon(icon, size: 20, color: color),
    ),
  );
}
