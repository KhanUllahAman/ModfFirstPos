import 'dart:convert';
import 'dart:developer';
import 'package:modfirstpos/core/exceptions/app_exceptions.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/customer/model/customer_model.dart';
import 'package:modfirstpos/modules/customer/storage/customer_cache_storage.dart';

class CustomerService {
  final NetworkClient _client = NetworkClient();
  static const String walkinPassword = 'WalkinCustomer@1234';

  Future<CreateCustomerResponse> createCustomer({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    try {
      final body = {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': walkinPassword,
        'confirmPassword': walkinPassword,
        'role': 'customer',
      };
      final response = await _client.post(
        endpoint: ApiConstants.userCreateEndpoint,
        body: body,
        showErrorSnackbar: false,
      );
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}')
                as Map<String, dynamic>;
      return CreateCustomerResponse.fromJson(data);
    } catch (e) {
      log("CustomerService createCustomer error: $e");
      return CreateCustomerResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<CustomerListResponse> fetchCustomers({
    int page = 1,
    int limit = 20,
    String? startDate,
    String? endDate,
    bool forceSync = false,
  }) async {
    try {
      final isDefaultCall =
          page == 1 &&
          (startDate == null || startDate.isEmpty) &&
          (endDate == null || endDate.isEmpty);

      if (!forceSync && isDefaultCall) {
        final cachedData = await CustomerCacheStorage.getCustomers();
        if (cachedData != null) {
          log("CustomerService: Loaded users from local storage cache.");
          return CustomerListResponse.fromJson(cachedData);
        }
      }

      final body = <String, dynamic>{
        'page': page,
        'limit': limit,
        'filters': {'role': 'customer'},
      };

      if (startDate != null && startDate.isNotEmpty) {
        body['startDate'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        body['endDate'] = endDate;
      }

      final response = await _client.post(
        endpoint: ApiConstants.userListEndpoint,
        body: body,
        showErrorSnackbar: false,
      );
      log("Body User List $body");
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}')
                as Map<String, dynamic>;

      if (data['success'] == true && isDefaultCall) {
        await CustomerCacheStorage.saveCustomers(data);
      }

      return CustomerListResponse.fromJson(data);
    } catch (e) {
      log("CustomerService fetchCustomers error: $e");
      final cachedData = await CustomerCacheStorage.getCustomers();
      if (cachedData != null) {
        log("CustomerService: network failed, serving cached customers.");
        return CustomerListResponse.fromJson(cachedData);
      }
      if (e is AppException) rethrow;
      rethrow;
    }
  }
}
