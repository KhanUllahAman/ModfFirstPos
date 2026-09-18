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
    if (raw == null) return null;
    var url = raw.trim();
    if (url.isEmpty || url.toLowerCase() == 'null') return null;
    if (passthrough.contains(url)) return url;

    // Protocol-relative URLs (e.g. //storage.modfirst.com/...)
    if (url.startsWith('//')) {
      return 'https:$url';
    }

    final cleanBaseHost = baseHost.endsWith('/')
        ? baseHost.substring(0, baseHost.length - 1)
        : baseHost;

    // Full absolute URLs (http:// or https://)
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url.replaceAll('/uploads/', '/');
    }

    // Host without protocol scheme
    if (url.startsWith('storage.modfirst.com') || url.startsWith('www.')) {
      return 'https://${url.replaceAll('/uploads/', '/')}';
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
    return '$cleanBaseHost$normalized';
  }
}
