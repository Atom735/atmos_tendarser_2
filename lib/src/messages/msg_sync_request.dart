import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:meta/meta.dart';

import '../data/dto_database_sync_data.dart';
import '../data/table_database_sync_data.dart';
import '../interfaces/i_msg.dart';

@immutable
class MsgSyncRequest implements IMsg {
  const MsgSyncRequest(this.id, this.syncData);

  factory MsgSyncRequest.decode(Uint8List data) {
    final reader = BinaryReader(data);
    final type = reader.readSize();
    if (type != typeId) {
      throw Exception('Untyped msg');
    }
    final id = reader.readSize();
    final dataSync = table.msgDartRead(reader);
    return MsgSyncRequest(id, dataSync);
  }

  static const typeId = 4;

  @override
  final int id;

  final DtoDatabaseSyncData syncData;

  static const table = TableDatabaseSyncData();

  @override
  Uint8List get toBytes {
    final writer = BinaryWriter()
      ..writeSize(typeId)
      ..writeSize(id);
    table.msgDartWrite(syncData, writer);
    return writer.takeBytes();
  }

  @override
  String toString() => 'MsgSyncRequest(id=$id, $syncData)';
}
