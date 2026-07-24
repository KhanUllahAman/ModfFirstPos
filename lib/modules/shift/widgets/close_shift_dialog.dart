import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/shift/controller/shift_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';
import 'package:modfirstpos/shared/widgets/dailogs/dialog_transitions.dart';

class CloseShiftDialog extends StatefulWidget {
  const CloseShiftDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showAppFadeDialog<void>(
      context,
      barrierLabel: 'Close Shift',
      builder: (_) => const CloseShiftDialog(),
    );
  }

  @override
  State<CloseShiftDialog> createState() => _CloseShiftDialogState();
}

class _CloseShiftDialogState extends State<CloseShiftDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _countedCashController;
  late final TextEditingController _closingNotesController;

  @override
  void initState() {
    super.initState();
    _countedCashController = TextEditingController();
    _closingNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _countedCashController.dispose();
    _closingNotesController.dispose();
    super.dispose();
  }

  String? _validateCountedCash(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Counted cash is required';
    final amount = double.tryParse(text);
    if (amount == null || amount < 0) return 'Enter a valid amount';
    return null;
  }

  Future<void> _save() async {
    final controller = Get.find<ShiftController>();
    if (controller.isClosingShift.value ||
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await controller.closeShift(
      countedCash: double.parse(_countedCashController.text.trim()),
      closingNotes: _closingNotesController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final controller = Get.find<ShiftController>();

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
                  'Close Shift',
                  textAlign: TextAlign.center,
                  style: AppFonts.geistMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorResources.labelColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Count the cash in the drawer and enter it below.',
                  textAlign: TextAlign.center,
                  style: AppFonts.geistMono(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                Divider(
                  height: context.responsiveHeight(0.03),
                  color: ColorResources.cardBorderColor,
                ),
                CustomTextFormField(
                  controller: _countedCashController,
                  labelText: 'Counted Cash *',
                  hintText: 'e.g. 100',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateCountedCash,
                  borderRadius: 10,
                ),
                SizedBox(height: context.responsiveHeight(0.018)),
                CustomTextFormField(
                  controller: _closingNotesController,
                  labelText: 'Closing Notes (Optional)',
                  maxLines: 2,
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
                          onPressed: controller.isClosingShift.value
                              ? () {}
                              : () => Navigator.of(context).pop(),
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
                          isLoading: controller.isClosingShift.value,
                          borderRadius: 10,
                          onPressed: _save,
                          child: Text(
                            'Close Shift',
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
