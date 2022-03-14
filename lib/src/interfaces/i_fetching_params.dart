import 'dart:collection';

import '../common/common_uri_raw.dart';
import '../common/common_web_constants.dart';

/// Интерфейс параметров запроса
///
/// Происходит подставнока данных в [url] и [query] где имеются след шаблоны:
/// - `${{name}}`
/// - `${{name:type}}`
/// - `${{name:type(params)}}`
abstract class IFetchingParams {
  IFetchingParams._();

  /// Уникальный идентификатор этих параметров
  int get id;

  /// Метод запроса
  /// - (Либо FTP)
  WebClientMethod get method;

  /// Url строка запроса
  /// - (Либо схема для FTP подключения
  /// `ftp://[<пользователь>[:<пароль>]@]<хост>[:<порт>]/<путь>`)
  String get url;

  /// Строка параметров запроса
  /// - (Для FTP выполняемый метод)
  String get query;

  /// Тип контента (игнорируется для GET или FTP запроса)
  WebContentType get type;

  /// Конечный uri для запроса
  /// - (Несущественен для FTP)
  Uri get uri;

  /// Необходимы ли данные для построения конечного запроса
  /// Вычисляемое поле
  bool get isNeedData;

  /// Получает новый экземпляр параметров запроса с установленными данными
  IFetchingParamsWithData toWithData();

  /// Регулярка для нахождения имен шаблонов
  static final reVar = RegExp(r'\$\{\{(.+?)\}\}');

  /// Генератор Uri
  static Uri uriGen(IFetchingParams t) {
    final uri = Uri.parse(t.url);
    if (t.method == WebClientMethod.get) {
      return UriRaw(Uri.decodeFull(uri
          .replace(
              query: (uri.query.isNotEmpty ? '${uri.query}&' : '') + t.query)
          .toString()));
    }
    return UriRaw(Uri.decodeFull(uri.toString()));
  }

  static Map<String, String> dataGen(IFetchingParams t) {
    if (!t.isNeedData) return const {};
    final datas = SplayTreeMap<String, String>();
    for (final m in IFetchingParams.reVar.allMatches(t.url)) {
      datas[m[1]!] = '';
    }
    for (final m in IFetchingParams.reVar.allMatches(t.query)) {
      datas[m[1]!] = '';
    }
    return datas;
  }
}

/// Прокси параметры, которые поставляются в готовом виде с данными
abstract class IFetchingParamsWithData implements IFetchingParams {
  IFetchingParamsWithData._();

  /// Базовые параметры от которых произошло унаследование
  IFetchingParams get paramsBase;

  /// Данные параметра, необходимые к заполнению
  Map<String, String> get data;
}
