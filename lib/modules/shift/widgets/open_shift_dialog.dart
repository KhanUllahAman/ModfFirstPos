import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/bootstrap/controller/bootstrap_controller.dart';
import 'package:modfirstpos/modules/shift/controller/shift_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';
import 'package:modfirstpos/shared/widgets/dailogs/dialog_transitions.dart';

/// Mandatory shift-open dialog — shown once per app session when the
/// cashier has no active shift. No cancel button: the POS shouldn't be
/// used to sell without an open cash drawer shift.
class OpenShiftDialog extends StatefulWidget {
  const OpenShiftDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showAppFadeDialog<void>(
      context,
      barrierLabel: 'Open Shift',
      barrierDismissible: false,
      builder: (_) => const OpenShiftDialog(),
    );
  }

  @override
  State<OpenShiftDialog> createState() => _OpenShiftDialogState();
}

class _OpenShiftDialogState extends State<OpenShiftDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _openingFloatController;
  late final TextEditingController _openingNotesController;
  bool _isSyncingStoreData = false;

  @override
  void initState() {
    super.initState();
    _openingFloatController = TextEditingController();
    _openingNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _openingFloatController.dispose();
    _openingNotesController.dispose();
    super.dispose();
  }

  String? _validateOpeningFloat(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Opening float is required';
    final amount = double.tryParse(text);
    if (amount == null || amount < 0) return 'Enter a valid amount';
    return null;
  }

  Future<void> _save() async {
    final controller = Get.find<ShiftController>();
    if (controller.isOpeningShift.value ||
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await controller.openShift(
      openingFloat: double.parse(_openingFloatController.text.trim()),
      openingNotes: _openingNotesController.text.trim(),
    );

    if (!success || !mounted) return;

    setState(() => _isSyncingStoreData = true);
    await Get.find<BootstrapController>().syncBootstrap(showSnackbar: false);
    if (!mounted) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final controller = Get.find<ShiftController>();

    return PopScope(
      canPop: false,
      child: Dialog(
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
                    'Open Shift',
                    textAlign: TextAlign.center,
                    style: AppFonts.geistMono(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorResources.labelColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Enter the starting cash in the drawer to begin this shift.',
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
                    controller: _openingFloatController,
                    labelText: 'Opening Float *',
                    hintText: 'e.g. 100',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: _validateOpeningFloat,
                    borderRadius: 10,
                  ),
                  SizedBox(height: context.responsiveHeight(0.018)),
                  CustomTextFormField(
                    controller: _openingNotesController,
                    labelText: 'Opening Notes (Optional)',
                    maxLines: 2,
                    borderRadius: 10,
                  ),
                  if (_isSyncingStoreData) ...[
                    SizedBox(height: context.responsiveHeight(0.018)),
                    Text(
                      'Setting up store data...',
                      textAlign: TextAlign.center,
                      style: AppFonts.geistMono(
                        fontSize: 11,
                        color: theme.secondaryColor.value,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  SizedBox(height: context.responsiveHeight(0.028)),
                  Obx(
                    () => AppButton(
                      backgroundColor: theme.secondaryColor.value,
                      isLoading:
                          controller.isOpeningShift.value || _isSyncingStoreData,
                      borderRadius: 10,
                      onPressed: _save,
                      child: Text(
                        'Open Shift',
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
          ),
        ),
      ),
    );
  }
}
