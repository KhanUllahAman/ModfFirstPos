import 'dart:math';
import 'package:modfirstpos/shared/widgets/helperFunction/get_device_id_function.dart';

/// Generic offline-record idempotency key generator — used for both
/// shift and order sync payloads (`client_reference`). Combines the
/// device's persistent id with a timestamp + random suffix so keys never
/// collide across devices or within the same device.
class ClientReferenceGenerator {
  ClientReferenceGenerator._();

  static Future<String> generate(String prefix) async {
    final deviceId = await AppInfo.getDeviceId();
    final safeDeviceId = deviceId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(900000) + 100000;
    return '$prefix-$safeDeviceId-$timestamp-$rand';
  }
}
