import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';

/// Product image carousel with page dots. When [overrideImageUrl] is set
/// (e.g. the selected variant has its own image) it is shown instead of the
/// carousel with a subtle cross-fade. Owns and disposes its PageController.
class ProductImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final String? overrideImageUrl;
  final double height;

  const ProductImageCarousel({
    super.key,
    required this.imageUrls,
    this.overrideImageUrl,
    this.height = 160,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _image(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        width: double.infinity,
        errorWidget: (_, __, ___) => Container(
          color: const Color(0xFFE5E7EB),
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_outlined, color: Colors.grey, size: 40),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final override = widget.overrideImageUrl;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: override != null && override.isNotEmpty
          ? SizedBox(
              key: ValueKey('override-$override'),
              height: widget.height,
              child: _image(override),
            )
          : Column(
              key: const ValueKey('carousel'),
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: widget.height,
                  child: widget.imageUrls.isEmpty
                      ? _placeholder()
                      : PageView.builder(
                          controller: _pageController,
                          onPageChanged: (idx) =>
                              setState(() => _currentPage = idx),
                          itemCount: widget.imageUrls.length,
                          itemBuilder: (_, index) =>
                              _image(widget.imageUrls[index]),
                        ),
                ),
                if (widget.imageUrls.length > 1) ...[
                  const SizedBox(height: 8),
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.imageUrls.length, (index) {
                        final isCurrent = _currentPage == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isCurrent ? 12 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? theme.secondaryColor.value
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
