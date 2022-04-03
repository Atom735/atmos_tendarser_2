import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';

@immutable
class MsgError implements IMsg {
  const MsgError(this.id, this.error);

  factory MsgError.read(BinaryReader reader) {
    final type = reader.readSize();
    assert(type == typeId, 'Not equals typeId');
    final id = reader.readSize();
    final error = reader.readString();
    return MsgError(id, error);
  }

  static const typeId = 2;

  @override
  final int id;
  final String error;

  @override
  BinaryWriter write(BinaryWriter writer) => writer
    ..writeSize(typeId)
    ..writeSize(id)
    ..writeString(error);

  @override
  String toString() => 'MsgError(id=$id, error="$error")';
}
