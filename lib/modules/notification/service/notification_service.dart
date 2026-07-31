import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart' show Response;
import 'package:modfirstpos/core/network/api_endpoints.dart';
import 'package:modfirstpos/core/network/network_client.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';

class NotificationApiResult {
  final bool isSuccess;
  final String message;
  final List<Map<String, dynamic>> payload;
  final int unreadCount;
  final int total;

  NotificationApiResult({
    required this.isSuccess,
    required this.message,
    this.payload = const [],
    this.unreadCount = 0,
    this.total = 0,
  });
}

class NotificationService {
  final NetworkClient _client = NetworkClient();

  Map<String, dynamic> _asMap(Response response) {
    return response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : jsonDecode(response.data?.toString() ?? '{}') as Map<String, dynamic>;
  }

  /// The logged-in staff user's own notifications.
  Future<NotificationApiResult> fetchMyNotifications({
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final response = await _client.post(
        endpoint: ApiConstants.notificationMyEndpoint,
        body: {'page': page, 'limit': limit, 'sort': 'newest'},
        showErrorSnackbar: false,
      );
      final data = _asMap(response);
      final payload = data['payload'];
      final summary = JsonUtils.asMapOrNull(data['summary']) ?? const {};
      return NotificationApiResult(
        isSuccess: JsonUtils.asBool(data['success']),
        message: JsonUtils.asString(data['message']),
        payload: payload is List
            ? payload.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
            : const [],
        unreadCount: JsonUtils.asInt(summary['unread_count']),
        total: JsonUtils.asInt(summary['total']),
      );
    } catch (e) {
      log('NotificationService fetchMyNotifications error: $e');
      return NotificationApiResult(isSuccess: false, message: e.toString());
    }
  }

  Future<int> fetchUnreadCount() async {
    try {
      final response = await _client.get(
        endpoint: ApiConstants.notificationUnreadCountEndpoint,
        showErrorSnackbar: false,
      );
      final data = _asMap(response);
      final payload = JsonUtils.asMapOrNull(data['payload']) ?? const {};
      return JsonUtils.asInt(payload['unread_count']);
    } catch (e) {
      log('NotificationService fetchUnreadCount error: $e');
      return 0;
    }
  }

  Future<bool> markRead(int id) async {
    try {
      final response = await _client.patch(
        endpoint: ApiConstants.notificationMarkReadEndpoint(id),
        body: const {},
        showErrorSnackbar: false,
      );
      return JsonUtils.asBool(_asMap(response)['success']);
    } catch (e) {
      log('NotificationService markRead error: $e');
      return false;
    }
  }

  Future<bool> markAllRead() async {
    try {
      final response = await _client.patch(
        endpoint: ApiConstants.notificationMarkAllReadEndpoint,
        body: const {},
        showErrorSnackbar: false,
      );
      return JsonUtils.asBool(_asMap(response)['success']);
    } catch (e) {
      log('NotificationService markAllRead error: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(int id) async {
    try {
      final response = await _client.delete(
        endpoint: ApiConstants.notificationDeleteEndpoint(id),
        showErrorSnackbar: false,
      );
      return JsonUtils.asBool(_asMap(response)['success']);
    } catch (e) {
      log('NotificationService deleteNotification error: $e');
      return false;
    }
  }

  /// Removes this device's token so it stops receiving push — call on
  /// logout.
  Future<void> removeDeviceToken(String token) async {
    try {
      await _client.delete(
        endpoint: ApiConstants.notificationDeviceTokenEndpoint,
        body: {'token': token},
        showErrorSnackbar: false,
      );
    } catch (e) {
      log('NotificationService removeDeviceToken error: $e');
    }
  }
}
