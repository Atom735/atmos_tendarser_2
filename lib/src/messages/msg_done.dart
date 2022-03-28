import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';

@immutable
class MsgDone implements IMsg {
  const MsgDone(this.id);

  factory MsgDone.decode(BinaryReader reader) {
    final id = reader.readSize();
    return MsgDone(id);
  }

  static const typeId = 3;

  @override
  final int id;

  @override
  Uint8List get toBytes => (BinaryWriter()
        ..writeSize(typeId)
        ..writeSize(id))
      .takeBytes();

  @override
  String toString() => 'MsgDone(id=$id)';
}
