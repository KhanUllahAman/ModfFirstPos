import 'dart:convert';
import 'dart:developer';
import 'package:modfirstpos/core/exceptions/app_exceptions.dart';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/category/storage/category_cache_storage.dart';
import 'package:modfirstpos/modules/category/model/category_model.dart';

class CategoryService {
  final NetworkClient _client = NetworkClient();

  Future<CategoryListResponse> fetchCategories({
    int page = 1,
    int limit = 20,
    String? name,
    String? slug,
    int? parentId,
    bool? isActive,
    int? createdBy,
    bool forceSync = false,
  }) async {
    try {
      if (!forceSync) {
        final cachedData = await CategoryCacheStorage.getCategories();
        if (cachedData != null) {
          log("CategoryService: Loaded categories from local storage cache.");
          return CategoryListResponse.fromJson(cachedData);
        }
      }

      final filters = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) filters['name'] = name.trim();
      if (slug != null && slug.trim().isNotEmpty) filters['slug'] = slug.trim();
      if (parentId != null) filters['parent_id'] = parentId;
      if (isActive != null) filters['is_active'] = isActive;
      if (createdBy != null) filters['created_by'] = createdBy;

      final response = await _client.post(
        endpoint: ApiConstants.categoryListEndpoint,
        body: {'page': page, 'limit': limit, 'filters': filters},
        showErrorSnackbar: false,
      );
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}')
                as Map<String, dynamic>;

      if (data['success'] == true) {
        await CategoryCacheStorage.saveCategories(data);
      }

      return CategoryListResponse.fromJson(data);
    } catch (e) {
      log("CategoryService fetchCategories error: $e");
      if (e is AppException) rethrow;
      rethrow;
    }
  }
}

