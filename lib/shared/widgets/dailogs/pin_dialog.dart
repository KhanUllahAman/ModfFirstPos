import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';

class PinDialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color? cursorColor;
  final Color? selectionHandleColor;

  const PinDialogField({
    super.key,
    required this.controller,
    required this.label,
    this.cursorColor,
    this.selectionHandleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Obx(() {
      final accentColor = cursorColor ?? theme.secondaryColor.value;
      final handleColor = selectionHandleColor ?? theme.secondaryColor.value;
      final focusBorderColor = theme.primaryColor.value;

      return Padding(
        padding: EdgeInsets.only(bottom: context.spacingMD),
        child: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionHandleColor: handleColor,
              cursorColor: accentColor,
              selectionColor: accentColor.withOpacity(0.3),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: true,
            maxLength: 4,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppFonts.geistMono(
              fontSize: context.fontSM,
              fontWeight: FontWeight.w600,
              letterSpacing: 4,
            ),
            cursorColor: accentColor,
            decoration: InputDecoration(
              counterText: '',
              labelText: label,
              labelStyle: AppFonts.geistMono(
                fontSize: context.fontXS,
                color: ColorResources.blackColor.withOpacity(0.5),
              ),
              filled: true,
              fillColor: const Color(0xFFF4F5F8),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE7E9F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: focusBorderColor, // ← black (ya theme.primaryColor)
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Reusable stylish dialog shell
/// Reusable stylish dialog shell
class PinActionDialog extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> fields;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final bool isDestructive;

  const PinActionDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.confirmLabel,
    required this.onConfirm,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Obx(() {
      final accentColor = isDestructive
          ? Colors.red
          : theme.secondaryColor.value;
      final confirmBg = isDestructive ? Colors.red : theme.primaryColor.value;
      final confirmTextColor = confirmBg.computeLuminance() > 0.5
          ? Colors.black
          : Colors.white;

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(0.08),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 380,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.spacingLG),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.1),
                    ),
                    child: Icon(icon, color: accentColor, size: 26),
                  ),
                  SizedBox(height: context.spacingMD),
                  Text(
                    title,
                    style: AppFonts.geistMono(
                      fontSize: context.fontMD,
                      fontWeight: FontWeight.w600,
                      color: ColorResources.blackColor,
                    ),
                  ),
                  SizedBox(height: context.spacingXS),
                  Text(
                    subtitle,
                    style: AppFonts.geistMono(
                      fontSize: context.fontXS,
                      color: ColorResources.blackColor.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: context.spacingLG),
                  ...fields,
                  SizedBox(height: context.spacingXS),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: context.spacingSM,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFE7E9F0)),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: AppFonts.geistMono(
                              fontSize: context.fontXS,
                              fontWeight: FontWeight.w500,
                              color: ColorResources.blackColor.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.spacingSM),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: confirmBg,
                            padding: EdgeInsets.symmetric(
                              vertical: context.spacingSM,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            confirmLabel,
                            style: AppFonts.geistMono(
                              fontSize: context.fontXS,
                              fontWeight: FontWeight.w600,
                              color: confirmTextColor,
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
    });
  }
}
