import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';

@immutable
class MsgDbGetLengthRequest implements IMsg {
  const MsgDbGetLengthRequest(this.id, this.table, this.search);

  factory MsgDbGetLengthRequest.decode(BinaryReader reader) {
    final id = reader.readSize();
    final table = reader.readSize();
    final search = reader.readString();
    return MsgDbGetLengthRequest(id, table, search);
  }

  static const typeId = 4;

  @override
  final int id;
  final int table;
  final String search;

  @override
  Uint8List get toBytes => (BinaryWriter()
        ..writeSize(typeId)
        ..writeSize(id)
        ..writeSize(table)
        ..writeString(search))
      .takeBytes();

  @override
  String toString() =>
      'MsgDbGetLengthRequest(id=$id, table=$table, search="$search")';
}
