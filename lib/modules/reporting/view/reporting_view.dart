import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/reporting/controller/reporting_controller.dart';
import 'package:modfirstpos/shared/widgets/CircularProgressIndicator/circular_progress_indicator.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/sideNav/app_nav_drawer.dart';

class ReportingView extends GetView<ReportingController> {
  const ReportingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(),
      drawer: const AppNavDrawer(),
      body: Padding(
        padding: EdgeInsets.all(context.responsiveWidth(0.02)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BackBar(title: 'Reporting'),
            SizedBox(height: context.spacingSM),
            _buildFiltersCard(context),
            SizedBox(height: context.spacingSM),
            Expanded(child: Obx(() => _buildPreviewArea(context))),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersCard(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Container(
      padding: EdgeInsets.all(context.spacingMD),
      decoration: BoxDecoration(
        color: ColorResources.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorResources.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duration Report',
            style: AppFonts.geistMono(
              fontSize: context.fontMD,
              fontWeight: FontWeight.w700,
              color: ColorResources.labelColor,
            ),
          ),
          SizedBox(height: context.spacingSM),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildPeriodDropdown(context),
              _buildSortByDropdown(context),
              _buildSortOrderDropdown(context),
            ],
          ),
          Obx(() {
            if (!controller.isCustomPeriod) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: context.spacingSM),
              child: Row(
                children: [
                  Expanded(child: _buildDatePicker(context, isStart: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDatePicker(context, isStart: false)),
                ],
              ),
            );
          }),
          SizedBox(height: context.spacingMD),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isGenerating.value
                          ? null
                          : controller.generateReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor.value,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: theme.secondaryColor.value
                            .withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isGenerating.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularLoaderWidget(
                                size: 20,
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              'GENERATE REPORT',
                              style: AppFonts.geistMono(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              Obx(() {
                if (!controller.hasReport.value) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.downloadReport,
                      icon: controller.isSaving.value
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularLoaderWidget(
                                size: 16,
                                strokeWidth: 2,
                                color: theme.secondaryColor.value,
                              ),
                            )
                          : const Icon(Icons.download_rounded, size: 18),
                      label: Text(
                        'DOWNLOAD',
                        style: AppFonts.geistMono(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: ColorResources.cardBorderColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: ColorResources.labelColor,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _themedDropdown<T>({
    required BuildContext context,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String label,
  }) {
    final theme = Get.find<AppThemeService>();
    final accent = theme.secondaryColor.value;
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(primary: accent, secondary: accent),
        splashColor: accent.withOpacity(0.1),
        highlightColor: accent.withOpacity(0.1),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        dropdownColor: ColorResources.whiteColor,
        isExpanded: true,
        focusColor: Colors.transparent,
        decoration: _fieldDecoration(label, accent),
        style: AppFonts.geistMono(
          fontSize: context.fontXS,
          color: ColorResources.labelColor,
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildPeriodDropdown(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Obx(
        () => _themedDropdown<String>(
          context: context,
          value: controller.selectedPeriod.value,
          label: 'Period',
          items: controller.periodOptions
              .map(
                (o) => DropdownMenuItem(
                  value: o['value'],
                  child: Text(
                    o['label']!,
                    style: AppFonts.geistMono(fontSize: context.fontXS),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) controller.selectPeriod(val);
          },
        ),
      ),
    );
  }

  Widget _buildSortByDropdown(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Obx(
        () => _themedDropdown<String>(
          context: context,
          value: controller.sortBy.value,
          label: 'Sort By',
          items: controller.sortByOptions
              .map(
                (o) => DropdownMenuItem(
                  value: o['value'],
                  child: Text(
                    o['label']!,
                    style: AppFonts.geistMono(fontSize: context.fontXS),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) controller.selectSortBy(val);
          },
        ),
      ),
    );
  }

  Widget _buildSortOrderDropdown(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Obx(
        () => _themedDropdown<String>(
          context: context,
          value: controller.sortOrder.value,
          label: 'Order',
          items: const [
            DropdownMenuItem(value: 'asc', child: Text('Ascending')),
            DropdownMenuItem(value: 'desc', child: Text('Descending')),
          ],
          onChanged: (val) {
            if (val != null) controller.selectSortOrder(val);
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, {required bool isStart}) {
    final theme = Get.find<AppThemeService>();
    return Obx(() {
      final date = isStart
          ? controller.startDate.value
          : controller.endDate.value;
      return InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            builder: (ctx, child) => Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: Theme.of(
                  ctx,
                ).colorScheme.copyWith(primary: theme.secondaryColor.value),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            if (isStart) {
              controller.setStartDate(picked);
            } else {
              controller.setEndDate(picked);
            }
          }
        },
        child: InputDecorator(
          decoration: _fieldDecoration(
            isStart ? 'Start Date' : 'End Date',
            theme.secondaryColor.value,
          ),
          child: Text(
            date != null ? DateFormat('yyyy-MM-dd').format(date) : 'Select',
            style: AppFonts.geistMono(
              fontSize: context.fontXS,
              color: ColorResources.labelColor,
            ),
          ),
        ),
      );
    });
  }

  InputDecoration _fieldDecoration(String label, Color accent) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppFonts.geistMono(
        fontSize: 10,
        color: ColorResources.labelColor,
      ),
      filled: true,
      fillColor: ColorResources.whiteColor,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorResources.cardBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorResources.cardBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accent, width: 1.5),
      ),
    );
  }

  Widget _buildPreviewArea(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    if (controller.isGenerating.value) {
      return Center(
        child: CircularLoaderWidget(
          size: 44,
          color: theme.secondaryColor.value,
          backgroundColor: theme.secondaryColor.value,
        ),
      );
    }
    if (!controller.hasReport.value) {
      return Center(
        child: Text(
          'Generate a report to preview it here',
          style: AppFonts.geistMono(
            fontSize: context.fontSM,
            color: Colors.grey[500],
          ),
        ),
      );
    }
    if (controller.previewHeaders.isEmpty) {
      return Center(
        child: Text(
          'No rows found in the report',
          style: AppFonts.geistMono(
            fontSize: context.fontSM,
            color: Colors.grey[500],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorResources.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorResources.cardBorderColor),
      ),
      padding: EdgeInsets.all(context.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.sheetNames.length > 1) ...[
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.sheetNames.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final name = controller.sheetNames[i];
                  final isActive = controller.activeSheet.value == name;
                  return ChoiceChip(
                    iconTheme: IconThemeData(color: theme.onPrimaryColor),
                    label: Text(
                      name,
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? theme.onPrimaryColor
                            : ColorResources.blackColor,
                      ),
                    ),
                    selected: isActive,
                    selectedColor: theme.primaryColor.value,
                    backgroundColor: ColorResources.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isActive
                            ? Colors.transparent
                            : ColorResources.cardBorderColor,
                      ),
                    ),
                    onSelected: (_) => controller.selectSheet(name),
                  );
                },
              ),
            ),
            SizedBox(height: context.spacingSM),
          ],
          Row(
            children: [
              Icon(Icons.swipe_rounded, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                'Scroll horizontally / vertically to see all columns and rows',
                style: AppFonts.geistMono(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacingXS),
          Expanded(
            child: Scrollbar(
              controller: controller.verticalTableScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: controller.verticalTableScrollController,
                child: Scrollbar(
                  controller: controller.horizontalTableScrollController,
                  thumbVisibility: true,
                  notificationPredicate: (notif) => true,
                  child: SingleChildScrollView(
                    controller: controller.horizontalTableScrollController,
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        ColorResources.backgroundColor.withOpacity(0.5),
                      ),
                      columns: controller.previewHeaders
                          .map(
                            (h) => DataColumn(
                              label: Text(
                                h,
                                style: AppFonts.geistMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: ColorResources.labelColor,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      rows: controller.previewRows
                          .map(
                            (row) => DataRow(
                              cells: List.generate(
                                controller.previewHeaders.length,
                                (i) => DataCell(
                                  Text(
                                    i < row.length ? row[i] : '',
                                    style: AppFonts.geistMono(fontSize: 11),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
