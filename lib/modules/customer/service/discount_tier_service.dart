import 'dart:convert';
import 'dart:developer';
import 'package:modfirstpos/core/models/pagination_model.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/customer/model/discount_tier_model.dart';

class DiscountTierService {
  final NetworkClient _client = NetworkClient();

  Map<String, dynamic> _asMap(dynamic data) {
    return data is Map<String, dynamic>
        ? data
        : jsonDecode(data?.toString() ?? '{}') as Map<String, dynamic>;
  }

  Future<DiscountTierListResponse> fetchDiscountTiers({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.post(
        endpoint: ApiConstants.discountTierListEndpoint,
        body: {'page': page, 'limit': limit},
        showErrorSnackbar: false,
      );
      return DiscountTierListResponse.fromJson(_asMap(response.data));
    } catch (e) {
      log("DiscountTierService fetchDiscountTiers error: $e");
      return DiscountTierListResponse(
        isSuccess: false,
        message: e.toString(),
        payload: const [],
        pagination: PaginationModel(),
      );
    }
  }

  Future<DiscountTierCreateResponse> createDiscountTier({
    required String name,
    required String discountType,
    required double discountValue,
  }) async {
    try {
      final response = await _client.post(
        endpoint: ApiConstants.discountTierCreateEndpoint,
        body: {
          'name': name,
          'discount_type': discountType,
          'discount_value': discountValue,
        },
        showErrorSnackbar: false,
      );
      return DiscountTierCreateResponse.fromJson(_asMap(response.data));
    } catch (e) {
      log("DiscountTierService createDiscountTier error: $e");
      return DiscountTierCreateResponse(
        isSuccess: false,
        status: 0,
        message: e.toString(),
      );
    }
  }
}
