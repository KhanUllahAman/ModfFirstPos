import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/core/utils/currency_utils.dart';
import 'package:modfirstpos/core/utils/url_utils.dart';
import 'package:modfirstpos/modules/draft_orders/controller/draft_order_controller.dart';
import 'package:modfirstpos/modules/draft_orders/model/draft_order_model.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';

class DraftOrdersPanel extends StatelessWidget {
  final HomeController homeController;
  final DraftOrderController draftController = Get.put(DraftOrderController());

  DraftOrdersPanel({super.key, required this.homeController});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          _buildHeader(context, theme),
          const SizedBox(height: 8),

          // Search Field
          _buildSearchField(context, theme),
          const SizedBox(height: 8),

          // Status & Delivery Filter Chips
          _buildFilterChips(context, theme),
          const SizedBox(height: 8),

          // Draft Orders List
          Expanded(
            child: Obx(() {
              if (draftController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ColorResources.blackColor,
                    strokeWidth: 3.0,
                  ),
                );
              }

              final drafts = draftController.draftOrders;
              if (drafts.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: () => draftController.fetchDraftOrders(refresh: true),
                child: ListView.separated(
                  controller: draftController.scrollController,
                  itemCount: drafts.length + (draftController.isMoreLoading.value ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (index == drafts.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    final draft = drafts[index];
                    return _buildDraftCard(context, theme, draft);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppThemeService theme) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: ColorResources.blackColor,
          ),
          onPressed: homeController.closeDraftOrdersPanel,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Row(
            children: [
              Text(
                'DRAFT ORDERS',
                style: AppFonts.geistMono(
                  fontSize: context.fontSM,
                  fontWeight: FontWeight.w700,
                  color: ColorResources.labelColor,
                ),
              ),
              const SizedBox(width: 8),
              Obx(() {
                if (draftController.totalCount.value > 0) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.secondaryColor.value.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${draftController.totalCount.value}',
                      style: AppFonts.geistMono(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: theme.secondaryColor.value,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh Drafts',
          icon: const Icon(
            Icons.refresh_rounded,
            color: ColorResources.blackColor,
            size: 20,
          ),
          onPressed: () => draftController.fetchDraftOrders(refresh: true),
        ),
        IconButton(
          icon: const Icon(
            Icons.close_rounded,
            color: Colors.grey,
            size: 20,
          ),
          onPressed: homeController.closeDraftOrdersPanel,
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context, AppThemeService theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: draftController.searchController,
        onChanged: draftController.onSearchChanged,
        style: AppFonts.geistMono(
          fontSize: 12.5,
          color: ColorResources.labelColor,
        ),
        decoration: InputDecoration(
          hintText: 'Search draft #, customer name, phone...',
          hintStyle: AppFonts.geistMono(
            fontSize: 12,
            color: Colors.grey[400],
          ),
          prefixIcon: const Icon(
            Iconsax.search_normal_1,
            size: 16,
            color: Colors.grey,
          ),
          suffixIcon: Obx(() {
            if (draftController.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear_rounded, size: 16),
                onPressed: draftController.clearSearch,
              );
            }
            return const SizedBox.shrink();
          }),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, AppThemeService theme) {
    const statuses = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Open', 'value': 'open'},
      {'label': 'Completed', 'value': 'completed'},
      {'label': 'Invoice Sent', 'value': 'invoice_sent'},
      {'label': 'Cancelled', 'value': 'cancelled'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((st) {
          return Obx(() {
            final isSelected = draftController.selectedStatus.value == st['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: ChoiceChip(
                label: Text(
                  st['label']!,
                  style: AppFonts.geistMono(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? theme.onSecondaryColor
                        : ColorResources.labelColor,
                  ),
                ),
                selected: isSelected,
                selectedColor: theme.secondaryColor.value,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? theme.secondaryColor.value
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                onSelected: (_) => draftController.setStatusFilter(st['value']!),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildDraftCard(
    BuildContext context,
    AppThemeService theme,
    DraftOrderModel draft,
  ) {
    final statusColor = _getStatusColor(draft.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Row: Draft Number & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt_outlined, size: 13, color: Color(0xFF475569)),
                          const SizedBox(width: 4),
                          Text(
                            draft.draftNumber,
                            style: AppFonts.geistMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    draft.status.toUpperCase(),
                    style: AppFonts.geistMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),

            // Customer Info Row
            Row(
              children: [
                const Icon(Iconsax.user, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    draft.displayCustomerName,
                    style: AppFonts.geistMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ColorResources.labelColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (draft.displayPhone != '--') ...[
                  const Icon(Iconsax.call, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    draft.displayPhone,
                    style: AppFonts.geistMono(
                      fontSize: 11,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),

            // Delivery & Channel Row
            Row(
              children: [
                Icon(
                  draft.deliveryType == 'home_delivery'
                      ? Iconsax.truck_fast
                      : Iconsax.shop,
                  size: 13,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  draft.deliveryType == 'home_delivery'
                      ? 'Home Delivery'
                      : 'Store Pickup',
                  style: AppFonts.geistMono(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                Text(
                  '${draft.items.length} ${draft.items.length == 1 ? 'item' : 'items'}',
                  style: AppFonts.geistMono(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            // Items Summary with Product Images
            if (draft.items.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...draft.items.take(3).map((it) {
                      final pName = it.product?.name ?? it.customText ?? 'Item';
                      final resolvedImage = it.imageUrl;
                      final fullImageUrl =
                          UrlUtils.resolveImageUrl(resolvedImage);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          children: [
                            // Product Image Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 34,
                                height: 34,
                                color: const Color(0xFFE2E8F0),
                                child: (fullImageUrl != null &&
                                        fullImageUrl.isNotEmpty)
                                    ? CachedNetworkImage(
                                        imageUrl: fullImageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => const Center(
                                          child: SizedBox(
                                            width: 12,
                                            height: 12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                            ),
                                          ),
                                        ),
                                        errorWidget: (_, __, ___) =>
                                            const Icon(
                                          Icons.inventory_2_outlined,
                                          size: 16,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.inventory_2_outlined,
                                        size: 16,
                                        color: Color(0xFF94A3B8),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Name & Quantity
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pName,
                                    style: AppFonts.geistMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1E293B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${it.quantity} x ${CurrencyUtils.format(it.unitPrice, decimals: 2)}',
                                    style: AppFonts.geistMono(
                                      fontSize: 10,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Line Total
                            Text(
                              CurrencyUtils.format(it.lineTotal, decimals: 2),
                              style: AppFonts.geistMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (draft.items.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '+ ${draft.items.length - 3} more items',
                          style: AppFonts.geistMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: theme.secondaryColor.value,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),

            // Bottom Row: Total Amount & Add to Cart Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL AMOUNT',
                      style: AppFonts.geistMono(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600],
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      CurrencyUtils.format(draft.totalAmount, decimals: 2),
                      style: AppFonts.geistMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: theme.secondaryColor.value,
                      ),
                    ),
                  ],
                ),
                if (draft.isCompleted)
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 15,
                          color: Color(0xFF16A34A),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Completed',
                          style: AppFonts.geistMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (draft.isCancelled)
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cancel_outlined,
                          size: 15,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Cancelled',
                          style: AppFonts.geistMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => draftController.loadDraftOrderToCart(
                      draft,
                      homeController,
                    ),
                    icon: Icon(
                      Icons.add_shopping_cart_rounded,
                      size: 15,
                      color: theme.onSecondaryColor,
                    ),
                    label: Text(
                      'Load to Cart',
                      style: AppFonts.geistMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.onSecondaryColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.secondaryColor.value,
                      foregroundColor: theme.onSecondaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const Color(0xFF0284C7); // Sky Blue
      case 'completed':
        return const Color(0xFF16A34A); // Green
      case 'invoice_sent':
        return const Color(0xFF7C3AED); // Purple
      case 'cancelled':
        return ColorResources.gradientRed;
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: ColorResources.blackColor.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No Draft Orders Found',
              style: AppFonts.geistMono(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ColorResources.labelColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try changing search query or filter status',
              textAlign: TextAlign.center,
              style: AppFonts.geistMono(
                fontSize: 11.5,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
