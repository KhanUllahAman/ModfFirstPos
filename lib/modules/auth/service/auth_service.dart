// import 'dart:developer';
// import 'package:get/get.dart';
// import 'package:mjafferjeesapp/core/network/api_endpoints.dart';
// import 'package:mjafferjeesapp/core/network/network_client.dart';
// import 'package:mjafferjeesapp/modules/auth/model/auth_model.dart';

// class AuthService {
//   final NetworkClient _networkClient = Get.find();

//   Future<OutletResponseModel> login({
//     required String userName,
//     required String password,
//     required String acno,
//     required String deviceId,
//     required String platform,
//     required String type,
//     required String fcmToken,
//   }) async {
//     try {
//       final body = {
//         "username": userName,
//         "password": password,
//         "acno": acno,
//         "deviceid": deviceId,
//         "platform": platform,
//         "type": type,
//         'fcm_token': fcmToken,
//       };
//       final response = await _networkClient.post(
//         endpoint: ApiConstants.baseUrl,
//         isLoginRequest: true,
//         body: body,
//       );
//       log("Login response: ${response.data}");
//       log("body login: ${body.toString()}");
//       return OutletResponseModel.fromJson(response.data);
//     } catch (e) {
//       log("AuthService login error: $e");
//       rethrow;
//     }
//   }
// }
