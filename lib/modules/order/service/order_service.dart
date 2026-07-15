import 'dart:convert';
import 'dart:developer';
import 'package:modfirstpos/core/exceptions/app_exceptions.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/order/storage/order_cache_storage.dart';
import 'package:modfirstpos/modules/order/model/order_model.dart';

class OrderService {
  final NetworkClient _client = NetworkClient();

  Future<OrderListResponse> fetchOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? paymentStatus,
    String? deliveryType,
    String? startDate,
    String? endDate,
    String? search,
    bool forceSync = false,
  }) async {
    try {
      final isDefaultFilters = page == 1 &&
          (status == null || status == 'All') &&
          (paymentStatus == null || paymentStatus == 'All') &&
          (deliveryType == null || deliveryType == 'All') &&
          (startDate == null || startDate.isEmpty) &&
          (endDate == null || endDate.isEmpty) &&
          (search == null || search.trim().isEmpty);

      if (!forceSync && isDefaultFilters) {
        final cachedData = await OrderCacheStorage.getOrders();
        if (cachedData != null) {
          log("OrderService: Loaded orders from local storage cache.");
          return OrderListResponse.fromJson(cachedData);
        }
      }

      final filters = <String, dynamic>{};
      if (status != null && status.trim().isNotEmpty && status != 'All') {
        filters['status'] = status.trim();
      }
      if (paymentStatus != null && paymentStatus.trim().isNotEmpty && paymentStatus != 'All') {
        filters['payment_status'] = paymentStatus.trim();
      }
      if (deliveryType != null && deliveryType.trim().isNotEmpty && deliveryType != 'All') {
        filters['delivery_type'] = deliveryType.trim();
      }

      final body = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (filters.isNotEmpty) {
        body['filters'] = filters;
      }
      if (startDate != null && startDate.isNotEmpty) {
        body['startDate'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        body['endDate'] = endDate;
      }
      if (search != null && search.trim().isNotEmpty) {
        body['search'] = search.trim();
      }

      final response = await _client.post(
        endpoint: ApiConstants.orderListEndpoint,
        body: body,
        showErrorSnackbar: false,
      );

      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}')
                as Map<String, dynamic>;

      if (data['success'] == true && isDefaultFilters) {
        await OrderCacheStorage.saveOrders(data);
      }

      return OrderListResponse.fromJson(data);
    } catch (e) {
      log("OrderService fetchOrders error: $e");
      if (e is AppException) rethrow;
      rethrow;
    }
  }
}

