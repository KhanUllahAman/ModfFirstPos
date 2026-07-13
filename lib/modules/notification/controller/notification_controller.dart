import 'package:get/get.dart';

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final String type; // 'order', 'system', 'inventory', 'diagnostic'
  final RxBool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    bool isRead = false,
  }) : isRead = isRead.obs;
}

class NotificationController extends GetxController {
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxString selectedFilter = 'All'.obs;

  final List<String> filterOptions = ['All', 'Orders', 'Inventory', 'System Alert', 'Diagnostics'];

  @override
  void onInit() {
    super.onInit();
    loadStaticNotifications();
  }

  void loadStaticNotifications() {
    final now = DateTime.now();
    notifications.assignAll([
      NotificationItem(
        id: '1',
        title: 'New Online Order Received',
        description: 'Order ORD-1783613298805-DVQI0 has been booked by Ammar Ali.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        type: 'Orders',
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Low Stock Warning',
        description: 'Premium Organic Cotton T-Shirt (SKU: TS-ORG-BLK-M-M) is below the reorder point (Remaining: 2).',
        timestamp: now.subtract(const Duration(hours: 1)),
        type: 'Inventory',
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        title: 'Thermal Printer Diagnostic',
        description: 'Failed to establish connection to Thermal Printer at IP: 192.168.1.200.',
        timestamp: now.subtract(const Duration(hours: 3)),
        type: 'Diagnostics',
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: 'POS Client Update Completed',
        description: 'Your terminal was successfully updated to client version 1.0.2.',
        timestamp: now.subtract(const Duration(days: 1)),
        type: 'System Alert',
        isRead: true,
      ),
      NotificationItem(
        id: '5',
        title: 'Store Sync Succeeded',
        description: 'Database synchronization completed. 15 new catalogue items updated.',
        timestamp: now.subtract(const Duration(days: 2)),
        type: 'System Alert',
        isRead: true,
      ),
    ]);
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

  void markAsRead(NotificationItem item) {
    item.isRead.value = true;
    notifications.refresh();
  }

  void markAllAsRead() {
    for (var n in notifications) {
      n.isRead.value = true;
    }
    notifications.refresh();
  }

  void removeNotification(NotificationItem item) {
    notifications.remove(item);
  }

  void clearAll() {
    notifications.clear();
  }
}
