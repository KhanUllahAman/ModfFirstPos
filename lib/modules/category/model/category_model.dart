import 'package:modfirstpos/core/models/pagination_model.dart';

class CategoryModel {
  final int? id;
  final String? name;
  final String? slug;
  final String? description;
  final int? parentId;
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
    this.isActive,
    this.isDeleted,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.parent,
    this.children = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      parentId: json['parent_id'] as int?,
      isActive: json['is_active'] as bool?,
      isDeleted: json['is_deleted'] as bool?,
      createdBy: json['created_by'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      parent: json['parent'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      children: (json['children'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
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
    final rawPayload = json['payload'];
    final list = rawPayload is List
        ? rawPayload
            .whereType<Map<String, dynamic>>()
            .map((e) => CategoryModel.fromJson(e))
            .toList()
        : <CategoryModel>[];

    return CategoryListResponse(
      isSuccess: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      payload: list,
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>?,
      ),
    );
  }
}