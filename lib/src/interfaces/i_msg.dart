import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

abstract class IMsg {
  IMsg._();

  /// Уникальный идентификатор сообщения
  int get id;

  BinaryWriter write(BinaryWriter writer);
}
