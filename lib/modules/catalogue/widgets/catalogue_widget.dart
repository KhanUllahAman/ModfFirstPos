import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/catalogue/controller/catalogue_controller.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';
import 'package:modfirstpos/shared/widgets/Buttons/sync_button_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class SearchBarCatalogue extends StatelessWidget {
  final CatalogueController controller;
  const SearchBarCatalogue({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: context.responsiveHeight(0.060),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearch,
              style: AppFonts.geistMono(fontSize: context.fontSM, color: ColorResources.labelColor),
              decoration: InputDecoration(
                hintText: 'Search Category',
                hintStyle: AppFonts.geistMono(
                  fontWeight: FontWeight.w600,
                  fontSize: context.fontSM,
                  color: ColorResources.labelColor,
                ),
                suffixIcon: const Icon(Icons.search, color: ColorResources.blackColor),
                filled: true,
                fillColor: ColorResources.whiteColor,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: ColorResources.cardBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: ColorResources.cardBorderColor),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.spacingSM,
                  vertical: context.spacingXS,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Obx(() => AppSyncButton(
          onPressed: controller.syncCategories,
          isLoading: controller.isLoading.value,
          label: 'Sync Server',
        )),
      ],
    );
  }
}


class ProductGrid extends StatelessWidget {
  final CatalogueController controller;
  const ProductGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return Obx(() {
      final _ = controller.searchQuery.value;
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: theme.secondaryColor.value),
        );
      }

      final categories = controller.filteredCategories;

      if (categories.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No categories found',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  color: ColorResources.blackColor.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 12),
              AppSyncButton(
                onPressed: () => controller.loadCategories(),
                label: 'Reload Categories',
                icon: Icons.refresh_rounded,
              ),
            ],
          ),
        );
      }


      return GridView.builder(
        primary: false,
        padding: EdgeInsets.symmetric(horizontal: context.spacingSM),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (_, i) => _CategoryCard(
          category: categories[i],
          onTap: () => controller.onCategoryTap(categories[i]),
        ),
      );
    });
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    return GestureDetector(
      onTap: onTap,
      child: Obx(() => Container(
        decoration: BoxDecoration(
          color: ColorResources.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorResources.cardBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                child: category.imageUrl != null && category.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: category.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorWidget: (_, __, ___) => Container(
                          color: theme.secondaryColor.value.withOpacity(0.12),
                          child: Center(
                            child: Text(
                              category.displayName.isNotEmpty ? category.displayName[0].toUpperCase() : '?',
                              style: AppFonts.geistMono(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: theme.secondaryColor.value,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: theme.secondaryColor.value.withOpacity(0.12),
                        child: Center(
                          child: Text(
                            category.displayName.isNotEmpty ? category.displayName[0].toUpperCase() : '?',
                            style: AppFonts.geistMono(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: theme.secondaryColor.value,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                alignment: Alignment.center,
                child: Text(
                  category.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppFonts.geistMono(
                    fontSize: context.fontSM,
                    fontWeight: FontWeight.w600,
                    color: ColorResources.labelColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}