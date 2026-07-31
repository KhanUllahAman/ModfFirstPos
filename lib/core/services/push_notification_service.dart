import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/modules/bootstrap/controller/bootstrap_controller.dart';
import 'package:modfirstpos/modules/notification/service/notification_service.dart';
import 'package:modfirstpos/routes/app_routes.dart';

/// Everything the incoming `data` map of a push carries — see
/// docs/NOTIFICATIONS_FLUTTER.md. All FCM data values are strings; the
/// numeric getters parse them defensively.
class PushData {
  final String event;
  final String entityType;
  final String? entityId;
  final String? sync;
  final String? notificationId;
  final Map<String, String> raw;

  PushData(Map<String, dynamic> d)
      : event = '${d['event'] ?? ''}',
        entityType = '${d['entity_type'] ?? ''}',
        entityId = d['entity_id'] as String?,
        sync = d['sync'] as String?,
        notificationId = d['notification_id'] as String?,
        raw = d.map((k, v) => MapEntry(k, '$v'));

  int? get quantity => int.tryParse(raw['quantity'] ?? '');
  int? get productId => int.tryParse(raw['product_id'] ?? '');
}

const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
  'modfirst_pos_default',
  'ModFirst POS Notifications',
  description: 'Order, inventory and catalogue alerts',
  importance: Importance.high,
);

/// Runs entirely outside the app's normal widget tree, so it must be a
/// top-level (or static) function and re-initialize anything it needs.
/// Only registered from the cashier flavor's main() — the customer app
/// never touches Firebase.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('PushNotification (background): ${message.messageId} ${message.data}');
}

/// Cashier-only. Wires FCM (foreground/background/tap) to local
/// notifications (so a banner shows while the app is open) and to the
/// backend's device-token + in-app notification feed.
class PushNotificationService extends GetxService {
  final NotificationService _service = NotificationService();
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  final RxInt unreadCount = 0.obs;

  Future<PushNotificationService> init() async {
    await _initLocalNotifications();
    await _requestPermissions();

    FirebaseMessaging.onMessage.listen((m) => _handle(m, tapped: false));
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _handle(m, tapped: true));

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _handle(initial, tapped: true);

    unawaited(refreshUnreadCount());
    return this;
  }

  /// The device's current FCM token — sent as part of the verify-otp
  /// request body (backend registers it there instead of a separate call).
  Future<String?> getToken() => FirebaseMessaging.instance.getToken();

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_defaultChannel);
  }

  Future<void> _requestPermissions() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  /// Call on logout — stops this device from receiving further push.
  Future<void> removeToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;
      await _service.removeDeviceToken(fcmToken);
    } catch (e) {
      log('PushNotificationService removeToken error: $e');
    }
  }

  Future<void> refreshUnreadCount() async {
    unreadCount.value = await _service.fetchUnreadCount();
  }

  void _handle(RemoteMessage message, {required bool tapped}) {
    final data = PushData(message.data);

    // Keep the offline catalogue cache fresh — matches
    // docs/NOTIFICATIONS_FLUTTER.md section 5.3.
    if (data.sync == 'catalogue' && Get.isRegistered<BootstrapController>()) {
      unawaited(Get.find<BootstrapController>().syncBootstrap(showSnackbar: false));
    }

    unawaited(refreshUnreadCount());

    if (tapped) {
      if (data.notificationId != null) {
        final id = int.tryParse(data.notificationId!);
        if (id != null) unawaited(_service.markRead(id));
      }
      Get.toNamed(Routes.notification);
    } else {
      final notification = message.notification;
      if (notification != null) {
        _showLocalBanner(
          title: notification.title ?? 'ModFirst POS',
          body: notification.body ?? '',
        );
      }
    }
  }

  int _notificationIdCounter = 0;

  Future<void> _showLocalBanner({required String title, required String body}) async {
    await _local.show(
      _notificationIdCounter++,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _defaultChannel.id,
          _defaultChannel.name,
          channelDescription: _defaultChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
