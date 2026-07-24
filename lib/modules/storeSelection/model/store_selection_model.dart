import 'dart:developer';

class SaleSelectionModel {
  final bool isSuccess;
  final int status;
  final String message;
  final List<SaleSelectionPayload> payload;

  SaleSelectionModel({
    required this.isSuccess,
    required this.status,
    required this.message,
    this.payload = const [],
  });

  factory SaleSelectionModel.fromJson(Map<String, dynamic> json) {
    final payload = <SaleSelectionPayload>[];
    try {
      final payloadData = json['payload'];
      if (payloadData is List) {
        for (final item in payloadData) {
          if (item is Map<String, dynamic>) {
            payload.add(SaleSelectionPayload.fromJson(item));
          }
        }
      } else if (payloadData is Map<String, dynamic>) {
        // Defensive: backend may switch back to a single-object payload.
        payload.add(SaleSelectionPayload.fromJson(payloadData));
      }
    } catch (e) {
      log("Error parsing store selection payload: $e");
    }

    final rawStatus = json['status'];
    final int parsedStatus = rawStatus is int
        ? rawStatus
        : int.tryParse(rawStatus?.toString() ?? '0') ?? 0;

    return SaleSelectionModel(
      isSuccess: json['success'] == true,
      status: parsedStatus,
      message: json['message']?.toString() ?? '',
      payload: payload,
    );
  }
}

class SaleSelectionPayload {
  final int? id;
  final String? siteName;

  SaleSelectionPayload({
    required this.id,
    required this.siteName,
  });

  factory SaleSelectionPayload.fromJson(Map<String, dynamic> json) {
    return SaleSelectionPayload(
      id: json['id'] ?? 0,
      siteName: json['site_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'site_name': siteName,
      };
}
