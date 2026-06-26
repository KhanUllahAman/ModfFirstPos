import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/binding/initial_binding.dart';
import 'package:modfirstpos/routes/app_pages.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MODFIRST POS',
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}