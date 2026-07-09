import 'package:flutter/material.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class PinDotsIndicator extends StatelessWidget {
  final int enteredLength;
  final int maxLength;
  final Color? activeColor;
  final Color? inactiveColor;

  const PinDotsIndicator({
    super.key,
    required this.enteredLength,
    this.maxLength = 6,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLength, (index) {
        final filled = index < enteredLength;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 7),
          width: filled ? 14 : 12,
          height: filled ? 14 : 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled
                ? (activeColor ?? ColorResources.appMainColor)
                : Colors.transparent,
            border: Border.all(
              color: filled
                  ? (activeColor ?? ColorResources.appMainColor)
                  : (inactiveColor ?? Colors.grey.withOpacity(0.4)),
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}

/// 3x4 numpad grid — 1-9, empty, 0, backspace
/// Size ab screen-width % ki bajaye ek clamp range mein fixed hai,
/// taake tablets/bade screens pe buttons overgrown na hon.
class PinNumpad extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspacePressed;
  final Color? digitColor;
  final Color? buttonFillColor;
  final Color? buttonBorderColor;

  const PinNumpad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspacePressed,
    this.digitColor,
    this.buttonFillColor,
    this.buttonBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = context.responsiveWidth(0.16).clamp(58.0, 74.0);

    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) {
                return SizedBox(width: buttonSize, height: buttonSize);
              }
              if (key == 'back') {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _NumpadButton(
                    size: buttonSize,
                    fillColor: Colors.transparent,
                    borderColor: Colors.transparent,
                    onTap: onBackspacePressed,
                    child: Icon(
                      Icons.backspace_outlined,
                      color: (digitColor ?? Colors.white).withOpacity(0.85),
                      size: buttonSize * 0.32,
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _NumpadButton(
                  size: buttonSize,
                  fillColor: buttonFillColor,
                  borderColor: buttonBorderColor,
                  onTap: () => onDigitPressed(key),
                  child: Text(
                    key,
                    style: AppFonts.geistMono(
                      fontSize: buttonSize * 0.32,
                      fontWeight: FontWeight.w600,
                      color: digitColor ?? Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double size;
  final Color? fillColor;
  final Color? borderColor;

  const _NumpadButton({
    required this.child,
    required this.onTap,
    required this.size,
    this.fillColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: fillColor ?? Colors.white.withOpacity(0.08),
      shape: CircleBorder(
        side: BorderSide(
          color: borderColor ?? Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        splashColor: ColorResources.appMainColor.withOpacity(0.25),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}
