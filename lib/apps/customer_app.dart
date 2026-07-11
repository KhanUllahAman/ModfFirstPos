import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modfirstpos/core/binding/customer_initial_binding.dart';
import 'package:modfirstpos/modules/customerDisplay/binding/customer_display_binding.dart';
import 'package:modfirstpos/modules/customerDisplay/view/customer_display_view.dart';
import 'package:modfirstpos/modules/customerDisplay/view/customer_pairing_view.dart';

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ModFirst Customer Display',
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
      initialBinding: CustomerInitialBinding(),
      initialRoute: '/pairing',
      getPages: [
        GetPage(
          name: '/pairing',
          page: () => const CustomerPairingView(),
        ),
        GetPage(
          name: '/customer-display',
          page: () => const CustomerDisplayView(),
          binding: CustomerDisplayBinding(),
        ),
      ],
    );
  }
}