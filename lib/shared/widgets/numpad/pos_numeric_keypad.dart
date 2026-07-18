import 'package:flutter/material.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

/// Reusable POS numeric keypad (0-9, decimal, backspace + CLEAR action).
///
/// Used by the cash payment panel and the checkout split-payment entry so
/// the cashier never needs the device keyboard for amounts.
class PosNumericKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final bool showClearButton;
  final double childAspectRatio;

  const PosNumericKeypad({
    super.key,
    required this.onKeyTap,
    required this.onBackspace,
    required this.onClear,
    this.showClearButton = true,
    this.childAspectRatio = 2.1,
  });

  static const _keys = [
    '7', '8', '9',
    '4', '5', '6',
    '1', '2', '3',
    '.', '0', '⌫',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GridView.count(
          primary: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: childAspectRatio,
          children: [
            for (final key in _keys)
              PosKeypadButton(
                label: key,
                onTap: () {
                  if (key == '⌫') {
                    onBackspace();
                  } else {
                    onKeyTap(key);
                  }
                },
                onLongPress: key == '⌫' ? onClear : null,
              ),
          ],
        ),
        if (showClearButton) ...[
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            width: double.infinity,
            child: PosKeypadButton(
              label: 'CLEAR',
              isAction: true,
              onTap: onClear,
            ),
          ),
        ],
      ],
    );
  }
}

class PosKeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isAction;

  const PosKeypadButton({
    super.key,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.isAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isAction
          ? ColorResources.gradientRed.withOpacity(0.08)
          : ColorResources.whiteColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ColorResources.cardBorderColor),
          ),
          child: Text(
            label,
            style: AppFonts.geistMono(
              fontSize: context.fontMD,
              fontWeight: FontWeight.w700,
              color: isAction
                  ? ColorResources.gradientRed
                  : ColorResources.labelColor,
            ),
          ),
        ),
      ),
    );
  }
}
