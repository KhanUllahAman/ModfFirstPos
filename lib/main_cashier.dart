import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/apps/cashier_app.dart';
import 'package:modfirstpos/core/network/app_config_apikey.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'package:modfirstpos/core/services/push_notification_service.dart';
import 'package:modfirstpos/firebase_options.dart';
import 'core/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => AppThemeService().init(), permanent: true);
  await dotenv.load(fileName: ".env");
  AppConfig.validate();

  // Firebase is cashier-only — the customer app never initializes it.
  // PushNotificationService itself is registered in InitialBinding (it
  // needs ConnectivityService/NetworkClient, which aren't ready until
  // GetMaterialApp builds) — here we only set up what has to run before
  // that: Firebase itself and the background message handler.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: ColorResources.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const CashierApp());
}