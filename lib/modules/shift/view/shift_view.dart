import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/bootstrap/controller/bootstrap_controller.dart';
import 'package:modfirstpos/modules/shift/controller/shift_controller.dart';
import 'package:modfirstpos/modules/shift/model/shift_model.dart';
import 'package:modfirstpos/modules/shift/widgets/close_shift_dialog.dart';
import 'package:modfirstpos/modules/shift/widgets/open_shift_dialog.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';
import 'package:modfirstpos/shared/widgets/sideNav/app_nav_drawer.dart';

class ShiftView extends GetView<ShiftController> {
  const ShiftView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(),
      drawer: const AppNavDrawer(),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Padding(
          padding: EdgeInsets.all(context.responsiveWidth(0.02)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: BackBar(title: 'Shift')),
                  Obx(
                    () => IconButton(
                      onPressed: Get.find<BootstrapController>().isSyncing.value
                          ? null
                          : () => Get.find<BootstrapController>().syncBootstrap(),
                      icon: Get.find<BootstrapController>().isSyncing.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync_rounded),
                      tooltip: 'Sync store data',
                    ),
                  ),
                  Obx(
                    () => IconButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.checkCurrentShift,
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Refresh shift',
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacingSM),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.currentShift.value == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final shift = controller.currentShift.value;
                  if (shift == null) {
                    return _NoActiveShiftState(context: context);
                  }

                  return _ActiveShiftDetails(shift: shift);
                }),
              ),
            ],
          ),
        ),
      ),
    ).noKeyboard();
  }
}

class _NoActiveShiftState extends StatelessWidget {
  final BuildContext context;
  const _NoActiveShiftState({required this.context});

  @override
  Widget build(BuildContext ctx) {
    final theme = Get.find<AppThemeService>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.point_of_sale_rounded, size: 64, color: Colors.grey[300]),
          SizedBox(height: context.spacingSM),
          Text(
            'No Active Shift',
            style: AppFonts.geistMono(
              fontSize: context.fontMD,
              fontWeight: FontWeight.w700,
              color: ColorResources.labelColor,
            ),
          ),
          SizedBox(height: context.spacingXS),
          Text(
            'Open a shift to start taking sales.',
            style: AppFonts.geistMono(
              fontSize: context.fontXS,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: context.spacingMD),
          SizedBox(
            width: context.responsiveWidth(0.2),
            child: AppButton(
              backgroundColor: theme.secondaryColor.value,
              isLoading: false,
              borderRadius: 10,
              onPressed: () => OpenShiftDialog.show(ctx),
              child: Text(
                'Open Shift',
                style: AppFonts.geistMono(
                  color: theme.onSecondaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveShiftDetails extends StatelessWidget {
  final ShiftModel shift;
  const _ActiveShiftDetails({required this.shift});

  Color _statusColor() {
    if (shift.isOpen) return ColorResources.successGreen;
    if (shift.isPaused) return ColorResources.warningOrange;
    return ColorResources.greyColor;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShiftController>();
    final totals = shift.totals;
    final currency = shift.websiteSetting?.currencySymbol ?? '\$';

    return ListView(
      primary: false,
      children: [
        Container(
          padding: EdgeInsets.all(context.spacingMD),
          decoration: BoxDecoration(
            color: ColorResources.whiteColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorResources.cardBorderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    shift.shiftCode,
                    style: AppFonts.geistMono(
                      fontSize: context.fontSM,
                      fontWeight: FontWeight.w700,
                      color: ColorResources.labelColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor().withOpacity(0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      shift.statusLabel ?? shift.status,
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        fontWeight: FontWeight.w700,
                        color: _statusColor(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacingSM),
              if (shift.branch?.name != null) _InfoRow('Branch', shift.branch!.name!),
              if (shift.posDevice?.name != null) _InfoRow('Device', shift.posDevice!.name!),
              _InfoRow('Opening Float', '$currency${shift.openingFloat.toStringAsFixed(2)}'),
              if (shift.openedAt != null) _InfoRow('Opened At', shift.openedAt!),
              if (shift.openingNotes != null && shift.openingNotes!.isNotEmpty)
                _InfoRow('Notes', shift.openingNotes!),
            ],
          ),
        ),
        SizedBox(height: context.spacingSM),
        if (totals != null) ...[
          _SectionCard(
            title: 'Orders',
            rows: [
              _InfoRow('Total', '${totals.orders.total}'),
              _InfoRow('Completed', '${totals.orders.completed}'),
              _InfoRow('Cancelled', '${totals.orders.cancelled}'),
            ],
          ),
          SizedBox(height: context.spacingSM),
          _SectionCard(
            title: 'Sales',
            rows: [
              _InfoRow('Gross Sales', '$currency${totals.sales.grossSales}'),
              _InfoRow('Net Sales', '$currency${totals.sales.netSales}'),
              _InfoRow('Collected', '$currency${totals.sales.collected}'),
              _InfoRow('Outstanding', '$currency${totals.sales.outstanding}'),
              _InfoRow('Cash Collected', '$currency${totals.cashCollected ?? '0.00'}'),
            ],
          ),
          SizedBox(height: context.spacingSM),
        ],
        Obx(
          () => Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      backgroundColor: ColorResources.warningOrange,
                      isLoading: controller.isUpdatingStatus.value,
                      borderRadius: 10,
                      onPressed: shift.isOpen
                          ? controller.pauseShift
                          : controller.resumeShift,
                      child: Text(
                        shift.isOpen ? 'Pause Shift' : 'Resume Shift',
                        style: AppFonts.geistMono(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: context.fontXS,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.spacingSM),
                  Expanded(
                    child: AppButton(
                      backgroundColor: ColorResources.gradientRed,
                      isLoading: false,
                      borderRadius: 10,
                      onPressed: () => CloseShiftDialog.show(context),
                      child: Text(
                        'Close Shift',
                        style: AppFonts.geistMono(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: context.fontXS,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.spacingSM),
              AppButton(
                backgroundColor: ColorResources.blackColor,
                isLoading: controller.isPrinting.value,
                borderRadius: 10,
                onPressed: controller.printReceipt,
                child: Text(
                  'Print Shift Receipt',
                  style: AppFonts.geistMono(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: context.fontXS,
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

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _SectionCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacingMD),
      decoration: BoxDecoration(
        color: ColorResources.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorResources.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppFonts.geistMono(
              fontSize: context.fontSM,
              fontWeight: FontWeight.w700,
              color: ColorResources.labelColor,
            ),
          ),
          SizedBox(height: context.spacingXS),
          ...rows,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppFonts.geistMono(fontSize: 11, color: Colors.grey[600]),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppFonts.geistMono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ColorResources.labelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
