/// URL helpers shared by API models.
class UrlUtils {
  UrlUtils._();

  /// Default host for media served from the commerce backend.
  static const String mediaBaseHost = 'https://storage.modfirst.com';

  /// Normalizes a backend image path into an absolute URL.
  ///
  /// Leaves sentinel values (e.g. `default-user.png`) untouched.
  /// Resolves relative paths against [baseHost] without `/uploads` segment.
  static String? resolveImageUrl(
    String? raw, {
    String baseHost = mediaBaseHost,
    Set<String> passthrough = const {'default-user.png'},
  }) {
    if (raw == null || raw.trim().isEmpty) return raw;
    var url = raw.trim();
    if (passthrough.contains(url)) return url;

    // If it's already an absolute URL, strip any /uploads/ segment if present
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url.replaceAll('/uploads/', '/');
    }

    // Strip leading /uploads/ or uploads/
    while (url.startsWith('/uploads/') || url.startsWith('uploads/')) {
      if (url.startsWith('/uploads/')) {
        url = url.substring('/uploads'.length);
      } else if (url.startsWith('uploads/')) {
        url = url.substring('uploads/'.length - 1);
      }
    }

    final normalized = url.startsWith('/') ? url : '/$url';
    return '$baseHost$normalized';
  }
}
