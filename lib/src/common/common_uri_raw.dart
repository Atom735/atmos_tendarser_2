class UriRaw implements Uri {
  UriRaw(String url) {
    final m = _re.matchAsPrefix(url);
    if (m == null) {
      throw const FormatException('Invalid URL');
    }
    scheme = m.group(2) ?? 'http';
    host = m.group(4) ?? '';
    path = m.group(5) ?? '/';
    query = m.group(7) ?? '';
    fragment = m.group(9) ?? '';

    if (path.isEmpty) {
      path = '/';
    }

    switch (scheme) {
      case 'https':
        port = 443;
        break;
      case 'http':
        port = 80;
        break;
      default:
        port = -1;
    }
  }

  static final _re =
      RegExp(r'^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?');
  @override
  late String fragment;
  @override
  late String host;

  @override
  late String path;

  @override
  late int port;

  @override
  late String query;

  @override
  late String scheme;

  @override
  String get authority => host;

  @override
  UriData? get data => throw UnimplementedError();

  @override
  bool get hasAbsolutePath => true;

  @override
  bool get hasAuthority => true;

  @override
  bool get hasEmptyPath => path == '/';

  @override
  bool get hasFragment => fragment.isNotEmpty;

  @override
  bool get hasPort => throw UnimplementedError();

  @override
  bool get hasQuery => query.isNotEmpty;

  @override
  bool get hasScheme => true;

  @override
  bool get isAbsolute => true;

  @override
  String get origin => throw UnimplementedError();

  @override
  List<String> get pathSegments => path.split('/').sublist(1);

  @override
  Map<String, String> get queryParameters => throw UnimplementedError();

  @override
  Map<String, List<String>> get queryParametersAll =>
      throw UnimplementedError();

  @override
  String get userInfo => '';

  @override
  bool isScheme(String scheme) => scheme == this.scheme;

  @override
  Uri normalizePath() {
    throw UnimplementedError();
  }

  @override
  Uri removeFragment() {
    if (!hasFragment) {
      return this;
    }
    throw UnimplementedError();
  }

  @override
  Uri replace(
      {String? scheme,
      String? userInfo,
      String? host,
      int? port,
      String? path,
      Iterable<String>? pathSegments,
      String? query,
      Map<String, dynamic>? queryParameters,
      String? fragment}) {
    throw UnimplementedError();
  }

  @override
  Uri resolve(String reference) => resolveUri(Uri.parse(reference));

  @override
  Uri resolveUri(Uri reference) {
    if (reference.isAbsolute) {
      return UriRaw(reference.toString());
    }
    if (reference.hasAbsolutePath) {
      return UriRaw('$scheme://$host$_portS$reference');
    }
    throw UnimplementedError();
  }

  @override
  String toFilePath({bool? windows}) {
    throw UnimplementedError();
  }

  String get _portS =>
      (port == 80 && scheme == 'http') || (port == 443 && scheme == 'https')
          ? ''
          : ':$port';
  String get _queryS => hasQuery ? '?$query' : '';
  String get _fragmentS => hasFragment ? fragment : '';

  @override
  String toString() => '$scheme://$host$_portS$path$_queryS$_fragmentS';
}
