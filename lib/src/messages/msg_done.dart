import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';

@immutable
class MsgDone implements IMsg {
  const MsgDone(this.id);

  factory MsgDone.read(BinaryReader reader) {
    final type = reader.readSize();
    assert(type == typeId, 'Not equals typeId');
    final id = reader.readSize();
    return MsgDone(id);
  }

  static const typeId = 3;

  @override
  final int id;

  @override
  BinaryWriter write(BinaryWriter writer) => writer
    ..writeSize(typeId)
    ..writeSize(id);

  @override
  String toString() => 'MsgDone(id=$id)';
}
