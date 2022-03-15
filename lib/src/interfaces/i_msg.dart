import 'dart:typed_data';

abstract class IMsg {
  IMsg._();

  /// Уникальный идентификатор сообщения
  int get id;

  Uint8List get toBytes;
}
