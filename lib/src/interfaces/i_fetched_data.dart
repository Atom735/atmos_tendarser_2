import 'dart:typed_data';

import '../common/common_stop_watch_ticks.dart';
import '../common/common_web_constants.dart';
import 'i_fetching_params.dart';

abstract class IFetchedData {
  IFetchedData._();

  /// Параметры запроса связанные с этим ответом.
  IFetchingParams get params;

  /// Время установки соединения
  StopWatchTicks get tConnecting;

  /// Время отправки запроса
  StopWatchTicks get tSending;

  /// Время ожидание первого полученного байта
  StopWatchTicks get tWaiting;

  /// Время загрузки всего ответа
  StopWatchTicks get tDownloading;

  /// Флаг являются ли данные сжатыми
  bool get gzip;

  /// Тип полученных данны
  WebContentType get type;

  /// Размер полученных данных (Сжатых)
  int get length;

  /// Размер полученных данных (Распакованных)
  int get decodedLength;

  /// Байты полученных данных
  Uint8List? get bytes;
}
