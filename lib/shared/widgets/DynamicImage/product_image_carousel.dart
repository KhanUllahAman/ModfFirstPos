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
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: (idx) =>
                                    setState(() => _currentPage = idx),
                                itemCount: widget.imageUrls.length,
                                itemBuilder: (_, index) =>
                                    _image(widget.imageUrls[index]),
                              ),
                            ),
                            if (widget.imageUrls.length > 1) ...[
                              if (_currentPage > 0)
                                Positioned(
                                  left: 6,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Material(
                                      color: Colors.black.withOpacity(0.35),
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () {
                                          _pageController.previousPage(
                                            duration: const Duration(
                                                milliseconds: 250),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Icon(
                                            Icons.chevron_left_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (_currentPage < widget.imageUrls.length - 1)
                                Positioned(
                                  right: 6,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Material(
                                      color: Colors.black.withOpacity(0.35),
                                      shape: const CircleBorder(),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: () {
                                          _pageController.nextPage(
                                            duration: const Duration(
                                                milliseconds: 250),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Icon(
                                            Icons.chevron_right_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ],
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

/// Compact slider specifically for product cards (supports multiple images swipe and chevrons).
class ProductCardImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const ProductCardImageSlider({
    super.key,
    required this.imageUrls,
    this.borderRadius = BorderRadius.zero,
    this.onTap,
  });

  @override
  State<ProductCardImageSlider> createState() => _ProductCardImageSliderState();
}

class _ProductCardImageSliderState extends State<ProductCardImageSlider> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return ClipRRect(
        borderRadius: widget.borderRadius,
        child: Container(
          color: const Color(0xFFF3F4F6),
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_outlined,
            color: Colors.grey,
            size: 22,
          ),
        ),
      );
    }

    if (widget.imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: widget.borderRadius,
        child: CachedNetworkImage(
          imageUrl: widget.imageUrls.first,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorWidget: (_, __, ___) => Container(
            color: const Color(0xFFE5E7EB),
            alignment: Alignment.center,
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey,
              size: 20,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Swipeable images
          PageView.builder(
            controller: _controller,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: widget.imageUrls.length,
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: widget.imageUrls[i],
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFFE5E7EB),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ),

          // Left Chevron Button
          if (_currentPage > 0)
            Positioned(
              left: 2,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _controller.previousPage(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          // Right Chevron Button
          if (_currentPage < widget.imageUrls.length - 1)
            Positioned(
              right: 2,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          // Dots Indicator pill
          Positioned(
            bottom: 3,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.imageUrls.length,
                    (index) {
                      final isCur = _currentPage == index;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        width: isCur ? 7 : 3.5,
                        height: 3.5,
                        decoration: BoxDecoration(
                          color: isCur ? Colors.white : Colors.white60,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    },
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
