import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../data/dto_database_sync_data.dart';
import '../data/table_database_sync_data.dart';
import '../interfaces/i_msg.dart';

/// Пакет данных показывающий интервал данных которые будут переданы след
/// сообщением
@immutable
class MsgSyncDataIntervals implements IMsg {
  const MsgSyncDataIntervals(this.id, this.begin, this.end);

  factory MsgSyncDataIntervals.decode(Uint8List data) {
    final reader = BinaryReader(data);
    final type = reader.readSize();
    if (type != typeId) {
      throw Exception('Untyped msg');
    }
    final id = reader.readSize();
    final begin = table.msgDartRead(reader);
    final end = table.msgDartRead(reader);
    return MsgSyncDataIntervals(id, begin, end);
  }

  static const typeId = 6;

  @override
  final int id;

  final DtoDatabaseSyncData begin;
  final DtoDatabaseSyncData end;

  static const table = TableDatabaseSyncData();

  @override
  Uint8List get toBytes {
    final writer = BinaryWriter()
      ..writeSize(typeId)
      ..writeSize(id);
    table
      ..msgDartWrite(begin, writer)
      ..msgDartWrite(end, writer);
    return writer.takeBytes();
  }

  @override
  String toString() => 'MsgSyncDataIntervals($id)'
      '\n companies   = ${begin.companies} - ${end.companies}'
      '\n regions     = ${begin.regions} - ${end.regions}'
      '\n regionsRefs = ${begin.regionsRefs} - ${end.regionsRefs}'
      '\n props       = ${begin.props} - ${end.props}'
      '\n propsRefs   = ${begin.propsRefs} - ${end.propsRefs}'
      '\n tenders     = ${begin.tenders} - ${end.tenders}';
}
