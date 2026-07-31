import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/services/push_notification_service.dart';
import 'package:modfirstpos/core/utils/json_utils.dart';
import 'package:modfirstpos/modules/notification/service/notification_service.dart';

class NotificationItem {
  final int id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type; // bucketed for the existing filter UI
  final String event;
  final String entityType;
  final String? entityId;
  final RxBool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.event = '',
    this.entityType = '',
    this.entityId,
    bool isRead = false,
  }) : isRead = isRead.obs;

  /// Maps a `/notifications/my` row into this widget-facing shape. Backend
  /// entity types today are only product/variant/inventory (catalogue) plus
  /// admin-sent "custom" — bucketed into the existing filter categories.
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final entityType = JsonUtils.asString(json['entity_type']).toLowerCase();
    final event = JsonUtils.asString(json['event']);
    String type;
    switch (entityType) {
      case 'order':
        type = 'Orders';
        break;
      case 'inventory':
        type = 'Inventory';
        break;
      default:
        type = 'System Alert';
    }
    return NotificationItem(
      id: JsonUtils.asInt(json['id']),
      title: JsonUtils.asStringOrNull(json['title']) ?? event,
      description: JsonUtils.asStringOrNull(json['body']) ?? '',
      timestamp:
          DateTime.tryParse(JsonUtils.asStringOrNull(json['created_at']) ?? '') ??
              DateTime.now(),
      type: type,
      event: event,
      entityType: entityType,
      entityId: JsonUtils.asStringOrNull(json['entity_id']),
      isRead: JsonUtils.asBool(json['is_read']),
    );
  }
}

class NotificationController extends GetxController {
  final NotificationService _service = NotificationService();

  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxString selectedFilter = 'All'.obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadCountFromServer = 0.obs;

  final List<String> filterOptions = ['All', 'Orders', 'Inventory', 'System Alert', 'Diagnostics'];

  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    loadNotifications();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      final result = await _service.fetchMyNotifications();
      if (result.isSuccess) {
        notifications.assignAll(result.payload.map(NotificationItem.fromJson));
        unreadCountFromServer.value = result.unreadCount;
        _refreshBellBadge();
      }
    } catch (e) {
      log('NotificationController loadNotifications error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  int get unreadCount => notifications.where((n) => !n.isRead.value).length;

  List<NotificationItem> get filteredNotifications {
    final filter = selectedFilter.value;
    if (filter == 'All') return notifications;
    return notifications.where((n) => n.type.toLowerCase() == filter.toLowerCase()).toList();
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> markAsRead(NotificationItem item) async {
    if (item.isRead.value) return;
    item.isRead.value = true;
    notifications.refresh();
    await _service.markRead(item.id);
    _refreshBellBadge();
  }

  Future<void> markAllAsRead() async {
    for (final n in notifications) {
      n.isRead.value = true;
    }
    notifications.refresh();
    await _service.markAllRead();
    _refreshBellBadge();
  }

  void _refreshBellBadge() {
    if (Get.isRegistered<PushNotificationService>()) {
      Get.find<PushNotificationService>().refreshUnreadCount();
    }
  }

  Future<void> removeNotification(NotificationItem item) async {
    notifications.remove(item);
    await _service.deleteNotification(item.id);
  }

  Future<void> clearAll() async {
    final items = List<NotificationItem>.from(notifications);
    notifications.clear();
    for (final item in items) {
      await _service.deleteNotification(item.id);
    }
  }
}
