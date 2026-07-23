import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/customer/repository/customer_local_repository.dart';
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
        customers.assignAll(await _mergeWithLocal(response.payload));
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
      // Fully offline with no cache: still show locally created customers.
      if (customers.isEmpty) {
        customers.assignAll(await _mergeWithLocal(const []));
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Prepends customers created on this device (offline-first) that the
  /// server list does not know about yet.
  Future<List<CustomerModel>> _mergeWithLocal(
    List<CustomerModel> serverCustomers,
  ) async {
    try {
      final local = await CustomerLocalRepository.getAll();
      final pendingLocal = local.where((localCustomer) {
        return !serverCustomers.any((server) =>
            server.id == localCustomer.id ||
            (localCustomer.phone != null &&
                localCustomer.phone!.isNotEmpty &&
                server.phone == localCustomer.phone));
      }).toList();
      return [...pendingLocal, ...serverCustomers];
    } catch (e) {
      log("CustomerController _mergeWithLocal error: $e");
      return serverCustomers;
    }
  }

  /// Creates the customer on the server (POST users/create). Falls back to
  /// an offline-local record only when there is no connectivity, so the
  /// cashier is never blocked; a proper 409/validation error from the
  /// server is surfaced as-is instead of silently going local.
  Future<CustomerModel?> addCustomer({
    required String fullName,
    required String phone,
    required String email,
    String? address,
  }) async {
    try {
      final response = await _service.createCustomer(
        fullName: fullName,
        email: email,
        phone: phone,
      );

      if (response.isSuccess && response.payload != null) {
        final customer = response.payload!.copyWith(address: address);
        customers.insert(0, customer);
        selectedCustomer.value = customer;
        return customer;
      }

      customSnackBar(
        'Could Not Save',
        response.message.isNotEmpty
            ? response.message
            : 'The customer could not be created.',
        snackBarType: SnackBarType.error,
      );
      return null;
    } catch (e) {
      log("CustomerController addCustomer error: $e");
      // Likely offline — keep the cashier moving with a local-only record;
      // SyncService will push it once connectivity returns.
      try {
        final customer = await CustomerLocalRepository.addCustomer(
          fullName: fullName,
          phone: phone,
          email: email,
          address: address,
        );
        customers.insert(0, customer);
        selectedCustomer.value = customer;
        customSnackBar(
          'Saved Offline',
          'No connection — customer saved locally and will sync later.',
          snackBarType: SnackBarType.warning,
        );
        return customer;
      } catch (localError) {
        log("CustomerController addCustomer local fallback error: $localError");
        customSnackBar(
          'Could Not Save',
          'The customer could not be saved. Please try again.',
          snackBarType: SnackBarType.error,
        );
        return null;
      }
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
          'customer': customer,
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
