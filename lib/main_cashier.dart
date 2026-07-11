import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/apps/cashier_app.dart';
import 'package:modfirstpos/core/network/app_config_apikey.dart';
import 'package:modfirstpos/core/services/app_theme_service.dart';
import 'core/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => AppThemeService().init(), permanent: true);
  await dotenv.load(fileName: ".env");
  AppConfig.validate();

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