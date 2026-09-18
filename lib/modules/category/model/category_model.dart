import 'package:modfirstpos/core/models/pagination_model.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/core/utils/url_utils.dart';

class CategoryModel {
  final int? id;
  final String? name;
  final String? slug;
  final String? description;
  final int? parentId;
  final String? imageUrl;
  final bool? isActive;
  final bool? isDeleted;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final CategoryModel? parent;
  final List<CategoryModel> children;

  CategoryModel({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.parentId,
    this.imageUrl,
    this.isActive,
    this.isDeleted,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.parent,
    this.children = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final parentMap = JsonUtils.asMapOrNull(json['parent']);
    return CategoryModel(
      id: JsonUtils.asIntOrNull(json['id']),
      name: JsonUtils.asStringOrNull(json['name']),
      slug: JsonUtils.asStringOrNull(json['slug']),
      description: JsonUtils.asStringOrNull(json['description']),
      parentId: JsonUtils.asIntOrNull(json['parent_id']),
      imageUrl: UrlUtils.resolveImageUrl(
        JsonUtils.asStringOrNull(json['image_url'] ?? json['image']),
      ),
      isActive: JsonUtils.asBoolOrNull(json['is_active']),
      isDeleted: JsonUtils.asBoolOrNull(json['is_deleted']),
      createdBy: JsonUtils.asIntOrNull(json['created_by']),
      createdAt: JsonUtils.asStringOrNull(json['created_at']),
      updatedAt: JsonUtils.asStringOrNull(json['updated_at']),
      parent: parentMap != null ? CategoryModel.fromJson(parentMap) : null,
      children: JsonUtils.asModelList(json['children'], CategoryModel.fromJson),
    );
  }

  String get displayName => name ?? 'Unnamed Category';
}

class CategoryListResponse {
  final bool isSuccess;
  final String message;
  final List<CategoryModel> payload;
  final PaginationModel pagination;

  CategoryListResponse({
    required this.isSuccess,
    required this.message,
    required this.payload,
    required this.pagination,
  });

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    return CategoryListResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: JsonUtils.asModelList(json['payload'], CategoryModel.fromJson),
      pagination: PaginationModel.fromJson(
        JsonUtils.asMapOrNull(json['pagination']),
      ),
    );
  }
}
