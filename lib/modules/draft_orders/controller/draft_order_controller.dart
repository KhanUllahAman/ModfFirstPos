import 'dart:async';
import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/exceptions/app_exceptions.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/draft_orders/model/draft_order_model.dart';
import 'package:modfirstpos/modules/draft_orders/service/draft_order_service.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class DraftOrderController extends GetxController {
  final DraftOrderService _service = DraftOrderService();

  final RxList<DraftOrderModel> draftOrders = <DraftOrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'all'.obs;
  final RxString selectedDeliveryType = 'all'.obs;

  final RxInt currentPage = 1.obs;
  final RxBool hasNext = false.obs;
  final RxInt totalCount = 0.obs;

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchDraftOrders(refresh: true);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoading.value &&
        !isMoreLoading.value &&
        hasNext.value) {
      loadMore();
    }
  }

  Future<void> fetchDraftOrders({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      isLoading.value = true;
    }

    try {
      final response = await _service.fetchDraftOrders(
        page: currentPage.value,
        limit: 20,
        search: searchQuery.value.trim().isEmpty ? null : searchQuery.value.trim(),
        status: selectedStatus.value == 'all' ? null : selectedStatus.value,
        deliveryType: selectedDeliveryType.value == 'all'
            ? null
            : selectedDeliveryType.value,
      );

      if (response.success) {
        if (refresh) {
          draftOrders.assignAll(response.payload);
        } else {
          draftOrders.addAll(response.payload);
        }
        if (response.pagination != null) {
          hasNext.value = response.pagination!.hasNext;
          totalCount.value = response.pagination!.total;
        } else {
          hasNext.value = false;
          totalCount.value = draftOrders.length;
        }
      }
    } catch (e) {
      log('DraftOrderController fetchDraftOrders error: $e');
      if (refresh) {
        draftOrders.clear();
      }
      if (e is AppException) {
        customSnackBar('Error', e.message, snackBarType: SnackBarType.error);
      }
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isMoreLoading.value || !hasNext.value) return;
    isMoreLoading.value = true;
    currentPage.value++;
    await fetchDraftOrders(refresh: false);
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchDraftOrders(refresh: true);
    });
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    fetchDraftOrders(refresh: true);
  }

  void setStatusFilter(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    fetchDraftOrders(refresh: true);
  }

  void setDeliveryFilter(String deliveryType) {
    if (selectedDeliveryType.value == deliveryType) return;
    selectedDeliveryType.value = deliveryType;
    fetchDraftOrders(refresh: true);
  }

  void loadDraftOrderToCart(
    DraftOrderModel draft,
    HomeController homeController,
  ) {
    // Prevent loading if draft order is already completed
    if (draft.isCompleted) {
      customSnackBar(
        'Draft Already Completed',
        'Draft #${draft.draftNumber} is already completed and cannot be added to cart.',
        snackBarType: SnackBarType.warning,
      );
      return;
    }

    if (draft.isCancelled) {
      customSnackBar(
        'Draft Cancelled',
        'Draft #${draft.draftNumber} is cancelled and cannot be added to cart.',
        snackBarType: SnackBarType.warning,
      );
      return;
    }

    // Prevent loading if another draft order is already in the cart
    if (homeController.activeDraftOrder.value != null &&
        homeController.cartItems.isNotEmpty) {
      final active = homeController.activeDraftOrder.value!;
      if (active.id != draft.id) {
        customSnackBar(
          'Draft Order Already In Cart',
          'Draft #${active.draftNumber} is already loaded in the cart. Please clear or complete the current cart before adding another draft order.',
          snackBarType: SnackBarType.warning,
        );
        return;
      }
    }

    if (draft.items.isEmpty) {
      customSnackBar(
        'Empty Draft',
        'This draft order does not contain any items.',
        snackBarType: SnackBarType.warning,
      );
      return;
    }

    // Set active draft order
    homeController.activeDraftOrder.value = draft;

    // Convert items into cart items
    final cartItemsToAdd = draft.items.map((it) => it.toCartItem()).toList();

    // Attach customer if present
    if (draft.user != null) {
      homeController.selectedCartCustomer.value = CustomerModel(
        id: draft.user!.id,
        fullName: draft.user!.fullName,
        email: draft.user!.email,
        phone: draft.user!.phone,
        accountType: draft.user!.accountType,
      );
    } else if (draft.shippingAddr != null && draft.shippingAddr!.userId != null) {
      homeController.selectedCartCustomer.value = CustomerModel(
        id: draft.shippingAddr!.userId!,
        fullName: draft.shippingAddr!.fullName,
        phone: draft.shippingAddr!.phone,
        email: draft.shippingAddr!.email,
        address: draft.shippingAddr!.fullAddressFormatted,
      );
    } else if ((draft.fullName != null && draft.fullName!.isNotEmpty) ||
        (draft.phone != null && draft.phone!.isNotEmpty)) {
      homeController.selectedCartCustomer.value = CustomerModel(
        id: draft.userId ?? 0,
        fullName: draft.fullName,
        phone: draft.phone,
        email: draft.email,
      );
    }

    // Add or merge items to POS cart
    for (final item in cartItemsToAdd) {
      homeController.addCartItem(item);
    }
    homeController.cartItems.refresh();

    // Close panel and return to home POS view
    homeController.showDraftOrdersPanel.value = false;

    customSnackBar(
      'Draft Loaded',
      'Draft #${draft.draftNumber} loaded into cart (${cartItemsToAdd.length} items).',
      snackBarType: SnackBarType.success,
    );
  }
}
