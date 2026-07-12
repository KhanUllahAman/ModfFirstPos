import 'dart:convert';
import 'dart:developer';
import 'package:modfirstpos/core/exceptions/app_exceptions.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/product/model/product_model.dart';

class ProductService {
  final NetworkClient _client = NetworkClient();

  Future<ProductListResponse> fetchProducts({
    int page = 1,
    int limit = 20,
    int? categoryId,
    String? name,
    String? status,
    bool? isActive,
    bool? isFeatured,
    String sortBy = 'newest',
    String order = 'desc',
  }) async {
    try {
      final filters = <String, dynamic>{};
      if (categoryId != null) filters['category_id'] = categoryId;
      if (name != null && name.trim().isNotEmpty) filters['name'] = name.trim();
      if (status != null) filters['status'] = status;
      if (isActive != null) filters['is_active'] = isActive;
      if (isFeatured != null) filters['is_featured'] = isFeatured;

      final response = await _client.post(
        endpoint: ApiConstants.productListEndpoint, // ⚠️ actual path lagao
        body: {
          'page': page,
          'limit': limit,
          'filters': filters,
          'sortBy': sortBy,
          'order': order,
        },
        showErrorSnackbar: false,
      );

      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}') as Map<String, dynamic>;

      return ProductListResponse.fromJson(data);
    } catch (e) {
      log("ProductService fetchProducts error: $e");
      if (e is AppException) rethrow;
      rethrow;
    }
  }
}