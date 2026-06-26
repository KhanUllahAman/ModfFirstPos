import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ScreenSize/screen_size_utils.dart';
import '../../../core/utils/colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.backgroundColor, 
    required this.onPressed,
    required this.child,
    required this.isLoading,
    this.height,
    this.borderRadius = 12.0,
  });

  final Color? backgroundColor;
  final VoidCallback onPressed;
  final Widget child;
  final bool isLoading;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final btnHeight = height ?? context.responsiveHeight(0.065);
    final radius = BorderRadius.circular(borderRadius);
    final useGradient = backgroundColor == null && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: btnHeight,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            gradient: useGradient ? ColorResources.appGradient : null,
            color: isLoading
                ? ColorResources.greyColor
                : backgroundColor, // solid color jab diya ho
            borderRadius: radius,
          ),
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: radius,
            splashColor: Colors.white.withOpacity(0.15),
            highlightColor: Colors.white.withOpacity(0.08),
            child: Container(
              alignment: Alignment.center,
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience text button used inside AppButton
class AppButtonLabel extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight fontWeight;

  const AppButtonLabel({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.geistMono(
        fontSize: fontSize ?? context.fontMD,
        fontWeight: fontWeight,
        color: Colors.white,
        letterSpacing: 0.3,
      ),
    );
  }
}
