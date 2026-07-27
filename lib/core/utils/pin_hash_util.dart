import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Salted one-way hash for the screen-lock PIN, so it can be verified
/// offline (stored via [SecureStorageService.savePinHash]) without ever
/// persisting the PIN itself in plain text on-device.
class PinHashUtil {
  PinHashUtil._();

  // Not a secret — just decorrelates this hash from a plain SHA-256 of the
  // raw PIN. The real security boundary is that the PIN only ever verifies
  // successfully offline after it was already confirmed correct online.
  static const _salt = 'modfirstpos_pin_v1';

  static String hash(String pin) {
    final bytes = utf8.encode('$_salt:$pin');
    return sha256.convert(bytes).toString();
  }
}
