import 'dart:convert';
import 'dart:developer';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/shift/model/shift_model.dart';

class ShiftService {
  final NetworkClient _client = NetworkClient();

  Map<String, dynamic> _parse(dynamic data) {
    return data is Map<String, dynamic>
        ? data
        : jsonDecode(data?.toString() ?? '{}') as Map<String, dynamic>;
  }

  Future<ShiftResponse> updateStatus({
    required int shiftId,
    required String status,
  }) async {
    try {
      final response = await _client.put(
        endpoint: ApiConstants.posShiftStatusEndpoint(shiftId),
        body: {'status': status},
        showErrorSnackbar: false,
      );
      return ShiftResponse.fromJson(_parse(response.data));
    } catch (e) {
      log("ShiftService updateStatus error: $e");
      return ShiftResponse(isSuccess: false, status: 0, message: e.toString());
    }
  }

  Future<ShiftResponse> closeShift({
    required int shiftId,
    required double countedCash,
    String? closingNotes,
  }) async {
    try {
      final response = await _client.put(
        endpoint: ApiConstants.posShiftCloseEndpoint(shiftId),
        body: {
          'counted_cash': countedCash,
          if (closingNotes != null && closingNotes.isNotEmpty)
            'closing_notes': closingNotes,
        },
        showErrorSnackbar: false,
      );
      return ShiftResponse.fromJson(_parse(response.data));
    } catch (e) {
      log("ShiftService closeShift error: $e");
      return ShiftResponse(isSuccess: false, status: 0, message: e.toString());
    }
  }

  Future<ShiftReceiptResponse> printReceiptData({
    required int shiftId,
    String printType = 'thermal_80mm',
  }) async {
    try {
      final response = await _client.post(
        endpoint: ApiConstants.posShiftPrintReceiptEndpoint(shiftId),
        body: {'print_type': printType},
        showErrorSnackbar: false,
      );
      return ShiftReceiptResponse.fromJson(_parse(response.data));
    } catch (e) {
      log("ShiftService printReceiptData error: $e");
      return ShiftReceiptResponse(isSuccess: false, message: e.toString());
    }
  }
}
