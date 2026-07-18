import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/hex_color_extension.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';

/// E-commerce style variant picker: a SIZE chip row and a COLOR chip row.
///
/// Selecting a size keeps the current color when that combination exists
/// (and vice-versa); combinations that don't exist or are out of stock are
/// shown struck-through. Falls back to plain SKU chips when the backend
/// sends variants without size/color dimensions.
class VariantSelector extends StatelessWidget {
  final ProductModel product;
  final ProductVariantModel? selectedVariant;
  final ValueChanged<ProductVariantModel> onVariantSelected;

  const VariantSelector({
    super.key,
    required this.product,
    required this.selectedVariant,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    if (!product.hasVariantDimensions) {
      return _buildSkuFallback(theme);
    }

    final sizes = product.availableSizes;
    final colors = product.availableColors;
    final selectedSizeId = selectedVariant?.sizeId;
    final selectedColorId = selectedVariant?.colorId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sizes.isNotEmpty) ...[
          _sectionLabel('SIZE'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final size in sizes)
                _buildSizeChip(theme, size, selectedSizeId, selectedColorId),
            ],
          ),
          const SizedBox(height: 14),
        ],
        if (colors.isNotEmpty) ...[
          _sectionLabel('COLOR'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final color in colors)
                _buildColorChip(theme, color, selectedSizeId, selectedColorId),
            ],
          ),
        ],
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: AppFonts.geistMono(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildSizeChip(
    AppThemeService theme,
    VariantSizeModel size,
    int? selectedSizeId,
    int? selectedColorId,
  ) {
    final isSelected = size.id == selectedSizeId;
    // Best target: same color if the combo exists, otherwise any variant of
    // this size.
    final target = product.findVariant(sizeId: size.id, colorId: selectedColorId) ??
        product.findVariant(sizeId: size.id);
    final available = target != null && target.inStock;

    return _VariantChip(
      label: size.label.toUpperCase(),
      isSelected: isSelected,
      isAvailable: available,
      accent: theme.secondaryColor.value,
      onTap: target == null ? null : () => onVariantSelected(target),
    );
  }

  Widget _buildColorChip(
    AppThemeService theme,
    VariantColorModel color,
    int? selectedSizeId,
    int? selectedColorId,
  ) {
    final isSelected = color.id == selectedColorId;
    final target = product.findVariant(sizeId: selectedSizeId, colorId: color.id) ??
        product.findVariant(colorId: color.id);
    final available = target != null && target.inStock;
    final swatch = color.hexCode?.toColorOrNull();

    return _VariantChip(
      label: color.displayName.toUpperCase(),
      isSelected: isSelected,
      isAvailable: available,
      accent: theme.secondaryColor.value,
      swatchColor: swatch,
      onTap: target == null ? null : () => onVariantSelected(target),
    );
  }

  /// Old-style fallback for variants without color/size data.
  Widget _buildSkuFallback(AppThemeService theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: product.variants.map((variant) {
        final isSelected = selectedVariant?.id == variant.id;
        return _VariantChip(
          label: variant.sku ?? '--',
          isSelected: isSelected,
          isAvailable: variant.inStock,
          accent: theme.secondaryColor.value,
          onTap: () => onVariantSelected(variant),
        );
      }).toList(),
    );
  }
}

class _VariantChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isAvailable;
  final Color accent;
  final Color? swatchColor;
  final VoidCallback? onTap;

  const _VariantChip({
    required this.label,
    required this.isSelected,
    required this.isAvailable,
    required this.accent,
    this.swatchColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? accent
        : isAvailable
            ? ColorResources.cardBorderColor
            : Colors.grey[300]!;
    final textColor = !isAvailable
        ? Colors.grey[400]!
        : isSelected
            ? accent
            : ColorResources.labelColor;

    return Material(
      color: isSelected ? accent.withOpacity(0.08) : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.8 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (swatchColor != null) ...[
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: swatchColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppFonts.geistMono(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: textColor,
                  decoration:
                      isAvailable ? null : TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
