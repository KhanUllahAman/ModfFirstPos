import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

/// In-place cash payment terminal shown on the POS home screen.
///
/// A custom on-screen keypad (no device keyboard) with quick amounts,
/// exact cash, live change calculation, confirm and cancel.
class CashPaymentPanel extends StatelessWidget {
  final HomeController controller;
  const CashPaymentPanel({super.key, required this.controller});

  static const _quickAmounts = <double>[100, 500, 1000, 5000];

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: ColorResources.blackColor,
              ),
              onPressed: controller.closeCashPayment,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'CASH PAYMENT',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w700,
                  color: ColorResources.labelColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsiveHeight(0.008)),
        // Amount display + totals
        Obx(() {
          final received = controller.cashReceivedInput.value;
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveWidth(0.015),
              vertical: context.responsiveHeight(0.014),
            ),
            decoration: BoxDecoration(
              color: ColorResources.whiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorResources.cardBorderColor),
            ),
            child: Column(
              children: [
                _AmountRow(
                  label: 'Payable',
                  value: 'Rs. ${controller.balance.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Received',
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      received.isEmpty ? '0' : received,
                      style: AppFonts.geistMono(
                        fontSize: context.fontLG,
                        fontWeight: FontWeight.w800,
                        color: theme.secondaryColor.value,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _AmountRow(
                  label: 'Change',
                  value: 'Rs. ${controller.changeDue.toStringAsFixed(2)}',
                  emphasized: controller.changeDue > 0,
                ),
              ],
            ),
          );
        }),
        SizedBox(height: context.responsiveHeight(0.012)),
        // Quick amounts + exact cash
        Row(
          children: [
            for (final amount in _quickAmounts) ...[
              Expanded(
                child: _QuickAmountChip(
                  label: amount.toStringAsFixed(0),
                  onTap: () => controller.addQuickAmount(amount),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              flex: 2,
              child: _QuickAmountChip(
                label: 'EXACT',
                highlighted: true,
                onTap: controller.setExactCash,
              ),
            ),
          ],
        ),
        SizedBox(height: context.responsiveHeight(0.012)),
        // Keypad
        Expanded(
          child: _CashKeypad(controller: controller),
        ),
        SizedBox(height: context.responsiveHeight(0.012)),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: AppButton(
                  backgroundColor: theme.primaryColor.value,
                  isLoading: false,
                  borderRadius: 10,
                  onPressed: controller.closeCashPayment,
                  child: Text(
                    'Cancel',
                    style: AppFonts.geistMono(
                      fontSize: context.fontSM,
                      fontWeight: FontWeight.w600,
                      color: theme.onPrimaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.responsiveWidth(0.012)),
              Expanded(
                flex: 2,
                child: AppButton(
                  backgroundColor: controller.canConfirmCashPayment
                      ? ColorResources.successGreen
                      : ColorResources.greyColor,
                  isLoading: false,
                  borderRadius: 10,
                  onPressed: controller.confirmCashPayment,
                  child: Text(
                    'Confirm Payment',
                    style: AppFonts.geistMono(
                      fontSize: context.fontSM,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _AmountRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFonts.geistMono(
            fontSize: context.fontXS,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: AppFonts.geistMono(
            fontSize: context.fontSM,
            fontWeight: FontWeight.w700,
            color: emphasized
                ? ColorResources.successGreen
                : ColorResources.labelColor,
          ),
        ),
      ],
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  final String label;
  final bool highlighted;
  final VoidCallback onTap;

  const _QuickAmountChip({
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(() {
      final accent = theme.secondaryColor.value;
      return Material(
        color: highlighted ? accent : accent.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              style: AppFonts.geistMono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: highlighted ? theme.onSecondaryColor : accent,
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _CashKeypad extends StatelessWidget {
  final HomeController controller;
  const _CashKeypad({required this.controller});

  static const _keys = [
    '7', '8', '9',
    '4', '5', '6',
    '1', '2', '3',
    '.', '0', '⌫',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            primary: false,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 2.1,
            children: [
              for (final key in _keys)
                _KeypadButton(
                  label: key,
                  onTap: () {
                    if (key == '⌫') {
                      controller.keypadBackspace();
                    } else {
                      controller.keypadAppend(key);
                    }
                  },
                  onLongPress: key == '⌫' ? controller.keypadClear : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: _KeypadButton(
            label: 'CLEAR',
            isAction: true,
            onTap: controller.keypadClear,
          ),
        ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isAction;

  const _KeypadButton({
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
