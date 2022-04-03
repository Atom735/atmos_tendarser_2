import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';

import 'i_writable.dart';

abstract class IMsg implements IWritable {
  /// For implement only
  IMsg._();

  /// Уникальный идентификатор сообщения
  int get id;
}

class InvalidateMsg extends Error {
  InvalidateMsg(this.msg);

  final IMsg msg;

  @override
  String toString() => 'InvalidateMsg: $msg';
}
