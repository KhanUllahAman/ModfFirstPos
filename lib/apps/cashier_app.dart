import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/binding/initial_binding.dart';
import 'package:modfirstpos/core/lock/app_lock_wrapper.dart';
import 'package:modfirstpos/routes/app_pages.dart';

class CashierApp extends StatelessWidget {
  const CashierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ModFirst Cashier',
      builder: (context, child) => AppLockWrapper(child: child),
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      initialBinding: InitialBinding(),
      initialRoute: AppPages.initial, 
      getPages: AppPages.routes,
    );
  }
}