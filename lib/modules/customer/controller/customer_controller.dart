import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/customer/service/customer_service.dart';
import 'package:modfirstpos/routes/app_routes.dart';
import 'package:modfirstpos/shared/widgets/Snackbar/custom_snackbar.dart';

class CustomerController extends GetxController {
  final CustomerService _service = CustomerService();

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final Rxn<CustomerModel> selectedCustomer = Rxn<CustomerModel>();

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt limit = 20.obs;
  final RxInt totalCount = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasNext = false.obs;
  final RxBool hasPrev = false.obs;

  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    loadCustomers();
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadCustomers({bool isRefresh = false, bool forceSync = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
    }

    try {
      isLoading.value = true;
      final response = await _service.fetchCustomers(
        page: currentPage.value,
        limit: limit.value,
        forceSync: forceSync,
      );

      if (response.isSuccess) {
        customers.assignAll(response.payload);
        totalCount.value = response.pagination.total ?? 0;
        totalPages.value = response.pagination.totalPages ?? 1;
        hasNext.value = response.pagination.hasNext ?? false;
        hasPrev.value = response.pagination.hasPrev ?? false;

        if (customers.isNotEmpty) {
          selectedCustomer.value = customers.first;
        } else {
          selectedCustomer.value = null;
        }

        if (forceSync) {
          customSnackBar(
            'Synced Successfully',
            'Fresh users loaded from server',
            snackBarType: SnackBarType.success,
          );
        }
      } else {
        customers.clear();
        selectedCustomer.value = null;
      }
    } catch (e) {
      log("CustomerController loadCustomers error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncCustomers() async {
    await loadCustomers(isRefresh: true, forceSync: true);
  }

  List<CustomerModel> get filteredCustomers {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return customers;
    return customers.where((c) {
      final name = (c.fullName ?? '').toLowerCase();
      final email = (c.email ?? '').toLowerCase();
      final phone = (c.phone ?? '').toLowerCase();
      return name.contains(query) || email.contains(query) || phone.contains(query);
    }).toList();
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
  }

  void selectCustomer(CustomerModel customer) {
    selectedCustomer.value = customer;
  }

  void navigateToCustomerOrders(CustomerModel customer) {
    if (customer.email != null && customer.email!.isNotEmpty) {
      Get.toNamed(
        Routes.order,
        arguments: {
          'email': customer.email,
          'customerName': customer.fullName,
        },
      );
    } else {
      customSnackBar(
        'No Email Associated',
        'This user does not have a registered email address to filter orders.',
        snackBarType: SnackBarType.warning,
      );
    }
  }

  void nextPage() {
    if (hasNext.value) {
      currentPage.value++;
      loadCustomers();
    }
  }

  void prevPage() {
    if (hasPrev.value) {
      currentPage.value--;
      loadCustomers();
    }
  }
}
