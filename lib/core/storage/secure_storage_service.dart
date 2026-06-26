// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:mjafferjeesapp/core/NotificationService/product_notification_model.dart';
// import 'package:mjafferjeesapp/core/contants/storage_keys.dart';
// import 'package:mjafferjeesapp/modules/auth/model/auth_model.dart';
// import 'package:mjafferjeesapp/modules/auth/model/product_model.dart';
// import 'package:mjafferjeesapp/modules/home/model/suspended_session.dart';

// class SecureStorageService {
//   static const _storage = FlutterSecureStorage();

//   static Future<void> _write(String key, String value) =>
//       _storage.write(key: key, value: value);

//   static Future<String?> _read(String key) => _storage.read(key: key);

//   static Future<void> _delete(String key) => _storage.delete(key: key);

//   static Future<void> savePinnedProducts(List<ProductItem> products) => _write(
//     StorageKeys.keyPinnedProducts,
//     jsonEncode(products.map((p) => p.toJson()).toList()),
//   );

//   static Future<List<ProductItem>> getPinnedProducts() async {
//     final raw = await _read(StorageKeys.keyPinnedProducts);
//     if (raw == null || raw.isEmpty) return [];
//     try {
//       return (jsonDecode(raw) as List)
//           .map((e) => ProductItem.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       log("getPinnedProducts error: $e");
//       return [];
//     }
//   }

//   static Future<void> saveToken(String token) =>
//       _write(StorageKeys.keyToken, token);
//   static Future<String?> getToken() => _read(StorageKeys.keyToken);

//   static Future<void> saveUserId(String id) =>
//       _write(StorageKeys.keyUserId, id);
//   static Future<String?> getUserId() => _read(StorageKeys.keyUserId);

//   static Future<void> saveEmpNo(String empNo) =>
//       _write(StorageKeys.keyEmpNo, empNo);
//   static Future<String?> getEmpNo() => _read(StorageKeys.keyEmpNo);

//   static Future<void> saveUserName(String name) =>
//       _write(StorageKeys.keyUserName, name);
//   static Future<String?> getUserName() => _read(StorageKeys.keyUserName);

//   static Future<void> savePassword(String password) =>
//       _write(StorageKeys.keyPassword, password);
//   static Future<String?> getPassword() => _read(StorageKeys.keyPassword);

//   static Future<void> saveUserEmail(String email) =>
//       _write(StorageKeys.keyUserEmail, email);
//   static Future<String?> getUserEmail() => _read(StorageKeys.keyUserEmail);

//   static Future<void> saveUserPhone(String phone) =>
//       _write(StorageKeys.keyUserPhone, phone);
//   static Future<String?> getUserPhone() => _read(StorageKeys.keyUserPhone);

//   static Future<void> saveProfilePicture(String url) =>
//       _write(StorageKeys.keyProfilePicture, url);
//   static Future<String?> getProfilePicture() =>
//       _read(StorageKeys.keyProfilePicture);

//   static Future<void> saveUserType(String type) =>
//       _write(StorageKeys.keyUserType, type);
//   static Future<String?> getUserType() => _read(StorageKeys.keyUserType);

//   static Future<void> saveEmployeeId(String id) =>
//       _write(StorageKeys.keyEmployeeId, id);
//   static Future<String?> getEmployeeId() => _read(StorageKeys.keyEmployeeId);
//   static Future<int> getEmployeeIdAsInt() async =>
//       int.tryParse(await _read(StorageKeys.keyEmployeeId) ?? '0') ?? 0;

//   static Future<void> saveDepartmentId(String id) =>
//       _write(StorageKeys.keyDepartmentId, id);
//   static Future<String?> getDepartmentId() =>
//       _read(StorageKeys.keyDepartmentId);

//   static Future<void> saveDesignationId(String id) =>
//       _write(StorageKeys.keyDesignationId, id);
//   static Future<String?> getDesignationId() =>
//       _read(StorageKeys.keyDesignationId);

//   static Future<void> saveUserStatus(String status) =>
//       _write(StorageKeys.keyUserStatus, status);
//   static Future<String?> getUserStatus() => _read(StorageKeys.keyUserStatus);

//   static Future<void> saveUserCnic(String cnic) =>
//       _write(StorageKeys.keyUserCnic, cnic);
//   static Future<String?> getUserCnic() => _read(StorageKeys.keyUserCnic);

//   static Future<void> saveUserAddress(String address) =>
//       _write(StorageKeys.keyUserAddress, address);
//   static Future<String?> getUserAddress() => _read(StorageKeys.keyUserAddress);

//   static Future<void> saveUserDob(String dob) =>
//       _write(StorageKeys.keyUserDob, dob);
//   static Future<String?> getUserDob() => _read(StorageKeys.keyUserDob);

//   static Future<void> saveUserGender(String gender) =>
//       _write(StorageKeys.keyUserGender, gender);
//   static Future<String?> getUserGender() => _read(StorageKeys.keyUserGender);

//   static Future<void> saveJoinDate(String date) =>
//       _write(StorageKeys.keyJoinDate, date);
//   static Future<String?> getJoinDate() => _read(StorageKeys.keyJoinDate);

//   static Future<void> saveMenus(List<dynamic> menus) =>
//       _write(StorageKeys.keyMenus, jsonEncode(menus));

//   static Future<List<Map<String, dynamic>>> getMenus() async {
//     final raw = await _read(StorageKeys.keyMenus);
//     if (raw == null || raw.isEmpty) return [];
//     try {
//       return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
//     } catch (e) {
//       log("getMenus error: $e");
//       return [];
//     }
//   }

//   static Future<void> saveSignature(String sig) =>
//       _write(StorageKeys.keySignature, sig);
//   static Future<String?> getSignature() => _read(StorageKeys.keySignature);

//   static Future<void> saveAuthHeader(String username, String password) {
//     final encoded = base64Encode(utf8.encode('$username:$password'));
//     return _write(StorageKeys.keyAuthHeader, 'Basic $encoded');
//   }

//   static Future<String?> getAuthHeader() => _read(StorageKeys.keyAuthHeader);

//   static Future<void> saveAcno(String acno) =>
//       _write(StorageKeys.keyAcno, acno);
//   static Future<String?> getAcno() => _read(StorageKeys.keyAcno);

//   static Future<void> saveOutletInfo(OutletInfo info) =>
//       _write(StorageKeys.keyOutletInfo, jsonEncode(info.toJson()));

//   static Future<OutletInfo?> getOutletInfo() async {
//     final raw = await _read(StorageKeys.keyOutletInfo);
//     if (raw == null || raw.isEmpty) return null;
//     try {
//       log("OutletInfo: $raw");
//       return OutletInfo.fromJson(jsonDecode(raw));
//     } catch (e) {
//       log("getOutletInfo error: $e");
//       return null;
//     }
//   }

//   static Future<void> saveLocInfo(String locCode, String locName) async {
//     await _write(StorageKeys.keyLocCode, locCode);
//     await _write(StorageKeys.keyLocName, locName);
//   }

//   static Future<String?> getLocCode() => _read(StorageKeys.keyLocCode);
//   static Future<String?> getLocName() => _read(StorageKeys.keyLocName);

//   static Future<void> saveStaffList(List<StaffMember> staff) => _write(
//     StorageKeys.keyStaffList,
//     jsonEncode(staff.map((s) => s.toJson()).toList()),
//   );

//   static Future<List<StaffMember>> getStaffList() async {
//     final raw = await _read(StorageKeys.keyStaffList);
//     if (raw == null || raw.isEmpty) return [];
//     try {
//       return (jsonDecode(raw) as List)
//           .map((e) => StaffMember.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       log("getStaffList error: $e");
//       return [];
//     }
//   }

//   static Future<void> saveServiceCharges(List<OutletOption> charges) => _write(
//     StorageKeys.keyServiceCharges,
//     jsonEncode(charges.map((c) => c.toJson()).toList()),
//   );

//   static Future<List<OutletOption>> getServiceCharges() async {
//     final raw = await _read(StorageKeys.keyServiceCharges);
//     if (raw == null || raw.isEmpty) return [];
//     try {
//       return (jsonDecode(raw) as List)
//           .map((e) => OutletOption.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       log("getServiceCharges error: $e");
//       return [];
//     }
//   }

//   static Future<void> saveCreditCards(List<OutletOption> cards) => _write(
//     StorageKeys.keyCreditCards,
//     jsonEncode(cards.map((c) => c.toJson()).toList()),
//   );

//   static Future<List<OutletOption>> getCreditCards() async {
//     final raw = await _read(StorageKeys.keyCreditCards);
//     if (raw == null || raw.isEmpty) return [];
//     try {
//       return (jsonDecode(raw) as List)
//           .map((e) => OutletOption.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       log("getCreditCards error: $e");
//       return [];
//     }
//   }

//   static Future<void> saveProducts(List<ProductItem> products) => _write(
//     StorageKeys.keyProducts,
//     jsonEncode(products.map((p) => p.toJson()).toList()),
//   );

//   static Future<List<ProductItem>> getProducts() async {
//     final raw = await _read(StorageKeys.keyProducts);
//     if (raw == null || raw.isEmpty) return [];
//     try {
//       log("Products: $raw");
//       return (jsonDecode(raw) as List)
//           .map((e) => ProductItem.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       log("getProducts error: $e");
//       return [];
//     }
//   }

//   static Future<void> saveLoginData({
//     required OutletPayload? payload,
//     required String username,
//     required String password,
//     required String acno,
//   }) async {
//     await saveAuthHeader(username, password);
//     await saveAcno(acno);

//     if (payload == null) return;

//     if (payload.signature != null) await saveSignature(payload.signature!);
//     if (payload.outlet != null) await saveOutletInfo(payload.outlet!);

//     await saveStaffList(payload.staff);
//     await saveServiceCharges(payload.serviceCharges);
//     await saveCreditCards(payload.creditCards);
//   }

//   static Future<void> saveProductData(ProductPayload payload) async {
//     await saveLocInfo(payload.locCode ?? '', payload.locName ?? '');
//     await saveProducts(payload.detail);
//   }

//   static Future<bool> isLoggedIn() async {
//     final sig = await getSignature();
//     return sig != null && sig.isNotEmpty;
//   }

//   static Future<void> saveDiscount({
//     required String type,
//     required double value,
//   }) async {
//     await _write(StorageKeys.keyDiscountType, type);
//     await _write(StorageKeys.keyDiscount, value.toString());
//   }

//   static Future<({String type, double value})?> getDiscount() async {
//     final type = await _read(StorageKeys.keyDiscountType);
//     final raw = await _read(StorageKeys.keyDiscount);
//     if (type == null || raw == null) return null;
//     final value = double.tryParse(raw);
//     if (value == null) return null;
//     return (type: type, value: value);
//   }

//   static Future<void> clearDiscount() async {
//     await _delete(StorageKeys.keyDiscount);
//     await _delete(StorageKeys.keyDiscountType);
//   }

//   static Future<void> addSuspendedSession(SuspendedSession session) async {
//     final existing = await getAllSuspendedSessions();
//     existing.add(session);
//     await _write(
//       StorageKeys.keySuspendedSessions,
//       jsonEncode(existing.map((s) => s.toJson()).toList()),
//     );
//   }

//   static Future<List<SuspendedSession>> getAllSuspendedSessions() async {
//     final raw = await _read(StorageKeys.keySuspendedSessions);
//     if (raw == null || raw.isEmpty) return [];
//     try {
//       return (jsonDecode(raw) as List)
//           .map((e) => SuspendedSession.fromJson(e as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       log('getAllSuspendedSessions error: $e');
//       return [];
//     }
//   }

//   static Future<void> removeSuspendedSession(String id) async {
//     final existing = await getAllSuspendedSessions();
//     existing.removeWhere((s) => s.id == id);
//     await _write(
//       StorageKeys.keySuspendedSessions,
//       jsonEncode(existing.map((s) => s.toJson()).toList()),
//     );
//   }

//   static Future<void> clearAllSuspendedSessions() async {
//     await _delete(StorageKeys.keySuspendedSessions);
//   }

//   // SecureStorageService mein yeh add karo

//   static Future<void> saveAddNotification(ProductAddNotification notif) async {
//     final existing = await getAddNotifications();
//     // duplicate check by skuCode
//     existing.removeWhere((n) => n.skuCode == notif.skuCode);
//     existing.add(notif);
//     await _write(
//       StorageKeys.keyAddNotifications,
//       jsonEncode(existing.map((n) => n.toJson()).toList()),
//     );
//   }

//   static Future<List<ProductAddNotification>> getAddNotifications() async {
//     final raw = await _read(StorageKeys.keyAddNotifications);
//     if (raw == null || raw.isEmpty) return [];
//     try {
//       return (jsonDecode(raw) as List)
//           .map(
//             (e) => ProductAddNotification.fromJson(e as Map<String, dynamic>),
//           )
//           .toList();
//     } catch (e) {
//       log('getAddNotifications error: $e');
//       return [];
//     }
//   }

//   static Future<void> removeAddNotification(String skuCode) async {
//     final existing = await getAddNotifications();
//     existing.removeWhere((n) => n.skuCode == skuCode);
//     await _write(
//       StorageKeys.keyAddNotifications,
//       jsonEncode(existing.map((n) => n.toJson()).toList()),
//     );
//   }

//   static Future<void> saveEditNotification(
//     ProductEditNotification notif,
//   ) async {
//     final existing = await getEditNotifications();
//     existing.removeWhere((n) => n.sku == notif.sku);
//     existing.add(notif);
//     await _write(
//       StorageKeys.keyEditNotifications,
//       jsonEncode(existing.map((n) => n.toJson()).toList()),
//     );
//   }

//   static Future<List<ProductEditNotification>> getEditNotifications() async {
//     final raw = await _read(StorageKeys.keyEditNotifications);
//     if (raw == null || raw.isEmpty) return [];
//     try {
//       return (jsonDecode(raw) as List)
//           .map(
//             (e) => ProductEditNotification.fromJson(e as Map<String, dynamic>),
//           )
//           .toList();
//     } catch (e) {
//       log('getEditNotifications error: $e');
//       return [];
//     }
//   }

//   static Future<void> removeEditNotification(String sku) async {
//     final existing = await getEditNotifications();
//     existing.removeWhere((n) => n.sku == sku);
//     await _write(
//       StorageKeys.keyEditNotifications,
//       jsonEncode(existing.map((n) => n.toJson()).toList()),
//     );
//   }

//   static Future<void> clearAll() => _storage.deleteAll();

//   static Future<void> delete(String key) => _delete(key);
// }
