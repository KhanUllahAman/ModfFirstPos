import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/inventory/controller/inventory_controller.dart';
import 'package:modfirstpos/modules/inventory/model/inventory_model.dart';
import 'package:modfirstpos/shared/widgets/Buttons/app_button.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/TextFormFeild/custom_text_form_field.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';
import 'package:modfirstpos/shared/widgets/sideNav/app_nav_drawer.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

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
              BackBar(title: 'Inventory'),
              SizedBox(height: context.spacingSM),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: _ProductListPane()),
                    SizedBox(width: context.responsiveWidth(0.02)),
                    Expanded(flex: 4, child: _AdjustmentPane()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).noKeyboard();
  }
}

class _PaneCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _PaneCard({required this.icon, required this.title, required this.child});

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
          Row(
            children: [
              Icon(icon, size: 20, color: ColorResources.blackColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppFonts.geistMono(
                  fontSize: context.fontMD,
                  fontWeight: FontWeight.bold,
                  color: ColorResources.labelColor,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacingMD),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ProductListPane extends GetView<InventoryController> {
  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return _PaneCard(
      icon: Icons.inventory_2_outlined,
      title: 'Products',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller.searchController,
            onChanged: controller.onSearchChanged,
            style: AppFonts.geistMono(fontSize: context.fontSM, color: ColorResources.labelColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: ColorResources.backgroundColor,
              hintText: 'Search product name / SKU',
              hintStyle: AppFonts.geistMono(fontSize: context.fontSM, color: Colors.grey[500]),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.secondaryColor.value, width: 1.5),
              ),
            ),
          ),
          SizedBox(height: context.spacingSM),
          Expanded(
            child: Obx(() {
              final products = controller.products;
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded, size: 36, color: Colors.grey[350]),
                      const SizedBox(height: 8),
                      Text(
                        'No products found',
                        style: AppFonts.geistMono(fontSize: context.fontSM, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }
              final selectedId = controller.selectedProduct.value?.id;
              return ListView.separated(
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final isSelected = product.id == selectedId;
                  final stock = product.hasVariants
                      ? product.variants.fold<int>(
                          0, (sum, v) => sum + (v.stockQuantity ?? 0))
                      : product.stock;
                  final inStock = (stock ?? 0) > 0;
                  return Material(
                    color: isSelected
                        ? theme.secondaryColor.value.withOpacity(0.12)
                        : ColorResources.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => controller.selectProduct(product),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? theme.secondaryColor.value
                                : Colors.transparent,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: ColorResources.whiteColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: ColorResources.cardBorderColor),
                              ),
                              child: Icon(
                                product.hasVariants
                                    ? Icons.style_outlined
                                    : Icons.inventory_2_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFonts.geistMono(
                                      fontSize: context.fontSM,
                                      fontWeight: FontWeight.w600,
                                      color: ColorResources.labelColor,
                                    ),
                                  ),
                                  if (product.sku != null)
                                    Text(
                                      product.sku!,
                                      style: AppFonts.geistMono(fontSize: 10, color: Colors.grey[600]),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: inStock
                                    ? ColorResources.successGreen.withOpacity(0.14)
                                    : ColorResources.gradientRed.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${stock ?? '--'}',
                                style: AppFonts.geistMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: inStock
                                      ? ColorResources.successGreen
                                      : ColorResources.gradientRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AdjustmentPane extends GetView<InventoryController> {
  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return _PaneCard(
      icon: Icons.tune_rounded,
      title: 'Adjust Stock',
      child: Obx(() {
        final product = controller.selectedProduct.value;
        if (product == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_outlined, size: 36, color: Colors.grey[350]),
                const SizedBox(height: 8),
                Text(
                  'Select a product to adjust stock',
                  textAlign: TextAlign.center,
                  style: AppFonts.geistMono(fontSize: context.fontSM, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                product.displayName,
                style: AppFonts.geistMono(
                  fontSize: context.fontMD,
                  fontWeight: FontWeight.w700,
                  color: ColorResources.labelColor,
                ),
              ),
              SizedBox(height: context.spacingSM),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.secondaryColor.value.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warehouse_outlined, size: 18, color: theme.secondaryColor.value),
                    const SizedBox(width: 8),
                    Text(
                      'Current Stock',
                      style: AppFonts.geistMono(
                        fontSize: context.fontXS,
                        fontWeight: FontWeight.w600,
                        color: ColorResources.labelColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${controller.currentStock ?? '--'}',
                      style: AppFonts.geistMono(
                        fontSize: context.fontMD,
                        fontWeight: FontWeight.w800,
                        color: theme.secondaryColor.value,
                      ),
                    ),
                  ],
                ),
              ),
              if (product.hasVariants) ...[
                SizedBox(height: context.spacingMD),
                Text(
                  'Variant',
                  style: AppFonts.geistMono(fontSize: context.fontXS, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: product.variants.map((v) {
                    final isSelected = controller.selectedVariant.value?.id == v.id;
                    final label = [v.color?.displayName, v.size?.label]
                        .where((e) => e != null)
                        .join(' / ');
                    return ChoiceChip(
                      label: Text(
                        label.isEmpty ? (v.sku ?? 'Variant #${v.id}') : label,
                        style: AppFonts.geistMono(
                          fontSize: 11,
                          color: isSelected ? Colors.white : ColorResources.labelColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selected: isSelected,
                      backgroundColor: ColorResources.backgroundColor,
                      selectedColor: theme.secondaryColor.value,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                      onSelected: (_) => controller.selectVariant(v),
                    );
                  }).toList(),
                ),
              ],
              SizedBox(height: context.spacingMD),
              Text(
                'Action',
                style: AppFonts.geistMono(fontSize: context.fontXS, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ColorResources.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: InventoryAction.values.map((a) {
                    final isSelected = controller.action.value == a;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectAction(a),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.secondaryColor.value : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _actionLabel(a),
                            textAlign: TextAlign.center,
                            style: AppFonts.geistMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : ColorResources.labelColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: context.spacingMD),
              CustomTextFormField(
                controller: controller.quantityController,
                labelText: controller.action.value == InventoryAction.adjust
                    ? 'New Quantity *'
                    : 'Quantity *',
                keyboardType: TextInputType.number,
                borderRadius: 10,
                customFocusedBorderColor: theme.secondaryColor.value,
              ),
              if (controller.action.value != InventoryAction.adjust) ...[
                SizedBox(height: context.spacingMD),
                Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: theme.secondaryColor.value,
                        ),
                    canvasColor: ColorResources.whiteColor,
                  ),
                  child: DropdownButtonFormField<InventoryReason>(
                    value: controller.reason.value,
                    dropdownColor: ColorResources.whiteColor,
                    style: AppFonts.geistMono(fontSize: context.fontSM, color: ColorResources.labelColor),
                    decoration: InputDecoration(
                      labelText: 'Reason',
                      labelStyle: AppFonts.geistMono(fontSize: context.fontXS, color: Colors.grey[600]),
                      filled: true,
                      fillColor: ColorResources.whiteColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: ColorResources.cardBorderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: ColorResources.cardBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: theme.secondaryColor.value, width: 1.5),
                      ),
                    ),
                    items: InventoryReason.values
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r.label, style: AppFonts.geistMono(fontSize: context.fontSM)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) controller.reason.value = val;
                    },
                  ),
                ),
              ],
              SizedBox(height: context.spacingMD),
              CustomTextFormField(
                controller: controller.notesController,
                labelText: 'Notes (Optional)',
                maxLines: 2,
                borderRadius: 10,
                customFocusedBorderColor: theme.secondaryColor.value,
              ),
              SizedBox(height: context.spacingMD),
              AppButton(
                backgroundColor: theme.secondaryColor.value,
                isLoading: controller.isSubmitting.value,
                borderRadius: 10,
                onPressed: controller.submit,
                child: Text(
                  _submitLabel(controller.action.value),
                  style: AppFonts.geistMono(
                    color: theme.onSecondaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _actionLabel(InventoryAction a) {
    switch (a) {
      case InventoryAction.increase:
        return 'Increase';
      case InventoryAction.decrease:
        return 'Decrease';
      case InventoryAction.adjust:
        return 'Adjust';
    }
  }

  String _submitLabel(InventoryAction a) {
    switch (a) {
      case InventoryAction.increase:
        return 'Increase Stock';
      case InventoryAction.decrease:
        return 'Decrease Stock';
      case InventoryAction.adjust:
        return 'Set Stock';
    }
  }
}
