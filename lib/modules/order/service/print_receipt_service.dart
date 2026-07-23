import 'dart:convert';
import 'dart:developer';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/order/model/print_receipt_model.dart';

class PrintReceiptService {
  final NetworkClient _client = NetworkClient();

  Future<PrintReceiptResponse> getReceiptData(int orderId) async {
    try {
      final response = await _client.post(
        endpoint: ApiConstants.printReceiptEndpoint,
        body: {'order_id': orderId},
        showErrorSnackbar: false,
      );
      final Map<String, dynamic> data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data?.toString() ?? '{}')
                as Map<String, dynamic>;
      return PrintReceiptResponse.fromJson(data);
    } catch (e) {
      log("PrintReceiptService getReceiptData error: $e");
      return PrintReceiptResponse(isSuccess: false, message: e.toString());
    }
  }
}
