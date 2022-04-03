import 'dart:collection';
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../data/data_interval_ids.dart';
import '../data/intervals/data_interval_tenders_etpgpb.dart';
import '../interfaces/i_msg.dart';

@immutable
class MsgDbGetIntervalIds<T> implements IMsg {
  const MsgDbGetIntervalIds(this.id, this.table, this.data);

  static const typeId = 8;

  @override
  final int id;
  final int table;
  final T data;

  @override
  Uint8List get toBytes {
    final d = data.toBytes;
    return (BinaryWriter()
          ..writeSize(typeId)
          ..writeSize(id)
          ..writeSize(table)
          ..writeListUint8(d))
        .takeBytes();
  }

  static MsgDbGetIntervalIds read(BinaryReader reader) {
    final type = reader.readSize();
    assert(type == typeId, 'Not equals typeId');
    final id = reader.readSize();
    final table = reader.readSize();
    final data = DataIntervalTendersEtpGpb.read(reader);
    return MsgDbGetIntervalIds(id, table, data);
  }

  @override
  String toString() => '''MsgDbGetIntervalIds(id=$id, table=$table)''';
}
