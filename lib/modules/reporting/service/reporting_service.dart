import 'dart:developer';

import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';

class ReportingService {
  final NetworkClient _client = NetworkClient();

  Future<List<int>> fetchDurationReportExcel({
    String period = 'this_month',
    String? startDate,
    String? endDate,
    String? sortBy,
    String? sortOrder,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final body = <String, dynamic>{'period': period};
      if (period == 'custom') {
        if (startDate != null) body['startDate'] = startDate;
        if (endDate != null) body['endDate'] = endDate;
      }
      if (sortBy != null && sortBy.isNotEmpty) body['sortBy'] = sortBy;
      if (sortOrder != null && sortOrder.isNotEmpty) {
        body['sortOrder'] = sortOrder;
      }
      if (filters != null && filters.isNotEmpty) body['filters'] = filters;

      final response = await _client.postBytes(
        endpoint: ApiConstants.reportsDurationExcelEndpoint,
        body: body,
        showErrorSnackbar: false,
      );

      return response.data ?? const [];
    } catch (e) {
      log("ReportingService fetchDurationReportExcel error: $e");
      rethrow;
    }
  }
}
