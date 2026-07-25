import 'package:modfirstpos/core/models/pagination_model.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';

class OrderCommentModel {
  final int? id;
  final int? userId;
  final int? orderId;
  final String? comment;
  final String? commentType;
  final bool? isInternal;
  final String? attachmentUrl;
  final bool? isActive;
  final bool? isDeleted;
  final int? createdBy;
  final int? updatedBy;
  final int? deletedBy;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;
  final String? humanizeCommentType;

  OrderCommentModel({
    this.id,
    this.userId,
    this.orderId,
    this.comment,
    this.commentType,
    this.isInternal,
    this.attachmentUrl,
    this.isActive,
    this.isDeleted,
    this.createdBy,
    this.updatedBy,
    this.deletedBy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.humanizeCommentType,
  });

  factory OrderCommentModel.fromJson(Map<String, dynamic> json) {
    return OrderCommentModel(
      id: JsonUtils.asIntOrNull(json['id']),
      userId: JsonUtils.asIntOrNull(json['user_id']),
      orderId: JsonUtils.asIntOrNull(json['order_id']),
      comment: JsonUtils.asStringOrNull(json['comment']),
      commentType: JsonUtils.asStringOrNull(json['comment_type']),
      isInternal: JsonUtils.asBoolOrNull(json['is_internal']),
      attachmentUrl: JsonUtils.asStringOrNull(json['attachment_url']),
      isActive: JsonUtils.asBoolOrNull(json['is_active']),
      isDeleted: JsonUtils.asBoolOrNull(json['is_deleted']),
      createdBy: JsonUtils.asIntOrNull(json['created_by']),
      updatedBy: JsonUtils.asIntOrNull(json['updated_by']),
      deletedBy: JsonUtils.asIntOrNull(json['deleted_by']),
      createdAt: JsonUtils.asStringOrNull(json['created_at']),
      updatedAt: JsonUtils.asStringOrNull(json['updated_at']),
      deletedAt: JsonUtils.asStringOrNull(json['deleted_at']),
      humanizeCommentType: JsonUtils.asStringOrNull(
        json['humanize_comment_type'],
      ),
    );
  }
}

class OrderCommentResponse {
  final bool isSuccess;
  final String message;
  final OrderCommentModel? payload;

  OrderCommentResponse({
    required this.isSuccess,
    required this.message,
    this.payload,
  });

  factory OrderCommentResponse.fromJson(Map<String, dynamic> json) {
    final payloadMap = JsonUtils.asMapOrNull(json['payload']);
    return OrderCommentResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: payloadMap != null
          ? OrderCommentModel.fromJson(payloadMap)
          : null,
    );
  }
}

class OrderCommentListResponse {
  final bool isSuccess;
  final String message;
  final List<OrderCommentModel> payload;
  final PaginationModel? pagination;

  OrderCommentListResponse({
    required this.isSuccess,
    required this.message,
    required this.payload,
    this.pagination,
  });

  factory OrderCommentListResponse.fromJson(Map<String, dynamic> json) {
    return OrderCommentListResponse(
      isSuccess: JsonUtils.asBool(json['success']),
      message: JsonUtils.asString(json['message']),
      payload: JsonUtils.asModelList(
        json['payload'],
        OrderCommentModel.fromJson,
      ),
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(JsonUtils.asMapOrNull(json['pagination']))
          : null,
    );
  }
}
