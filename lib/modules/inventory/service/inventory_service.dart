import 'dart:convert';
import 'dart:developer';
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/modules/inventory/model/inventory_model.dart';

class InventoryService {
  final NetworkClient _client = NetworkClient();

  Map<String, dynamic> _parse(dynamic data) {
    return data is Map<String, dynamic>
        ? data
        : jsonDecode(data?.toString() ?? '{}') as Map<String, dynamic>;
  }

  Future<InventoryResponse> increase({
    required int productId,
    int? variantId,
    required int quantity,
    InventoryReason? reason,
    String? notes,
  }) async {
    try {
      final response = await _client.post(
        endpoint: ApiConstants.inventoryIncreaseEndpoint,
        body: {
          'product_id': productId,
          if (variantId != null) 'variant_id': variantId,
          'quantity': quantity,
          if (reason != null) 'reason': reason.value,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        showErrorSnackbar: false,
      );
      return InventoryResponse.fromJson(_parse(response.data));
    } catch (e) {
      log("InventoryService increase error: $e");
      return InventoryResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<InventoryResponse> decrease({
    required int productId,
    int? variantId,
    required int quantity,
    InventoryReason? reason,
    String? notes,
  }) async {
    try {
      final response = await _client.post(
        endpoint: ApiConstants.inventoryDecreaseEndpoint,
        body: {
          'product_id': productId,
          if (variantId != null) 'variant_id': variantId,
          'quantity': quantity,
          if (reason != null) 'reason': reason.value,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        showErrorSnackbar: false,
      );
      return InventoryResponse.fromJson(_parse(response.data));
    } catch (e) {
      log("InventoryService decrease error: $e");
      return InventoryResponse(isSuccess: false, message: e.toString());
    }
  }

  Future<InventoryResponse> adjust({
    required int productId,
    int? variantId,
    required int quantity,
    String? notes,
  }) async {
    try {
      final response = await _client.post(
        endpoint: ApiConstants.inventoryAdjustEndpoint,
        body: {
          'product_id': productId,
          if (variantId != null) 'variant_id': variantId,
          'quantity': quantity,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
        showErrorSnackbar: false,
      );
      return InventoryResponse.fromJson(_parse(response.data));
    } catch (e) {
      log("InventoryService adjust error: $e");
      return InventoryResponse(isSuccess: false, message: e.toString());
    }
  }
}
