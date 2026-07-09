import 'package:flutter/material.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/utils/colors.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool isPasswordField;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final TextInputType keyboardType;
  final int maxLines;
  final bool expands;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? hintText;
  final double borderRadius;
  final Color? customFocusedBorderColor;
  final Color? customEnabledBorderColor;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.obscureText = false,
    this.isPasswordField = false,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.expands = false,
    this.readOnly = false,
    this.onTap,
    this.hintText,
    this.borderRadius = 14.0,
    this.customFocusedBorderColor,
    this.customEnabledBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final focusColor = customFocusedBorderColor ?? ColorResources.appMainColor;
    final textColor = ColorResources.labelColor;
    final labelColor = ColorResources.labelColor;

    final borderColor = ColorResources.labelBorderColor;
    final fillColor = Colors.transparent;

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: focusColor,
          selectionColor: focusColor.withAlpha(60),
          cursorColor: focusColor,
        ),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        expands: expands,
        readOnly: readOnly,
        onTap: onTap,
        style: AppFonts.geistMono(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        cursorColor: focusColor,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          suffixIcon: _buildSuffixIcon(context),
          labelStyle: AppFonts.geistMono(fontSize: 13, color: labelColor),
          floatingLabelStyle: AppFonts.geistMono(
            fontSize: 13,
            color: focusColor,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: focusColor, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: ColorResources.gradientRed),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(
              color: ColorResources.gradientRed,
              width: 2.0,
            ),
          ),
          fillColor: fillColor,
          filled: true,
          errorStyle: AppFonts.geistMono(
            color: ColorResources.gradientRed,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    final iconColor = ColorResources.labelColor;

    if (isPasswordField) {
      return IconButton(
        onPressed: onSuffixIconPressed,
        icon: Icon(
          obscureText ? Iconsax.eye_slash : Iconsax.eye,
          color: iconColor,
          size: 20,
        ),
      );
    } else if (suffixIcon != null) {
      return IconButton(
        onPressed: onSuffixIconPressed,
        icon: Icon(suffixIcon, color: iconColor, size: 20),
      );
    }
    return null;
  }
}
