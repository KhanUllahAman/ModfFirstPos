/// Defensive JSON parsing helpers.
///
/// The backend may send the same field as `"1"`, `1`, `1.0`, `true` or `null`
/// between releases. Every model `fromJson` must go through these helpers so a
/// type change never crashes the app.
class JsonUtils {
  JsonUtils._();

  /// Parses [value] into an [int], or returns null.
  static int? asIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is bool) return value ? 1 : 0;
    if (value is String) {
      return int.tryParse(value.trim()) ??
          double.tryParse(value.trim())?.toInt();
    }
    return null;
  }

  static int asInt(dynamic value, {int fallback = 0}) =>
      asIntOrNull(value) ?? fallback;

  /// Parses [value] into a [double], or returns null.
  static double? asDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static double asDouble(dynamic value, {double fallback = 0.0}) =>
      asDoubleOrNull(value) ?? fallback;

  /// Parses [value] into a [String], or returns null. Empty strings stay
  /// empty; non-string scalars are stringified.
  static String? asStringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }

  static String asString(dynamic value, {String fallback = ''}) =>
      asStringOrNull(value) ?? fallback;

  /// Parses truthy backend values: true, "true", "1", 1, 1.0, "yes".
  static bool? asBoolOrNull(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final v = value.trim().toLowerCase();
      if (v == 'true' || v == '1' || v == 'yes') return true;
      if (v == 'false' || v == '0' || v == 'no' || v == '') return false;
    }
    return null;
  }

  static bool asBool(dynamic value, {bool fallback = false}) =>
      asBoolOrNull(value) ?? fallback;

  /// Returns [value] as a `Map<String, dynamic>` or null.
  static Map<String, dynamic>? asMapOrNull(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }

  static Map<String, dynamic> asMap(dynamic value) =>
      asMapOrNull(value) ?? <String, dynamic>{};

  /// Maps a JSON list of objects into models, skipping malformed entries.
  static List<T> asModelList<T>(
    dynamic value,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (value is! List) return <T>[];
    final result = <T>[];
    for (final item in value) {
      final map = asMapOrNull(item);
      if (map == null) continue;
      try {
        result.add(fromJson(map));
      } catch (_) {
        // Skip entries the model cannot parse instead of failing the batch.
      }
    }
    return result;
  }

  /// Maps a JSON list into strings, skipping nulls.
  static List<String> asStringList(dynamic value) {
    if (value is! List) return <String>[];
    return value.where((e) => e != null).map((e) => e.toString()).toList();
  }
}
