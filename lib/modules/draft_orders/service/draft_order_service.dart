import 'dart:convert';
import 'dart:developer';
import 'package:modfirstpos/core/exceptions/app_exceptions.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/draft_orders/model/draft_order_model.dart';

class DraftOrderService {
  final NetworkClient _client = NetworkClient();

  Future<DraftOrderListResponse> fetchDraftOrders({
    int page = 1,
    int limit = 20,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    String? status,
    String? deliveryType,
    String? channel,
    int? userId,
    int? branchId,
  }) async {
    try {
      final body = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (search != null && search.trim().isNotEmpty) {
        body['search'] = search.trim();
      }

      final filters = <String, dynamic>{};
      if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
        filters['status'] = status.toLowerCase();
      }
      if (deliveryType != null &&
          deliveryType.isNotEmpty &&
          deliveryType.toLowerCase() != 'all') {
        filters['delivery_type'] = deliveryType.toLowerCase();
      }
      if (channel != null && channel.isNotEmpty && channel.toLowerCase() != 'all') {
        filters['channel'] = channel.toLowerCase();
      }
      if (userId != null) {
        filters['user_id'] = userId;
      }
      if (branchId != null) {
        filters['branch_id'] = branchId;
      }

      if (filters.isNotEmpty) {
        body['filters'] = filters;
      }

      final response = await _client.post(
        endpoint: ApiConstants.draftOrderListEndpoint,
        body: body,
        showErrorSnackbar: false,
      );

      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}')
              as Map<String, dynamic>;

      return DraftOrderListResponse.fromJson(data);
    } catch (e) {
      log("DraftOrderService fetchDraftOrders error: $e");
      if (e is AppException) rethrow;
      rethrow;
    }
  }
}
