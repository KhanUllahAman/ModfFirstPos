// import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:mjafferjeesapp/core/NotificationService/notification_service.dart';
// import 'package:mjafferjeesapp/core/storage/secure_storage_service.dart';
// import 'package:mjafferjeesapp/core/utils/colors.dart';
// import 'package:mjafferjeesapp/modules/auth/service/auth_service.dart';
// import 'package:mjafferjeesapp/modules/auth/service/product_service.dart';
// import 'package:mjafferjeesapp/routes/app_routes.dart';
// import 'package:mjafferjeesapp/shared/widgets/CircularProgressIndicator/circular_progress_indicator.dart';
// import 'package:mjafferjeesapp/shared/widgets/helperFunction/get_device_id_function.dart';
// import '../../../shared/widgets/Snackbar/custom_snackbar.dart';

class AuthController extends GetxController {
  // final AuthService _authService = Get.find<AuthService>();
  // final ProductService _productService = Get.find<ProductService>();

  final TextEditingController storeNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  String? validateStoreName(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Store name is required' : null;

  String? validatePassword(String? value) =>
      (value == null || value.isEmpty) ? 'Password is required' : null;

  // Future<void> login(GlobalKey<FormState> formKey) async {
  //   if (!formKey.currentState!.validate()) return;

  //   final username = storeNameController.text.trim();
  //   final password = passwordController.text.trim();
  //   const acno = 'LHE-00838';
  //   final deviceId = await GetDeviceIdFunction().getPersistentDeviceId();
  //   final fcmToken = NotificationService().fcmToken;

  //   bool deviceBlocked = false; // ← flag add kiya

  //   CustomLoadingDialog.show();
  //   try {
  //     final loginResponse = await _authService.login(
  //       userName: username,
  //       password: password,
  //       acno: acno,
  //       deviceId: deviceId,
  //       fcmToken: fcmToken.toString(),
  //       platform: 'mjafferjees',
  //       type: 'login',
  //     );

  //     if (!loginResponse.isSuccess) {
  //       CustomLoadingDialog.hide();
  //       customSnackBar(
  //         'Error',
  //         loginResponse.message,
  //         snackBarType: SnackBarType.error,
  //       );
  //       return;
  //     }

  //     final outlet = loginResponse.payload?.outlet;
  //     if (outlet != null && !outlet.isDeviceActive) {
  //       deviceBlocked = true; // ← flag set karo
  //       CustomLoadingDialog.hide();
  //       Get.dialog(
  //         AlertDialog(
  //           backgroundColor: ColorResources.backgroundColor,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           title: const Row(
  //             children: [
  //               Icon(Icons.error_outline, color: Colors.red),
  //               SizedBox(width: 8),
  //               Text('Device Not Registered'),
  //             ],
  //           ),
  //           content: const Text(
  //             'Your device ID is not registered.\nPlease contact Orio team.',
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Get.back(),
  //               child: Text(
  //                 'OK',
  //                 style: TextStyle(color: ColorResources.appAccentColor),
  //               ),
  //             ),
  //           ],
  //         ),
  //         barrierDismissible: false,
  //       );
  //       return;
  //     }

  //     await SecureStorageService.saveLoginData(
  //       payload: loginResponse.payload,
  //       username: username,
  //       password: password,
  //       acno: acno,
  //     );

  //     try {
  //       final productResponse = await _productService.fetchProducts();
  //       if (productResponse.isSuccess && productResponse.payload != null) {
  //         await SecureStorageService.saveProductData(productResponse.payload!);
  //         await SecureStorageService.saveUserName(username);
  //         await SecureStorageService.savePassword(password);

  //         log(
  //           "Products saved: ${productResponse.payload!.detail.length} items",
  //         );
  //       }
  //     } catch (e) {
  //       log("Product fetch error (non-fatal): $e");
  //     }

  //     CustomLoadingDialog.hide();
  //     customSnackBar(
  //       'Success',
  //       loginResponse.message,
  //       snackBarType: SnackBarType.success,
  //     );
  //     Get.toNamed(Routes.home);
  //   } catch (e) {
  //     log("Login error: $e");
  //     CustomLoadingDialog.hide();
  //     customSnackBar(
  //       'Error',
  //       'Something went wrong. Please try again.',
  //       snackBarType: SnackBarType.error,
  //     );
  //   } finally {
  //     if (!deviceBlocked) CustomLoadingDialog.forceHide();
  //   }
  // }

  // @override
  // void onClose() {
  //   storeNameController.dispose();
  //   passwordController.dispose();
  //   super.onClose();
  // }
}
