class MediaSearchConfig {
  static const _proxy = String.fromEnvironment('MEDIA_PROXY_URL');

  static String get proxyUrl {
    var s = _proxy.trim();
    if (s.isEmpty || s.contains(' ') || s.contains('YOUR-')) return '';
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }
}
