import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';

@immutable
class MsgDbGetLengthResponse implements IMsg {
  const MsgDbGetLengthResponse(this.id, this.length);

  factory MsgDbGetLengthResponse.decode(BinaryReader reader) {
    final id = reader.readSize();
    final length = reader.readSize();
    return MsgDbGetLengthResponse(id, length);
  }

  static const typeId = 5;

  @override
  final int id;
  final int length;

  @override
  Uint8List get toBytes => (BinaryWriter()
        ..writeSize(typeId)
        ..writeSize(id)
        ..writeSize(length))
      .takeBytes();

  @override
  String toString() => 'MsgDbGetLengthResponse(id=$id, length=$length)';
}
