import 'package:atmos_database/atmos_database.dart';
import 'package:meta/meta.dart';

/// Метод подключения Web-клиента
enum WebClientMethod {
  /// Неизвестный метод
  unknown,

  /// Подключение по FTP
  ftp,

  /// HTTP GET запрос
  get,

  /// HTTP POST запрос
  post,
}

extension WebClientMethodX on WebClientMethod {
  /// Каноническое название методов веб запроса
  String get canonical {
    switch (this) {
      case WebClientMethod.unknown:
        return '???';
      case WebClientMethod.ftp:
        return 'FTP';
      case WebClientMethod.get:
        return 'GET';
      case WebClientMethod.post:
        return 'POST';
    }
  }
}

@immutable
class DatabaseColumnWebClientMethod
    extends DatabaseColumnUnsignedBase<WebClientMethod> {
  @literal
  const DatabaseColumnWebClientMethod(String name) : super(name);

  @override
  WebClientMethod dartEncode(int value) => WebClientMethod.values[value];

  @override
  int dartDecode(WebClientMethod value) => value.index;
}

class DatabaseColumnUnsigned {}

/// Тип веб контента
enum WebContentType {
  /// Неизвестный тип (Зачастую используется для GET или FTP запроса )
  unknown,

  /// Результат архивный файл
  zip,

  /// Возвращённый результат - Список файлов (Для FTP)
  list,

  /// Полученный файл является HTML документом
  html,

  /// Полученный или отправляемые данные являются JSON документом
  json,

  /// Полученные или отправляемые данные являются параметры закодированые в url
  /// представлении
  url,
}

extension WebContentTypeX on WebContentType {
  /// Канонический mime тип для предоставления ээтих данных
  String get canonical {
    switch (this) {
      case WebContentType.unknown:
        return '???/???';
      case WebContentType.zip:
        return 'application/zip';
      case WebContentType.list:
        return 'application/x-ftp-list';
      case WebContentType.html:
        return 'text/html; charset=utf-8';
      case WebContentType.json:
        return 'application/json; charset=utf-8';
      case WebContentType.url:
        return 'application/x-www-form-urlencoded; charset=utf-8';
    }
  }

  /// Расширение файла для сохранения
  String get ext {
    switch (this) {
      case WebContentType.unknown:
        return '.unknown';
      case WebContentType.zip:
        return '.zip';
      case WebContentType.list:
      case WebContentType.url:
        return '.txt';
      case WebContentType.html:
        return '.html';
      case WebContentType.json:
        return '.json';
    }
  }

  static WebContentType parse(String mime) {
    if (mime.contains('text/html')) {
      return WebContentType.html;
    }
    if (mime.contains('application/json')) {
      return WebContentType.json;
    }
    if (mime.contains('application/x-www-form-urlencoded')) {
      return WebContentType.url;
    }
    return WebContentType.unknown;
  }
}

@immutable
class DatabaseColumnWebContentType
    extends DatabaseColumnUnsignedBase<WebContentType> {
  @literal
  const DatabaseColumnWebContentType(String name) : super(name);

  @override
  WebContentType dartEncode(int value) => WebContentType.values[value];

  @override
  int dartDecode(WebContentType value) => value.index;
}
