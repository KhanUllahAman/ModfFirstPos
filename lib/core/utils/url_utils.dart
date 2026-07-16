/// URL helpers shared by API models.
class UrlUtils {
  UrlUtils._();

  /// Default host for media served from the commerce backend.
  static const String mediaBaseHost = 'https://command.modfirst.com';

  /// Normalizes a backend image path into an absolute URL.
  ///
  /// Leaves absolute URLs and sentinel values (e.g. `default-user.png`)
  /// untouched. Relative paths are resolved against [baseHost] under
  /// `/uploads`.
  static String? resolveImageUrl(
    String? raw, {
    String baseHost = mediaBaseHost,
    Set<String> passthrough = const {'default-user.png'},
  }) {
    if (raw == null || raw.trim().isEmpty) return raw;
    final url = raw.trim();
    if (url.startsWith('http')) return url;
    if (passthrough.contains(url)) return url;
    if (url.startsWith('/uploads')) return '$baseHost$url';
    final normalized = url.startsWith('/') ? url : '/$url';
    return '$baseHost/uploads$normalized';
  }
}
