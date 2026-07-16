import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/order/model/order_model.dart';
import 'package:modfirstpos/modules/order/service/order_service.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/home/controller/home_controller.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class OrderController extends GetxController {
  final OrderService _service = OrderService();

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final Rxn<OrderModel> selectedOrder = Rxn<OrderModel>();

  // Pagination states
  final RxInt currentPage = 1.obs;
  final RxInt limit = 20.obs;
  final RxInt totalCount = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasNext = false.obs;
  final RxBool hasPrev = false.obs;

  // Filter states
  final RxString selectedStatus = 'All'.obs;
  final RxString selectedPaymentStatus = 'All'.obs;
  final RxString selectedDeliveryType = 'All'.obs;
  final Rxn<String> startDate = Rxn<String>();
  final Rxn<String> endDate = Rxn<String>();

  // Filter options lists
  final List<String> statusOptions = [
    'All',
    'booked',
    'accepted',
    'design_review',
    'preparing',
    'label_create',
    'shipped',
    'ready_for_pickup',
    'completed',
    'cancelled',
  ];

  final List<String> paymentStatusOptions = [
    'All',
    'pending',
    'paid',
    'failed',
    'refunded',
  ];

  final List<String> deliveryTypeOptions = [
    'All',
    'home_delivery',
    'store_pickup',
  ];

  late ScrollController orderListScrollController;
  late ScrollController orderDetailsScrollController;

  final Rxn<CustomerModel> currentFilterCustomer = Rxn<CustomerModel>();

  bool get isCustomerInCart {
    final customer = currentFilterCustomer.value;
    if (customer == null) return false;
    final homeController = Get.find<HomeController>();
    return homeController.selectedCartCustomer.value?.email == customer.email;
  }

  void toggleCustomerInCart() {
    final customer = currentFilterCustomer.value;
    if (customer == null) return;
    final homeController = Get.find<HomeController>();
    if (isCustomerInCart) {
      homeController.selectedCartCustomer.value = null;
      customSnackBar('Customer Removed', 'Customer removed from cart', snackBarType: SnackBarType.success);
    } else {
      homeController.selectedCartCustomer.value = customer;
      customSnackBar('Customer Added', 'Customer added to cart', snackBarType: SnackBarType.success);
    }
  }

  @override
  void onInit() {
    super.onInit();
    orderListScrollController = ScrollController();
    orderDetailsScrollController = ScrollController();

    final args = Get.arguments;
    if (args is Map) {
      if (args['customer'] is CustomerModel) {
        currentFilterCustomer.value = args['customer'] as CustomerModel;
      }
      if (args['email'] != null) {
        searchQuery.value = args['email'];
        searchController.text = args['email'];
      }
    }

    loadOrders();
    
    // Add debounce to search to avoid calling API too many times
    debounce(searchQuery, (_) {
      currentPage.value = 1;
      loadOrders();
    }, time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    searchController.dispose();
    orderListScrollController.dispose();
    orderDetailsScrollController.dispose();
    super.onClose();
  }


  Future<void> loadOrders({bool isRefresh = false, bool forceSync = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
    }

    try {
      isLoading.value = true;
      final response = await _service.fetchOrders(
        page: currentPage.value,
        limit: limit.value,
        status: selectedStatus.value,
        paymentStatus: selectedPaymentStatus.value,
        deliveryType: selectedDeliveryType.value,
        startDate: startDate.value,
        endDate: endDate.value,
        search: searchQuery.value,
        forceSync: forceSync,
      );

      if (response.isSuccess) {
        orders.assignAll(response.payload);
        totalCount.value = response.pagination.total ?? 0;
        totalPages.value = response.pagination.totalPages ?? 1;
        hasNext.value = response.pagination.hasNext ?? false;
        hasPrev.value = response.pagination.hasPrev ?? false;

        // Auto select first order if details is empty and we have items
        if (orders.isNotEmpty) {
          if (selectedOrder.value == null || !orders.any((o) => o.id == selectedOrder.value?.id)) {
            selectedOrder.value = orders.first;
          } else {
            // update existing selected order if present
            final currentId = selectedOrder.value?.id;
            selectedOrder.value = orders.firstWhere((o) => o.id == currentId, orElse: () => orders.first);
          }
        } else {
          selectedOrder.value = null;
        }

        if (forceSync) {
          customSnackBar(
            'Synced Successfully',
            'Fresh orders loaded from server',
            snackBarType: SnackBarType.success,
          );
        }
      } else {
        orders.clear();
        selectedOrder.value = null;
      }
    } catch (e) {
      log("OrderController loadOrders error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncOrders() async {
    await loadOrders(isRefresh: true, forceSync: true);
  }


  void onSearchChanged(String val) {
    searchQuery.value = val;
  }

  void selectOrder(OrderModel order) {
    selectedOrder.value = order;
  }

  void selectStatus(String status) {
    selectedStatus.value = status;
    currentPage.value = 1;
    loadOrders();
  }

  void selectPaymentStatus(String paymentStatus) {
    selectedPaymentStatus.value = paymentStatus;
    currentPage.value = 1;
    loadOrders();
  }

  void selectDeliveryType(String type) {
    selectedDeliveryType.value = type;
    currentPage.value = 1;
    loadOrders();
  }

  void setDateRange(String? start, String? end) {
    startDate.value = start;
    endDate.value = end;
    currentPage.value = 1;
    loadOrders();
  }

  void clearFilters() {
    selectedStatus.value = 'All';
    selectedPaymentStatus.value = 'All';
    selectedDeliveryType.value = 'All';
    startDate.value = null;
    endDate.value = null;
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;
    loadOrders();
  }

  void nextPage() {
    if (hasNext.value) {
      currentPage.value++;
      loadOrders();
    }
  }

  void prevPage() {
    if (hasPrev.value) {
      currentPage.value--;
      loadOrders();
    }
  }
}
