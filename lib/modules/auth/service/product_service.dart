// import 'dart:developer';

// import 'package:get/get.dart';
// import 'package:mjafferjeesapp/core/network/api_endpoints.dart';
// import 'package:mjafferjeesapp/core/network/network_client.dart';
// import 'package:mjafferjeesapp/core/storage/secure_storage_service.dart';
// import 'package:mjafferjeesapp/modules/auth/model/product_model.dart';

// class ProductService {
//   final NetworkClient _networkClient = Get.find();

//   Future<ProductResponseModel> fetchProducts() async {
//     try {
//       final acno = await SecureStorageService.getAcno() ?? '';

//       final response = await _networkClient.post(
//         endpoint: ApiConstants.baseUrl,
//         body: {"acno": acno, "platform": "mjafferjees", "type": "products"},
//       );
//       log("Products response: ${response.data}");
//       return ProductResponseModel.fromJson(response.data);
//     } catch (e) {
//       log("fetchProducts error: $e");
//       rethrow;
//     }
//   }
// }
