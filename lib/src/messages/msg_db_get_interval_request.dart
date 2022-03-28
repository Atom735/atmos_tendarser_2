import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';

@immutable
class MsgDbGetIntervalRequest implements IMsg {
  const MsgDbGetIntervalRequest(
      this.id, this.table, this.search, this.offset, this.length);

  factory MsgDbGetIntervalRequest.decode(BinaryReader reader) {
    final id = reader.readSize();
    final table = reader.readSize();
    final search = reader.readString();
    final offset = reader.readSize();
    final length = reader.readSize();
    return MsgDbGetIntervalRequest(id, table, search, offset, length);
  }

  static const typeId = 6;

  @override
  final int id;
  final int table;
  final String search;
  final int offset;
  final int length;

  @override
  Uint8List get toBytes => (BinaryWriter()
        ..writeSize(typeId)
        ..writeSize(id)
        ..writeSize(table)
        ..writeString(search)
        ..writeSize(offset)
        ..writeSize(length))
      .takeBytes();

  @override
  String toString() =>
      '''MsgDbGetIntervalRequest(id=$id, table=$table, [$offset-$length], search="$search")''';
}
