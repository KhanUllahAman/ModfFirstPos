import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:modfirstpos/core/storage/secure_storage_service.dart';

/// Salted one-way hash for the screen-lock PIN, so it can be verified
/// offline (stored via [SecureStorageService.savePinHash]) without ever
/// persisting the PIN itself in plain text on-device.
///
/// The salt is random per device install (see
/// [SecureStorageService.getOrCreatePinSalt]) rather than a fixed constant,
/// so a leaked hash can't be attacked with a rainbow table precomputed
/// against every install sharing the same salt.
class PinHashUtil {
  PinHashUtil._();

  static Future<String> hash(String pin) async {
    final salt = await SecureStorageService.getOrCreatePinSalt();
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }
}
