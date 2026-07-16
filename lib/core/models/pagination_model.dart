import 'package:modfirstpos/core/utils/json_utils.dart';

class PaginationModel {
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;
  final bool? hasNext;
  final bool? hasPrev;

  PaginationModel({
    this.page,
    this.limit,
    this.total,
    this.totalPages,
    this.hasNext,
    this.hasPrev,
  });

  factory PaginationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PaginationModel();
    return PaginationModel(
      page: JsonUtils.asIntOrNull(json['page']),
      limit: JsonUtils.asIntOrNull(json['limit']),
      total: JsonUtils.asIntOrNull(json['total']),
      totalPages: JsonUtils.asIntOrNull(json['totalPages']),
      hasNext: JsonUtils.asBoolOrNull(json['hasNext']),
      hasPrev: JsonUtils.asBoolOrNull(json['hasPrev']),
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'limit': limit,
        'total': total,
        'totalPages': totalPages,
        'hasNext': hasNext,
        'hasPrev': hasPrev,
      };
}
