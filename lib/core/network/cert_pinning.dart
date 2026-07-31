import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// SHA-256 hashes (base64) of the SPKI (public key) of the certificates we
/// trust for [_pinnedHost]. Pinning the public key instead of the raw cert
/// means the pin survives a plain cert *renewal* (same key, new expiry) —
/// it only breaks if ModFirst switches to a brand-new key pair or changes
/// certificate authority.
///
/// Pins included (fetched 2026-07-31 via `openssl s_client`):
///   - Leaf   (command.modfirst.com)      — breaks if the private key is rotated.
///   - Issuer (Let's Encrypt intermediate) — backup pin; survives leaf-key rotation
///     as long as Let's Encrypt keeps issuing from the same intermediate.
///
/// IMPORTANT (maintenance note): if ModFirst ever rotates to a new private
/// key or changes certificate authority, API calls will start failing with
/// a pinning error until this list is updated with the new SPKI hash. Re-run:
///   openssl s_client -connect command.modfirst.com:443 -servername command.modfirst.com -showcerts
/// and hash each cert's SPKI with sha256/base64 to get fresh values.
const List<String> _pinnedSpkiSha256 = [
  'NCVtqKX814K+n4d8OctCcc9MXDTPSrknTiLrC8MV+jw=', // leaf: command.modfirst.com
  'brzvtCELCIZUo4sD/qPX0ccRtPsd3DY6RfmxpOU9oB4=', // issuer: Let's Encrypt intermediate (YE1)
];

const String _pinnedHost = 'command.modfirst.com';

/// Validates [cert]'s SPKI hash against [_pinnedSpkiSha256] for
/// [_pinnedHost]. Wired into Dio's [IOHttpClientAdapter.validateCertificate],
/// which — unlike [HttpClient.badCertificateCallback] — runs for every
/// connection (trusted or not), which is what real pinning requires.
bool validatePinnedCertificate(X509Certificate cert, String host, int port) {
  if (host != _pinnedHost) return true;

  try {
    final spkiDer = _extractSpkiDer(cert.der);
    final hash = base64.encode(sha256.convert(spkiDer).bytes);
    if (_pinnedSpkiSha256.contains(hash)) return true;
    if (kDebugMode) {
      log('CertPinning: REJECTED $host — spki=$hash not in pinned set');
    }
    return false;
  } catch (e) {
    if (kDebugMode) log('CertPinning: error validating $host: $e');
    return false;
  }
}

/// Extracts the DER-encoded SubjectPublicKeyInfo from a DER-encoded X.509
/// certificate by walking the ASN.1 TBSCertificate structure, avoiding a
/// dependency on a full ASN.1 parsing package for a single field.
List<int> _extractSpkiDer(Uint8List certDer) {
  int pos = 0;

  int readLength(List<int> data, int p) {
    final first = data[p];
    if (first < 0x80) return first;
    final numBytes = first & 0x7F;
    int len = 0;
    for (var i = 0; i < numBytes; i++) {
      len = (len << 8) | data[p + 1 + i];
    }
    return len;
  }

  int lengthFieldSize(List<int> data, int p) {
    final first = data[p];
    return first < 0x80 ? 1 : 1 + (first & 0x7F);
  }

  // Certificate ::= SEQUENCE { tbsCertificate, ... }
  if (certDer[pos] != 0x30) throw const FormatException('not a SEQUENCE');
  pos = 1 + lengthFieldSize(certDer, 1);

  // TBSCertificate ::= SEQUENCE { ... }
  if (certDer[pos] != 0x30) throw const FormatException('no tbsCertificate');
  final tbsHeaderLen = 1 + lengthFieldSize(certDer, pos + 1);
  int cur = pos + tbsHeaderLen;

  int skipTlv(int p) {
    final lenSize = lengthFieldSize(certDer, p + 1);
    final len = readLength(certDer, p + 1);
    return p + 1 + lenSize + len;
  }

  // version (optional, context [0]) — skip if present
  if (certDer[cur] == 0xA0) cur = skipTlv(cur);
  // serialNumber (INTEGER)
  cur = skipTlv(cur);
  // signature (SEQUENCE)
  cur = skipTlv(cur);
  // issuer (SEQUENCE)
  cur = skipTlv(cur);
  // validity (SEQUENCE)
  cur = skipTlv(cur);
  // subject (SEQUENCE)
  cur = skipTlv(cur);
  // subjectPublicKeyInfo (SEQUENCE) — this is what we want, whole TLV
  final spkiStart = cur;
  final spkiEnd = skipTlv(cur);
  return certDer.sublist(spkiStart, spkiEnd);
}
