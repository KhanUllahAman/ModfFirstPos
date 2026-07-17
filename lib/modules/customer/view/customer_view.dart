import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/utils/app_fonts.dart';
import 'package:modfirstpos/core/utils/colors.dart';
import 'package:modfirstpos/modules/customer/controller/customer_controller.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/shared/widgets/Buttons/sync_button_widget.dart';
import 'package:modfirstpos/shared/widgets/ScreenSize/screen_size_utils.dart';
import 'package:modfirstpos/shared/widgets/appBarWidget/app_bar_widget.dart';
import 'package:modfirstpos/shared/widgets/backButtonWidgt/back_button_widget.dart';
import 'package:modfirstpos/shared/widgets/noKeyboard/no_keyboard_extension.dart';
import 'package:modfirstpos/shared/widgets/sideNav/app_nav_drawer.dart';

class CustomerView extends GetView<CustomerController> {
  const CustomerView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorResources.backgroundColor,
      appBar: AppTopBar(),
      drawer: const AppNavDrawer(),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.responsiveWidth(0.02)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BackBar(title: 'Users'),
                    SizedBox(height: context.spacingSM),
                    // Search bar & Sync row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: context.responsiveHeight(0.060),
                            child: TextField(
                              controller: controller.searchController,
                              onChanged: controller.onSearchChanged,
                              style: AppFonts.geistMono(
                                fontSize: context.fontSM,
                                color: ColorResources.labelColor,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search ID / Name / Email / Phone',
                                hintStyle: AppFonts.geistMono(
                                  fontWeight: FontWeight.w600,
                                  fontSize: context.fontSM,
                                  color: ColorResources.labelColor.withOpacity(0.5),
                                ),
                                suffixIcon: const Icon(Icons.search, color: ColorResources.blackColor),
                                filled: true,
                                fillColor: ColorResources.whiteColor,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: ColorResources.cardBorderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: ColorResources.cardBorderColor),
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
                              onPressed: controller.syncCustomers,
                              isLoading: controller.isLoading.value,
                              label: 'Sync Customers',
                            )),
                      ],
                    ),
                    SizedBox(height: context.spacingSM),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return Center(
                            child: CircularProgressIndicator(color: theme.secondaryColor.value),
                          );
                        }

                        final customers = controller.filteredCustomers;

                        if (customers.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'No customers found',
                                  style: AppFonts.geistMono(
                                    fontSize: context.fontSM,
                                    color: ColorResources.blackColor.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                AppSyncButton(
                                  onPressed: () => controller.loadCustomers(),
                                  label: 'Reload Customers',
                                  icon: Icons.refresh_rounded,
                                ),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          primary: false,
                          padding: EdgeInsets.symmetric(horizontal: context.spacingSM),
                          itemCount: customers.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.25,
                          ),
                          itemBuilder: (_, i) => _CustomerListCard(
                            customer: customers[i],
                            onTap: () => controller.navigateToCustomerOrders(customers[i]),
                          ),
                        );
                      }),
                    ),
                    // Customer Pagination
                    Obx(() {
                      if (controller.customers.isEmpty) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total: ${controller.totalCount.value} users',
                              style: AppFonts.geistMono(
                                fontSize: context.fontXS,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: controller.hasPrev.value ? controller.prevPage : null,
                                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                                  color: ColorResources.appAccentColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Page ${controller.currentPage.value} / ${controller.totalPages.value}',
                                  style: AppFonts.geistMono(
                                    fontSize: context.fontXS,
                                    fontWeight: FontWeight.w700,
                                    color: ColorResources.labelColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: controller.hasNext.value ? controller.nextPage : null,
                                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                                  color: ColorResources.appAccentColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).noKeyboard();
  }
}

class _CustomerListCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;
  const _CustomerListCard({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.spacingSM),
        decoration: BoxDecoration(
          color: ColorResources.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorResources.cardBorderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _CustomerAvatar(
                  customer: customer,
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.fullName ?? 'Walk-in Customer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.geistMono(
                          fontSize: context.fontSM,
                          fontWeight: FontWeight.w700,
                          color: ColorResources.labelColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          customer.role?.replaceAll('_', ' ').toUpperCase() ?? 'CUSTOMER',
                          style: AppFonts.geistMono(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 12, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    customer.email ?? 'No email address',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.geistMono(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 12, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    customer.phone ?? 'No phone number',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.geistMono(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Divider(height: 1, color: ColorResources.cardBorderColor),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Verified',
                  style: AppFonts.geistMono(
                    fontSize: 10,
                    color: customer.emailVerified ? ColorResources.successGreen : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'View Orders',
                      style: AppFonts.geistMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: theme.secondaryColor.value,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: theme.secondaryColor.value,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerAvatar extends StatelessWidget {
  final CustomerModel customer;
  final double radius;
  const _CustomerAvatar({required this.customer, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    final theme = Get.find<AppThemeService>();
    final initials = customer.fullName != null && customer.fullName!.isNotEmpty
        ? customer.fullName![0].toUpperCase()
        : '?';

    final hasImage = customer.image != null &&
        customer.image!.isNotEmpty &&
        customer.image != 'default-user.png';

    if (hasImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: customer.image!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (_, __) => CircleAvatar(
            radius: radius,
            backgroundColor: theme.secondaryColor.value.withOpacity(0.12),
            child: Text(
              initials,
              style: AppFonts.geistMono(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.bold,
                color: theme.secondaryColor.value,
              ),
            ),
          ),
          errorWidget: (_, __, ___) => CircleAvatar(
            radius: radius,
            backgroundColor: theme.secondaryColor.value.withOpacity(0.12),
            child: Text(
              initials,
              style: AppFonts.geistMono(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.bold,
                color: theme.secondaryColor.value,
              ),
            ),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.secondaryColor.value.withOpacity(0.12),
      child: Text(
        initials,
        style: AppFonts.geistMono(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
          color: theme.secondaryColor.value,
        ),
      ),
    );
  }
}
