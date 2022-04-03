import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';

@immutable
class MsgUnknown implements IMsg {
  const MsgUnknown(this.type, this.id, this.data);

  factory MsgUnknown.read(BinaryReader reader) {
    final type = reader.readSize();
    final id = reader.readSize();
    final length = reader.peek;
    final data = reader.readListUint8(size: length);
    return MsgUnknown(type, id, data);
  }

  static const typeId = 0;

  final int type;
  @override
  final int id;
  final Uint8List data;

  @override
  BinaryWriter write(BinaryWriter writer) => writer
    ..writeSize(type)
    ..writeSize(id)
    ..writeListUint8(data, size: data.length);

  @override
  String toString() =>
      'MsgUnknown(type=$type, id=$id, data=bytes(${data.length}))';
}
