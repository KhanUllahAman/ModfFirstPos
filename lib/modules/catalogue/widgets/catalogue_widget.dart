import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/images_constant.dart';
import 'package:modfirstpos/modules/catalogue/controller/catalogue_controller.dart';
import 'package:modfirstpos/modules/home/model/product_item.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class SearchBarCatalogue extends StatelessWidget {
  final CatalogueController controller;
  const SearchBarCatalogue({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.responsiveHeight(0.060),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearch,
        style: GoogleFonts.geistMono(
          fontSize: context.fontSM,
          color: ColorResources.labelColor,
        ),
        decoration: InputDecoration(
          hintText: 'Search Product',
          hintStyle: GoogleFonts.geistMono(
            fontWeight: FontWeight.w600,
            fontSize: context.fontSM,
            color: ColorResources.labelColor,
          ),
          suffixIcon: Icon(
            Iconsax.search_favorite,
            size: context.fontLG,
            color: ColorResources.blackColor,
          ),
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
    );
  }
}

class ProductGrid extends StatelessWidget {
  final CatalogueController controller;
  const ProductGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: ColorResources.appMainColor,
            strokeWidth: 1.5,
          ),
        );
      }

      final products = controller.filteredProducts;

      if (products.isEmpty) {
        return Center(
          child: Text(
            'No products found',
            style: GoogleFonts.geistMono(
              fontSize: context.fontSM,
              color: ColorResources.blackColor.withOpacity(0.5),
            ),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: context.spacingSM),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (_, i) => _ProductCard(
            product: products[i],
            onAddToCart: () => controller.addToCart(products[i]),
            onPinnedListAdd: () => controller.onProductTap(products[i]),
          ),
        ),
      );
    });
  }
}

class _ProductCard extends StatelessWidget {
  final ProductItem product;
  final VoidCallback onAddToCart;
  final VoidCallback onPinnedListAdd;

  const _ProductCard({
    required this.product,
    required this.onAddToCart,
    required this.onPinnedListAdd,
  });

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPinnedListAdd,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child:
                        product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Container(
                              color: ColorResources.labelColor,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFE5E7EB),
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFE5E7EB),
                            width: double.infinity,
                            height: double.infinity,
                            child: const Icon(
                              Icons.image_outlined,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        padding: EdgeInsets.all(context.responsiveWidth(0.007)),
                        decoration: BoxDecoration(
                          color: ColorResources.whiteColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: ColorResources.whiteColor),
                        ),
                        child: SvgPicture.asset(
                          ImagesConstant.cart,
                          width: context.responsiveWidth(0.02),
                          height: context.responsiveHeight(0.02),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.geistMono(
                        fontSize: context.fontXS,
                        fontWeight: FontWeight.w600,
                        color: ColorResources.labelColor,
                      ),
                    ),
                    Text(
                      'SKU ${product.skuCode ?? '--'}',
                      style: GoogleFonts.geistMono(
                        fontSize: context.fontXS - 1,
                        color: ColorResources.labelColor.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      'Old SKU ${product.oldSkuCode ?? '--'}',
                      style: GoogleFonts.geistMono(
                        fontSize: context.fontXS - 1,
                        color: ColorResources.labelColor.withOpacity(0.4),
                      ),
                    ),
                    Text(
                      'Rs. ${_fmt(product.productPrice ?? 0)}',
                      style: GoogleFonts.geistMono(
                        fontSize: context.fontXS,
                        fontWeight: FontWeight.w700,
                        color: ColorResources.labelColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
