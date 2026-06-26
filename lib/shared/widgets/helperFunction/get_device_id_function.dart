import 'dart:developer';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:persistent_device_id/persistent_device_id.dart';

class GetDeviceIdFunction {
  Future<String> getPersistentDeviceId() async {
    try {
      final deviceId = await PersistentDeviceId.getDeviceId();
      log("Device id :: $deviceId");
      return deviceId ?? "";
    } catch (e) {
      return 'Error generating ID: $e';
    }
  }
}

class AppInfo {
  static Future<String> getDeviceId() async {
    try {
      final deviceId = await PersistentDeviceId.getDeviceId();
      return deviceId ?? "Unknown";
    } catch (e) {
      return "Error: $e";
    }
  }

  static Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return "${packageInfo.version} (${packageInfo.buildNumber})";
    } catch (e) {
      return "1.0.0"; 
    }
  }
}