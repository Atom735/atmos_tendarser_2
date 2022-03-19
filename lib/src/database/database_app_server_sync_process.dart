import 'dart:async';

import '../data/dto_database_sync_data.dart';
import '../interfaces/i_msg_connection.dart';
import '../messages/msg_done.dart';
import '../messages/msg_sync_data_haved.dart';
import '../messages/msg_sync_data_intervals.dart';
import '../messages/msg_sync_request.dart';
import 'database_app_server.dart';

class DatabaseAppServerSyncProcess {
  DatabaseAppServerSyncProcess(
    this.db,
    this.connection,
    MsgSyncRequest msgStart,
  ) {
    syncData = msgStart.syncData;
    msgId = msgStart.id;
    syncDataEnd = db.getLastSyncData();
    done = syncingStart();
  }

  final DatabaseAppServer db;
  final IMsgConnection connection;
  late DtoDatabaseSyncData syncData;
  late final DtoDatabaseSyncData syncDataEnd;
  late final Future<void> done;
  late final int msgId;

  Future<void> syncingStart() async {
    final msgSyncDataMax =
        await connection.request(MsgSyncRequest(msgId, syncDataEnd));
    if (msgSyncDataMax is! MsgDone) {
      throw StateError('Неправильный ответ начала синхронизации');
    }
    while (await syncingStep()) {}
    connection.send(MsgDone(msgId));
  }

  Future<bool> syncingStep() async {
    final serverIds = db.getSyncDataChunkData(msgId, syncData, syncDataEnd);
    final clientIds = await connection.request(
      MsgSyncDataIntervals(msgId, syncData, serverIds.toSyncDataMax),
    );
    if (clientIds is! MsgSyncDataHaved) {
      throw StateError('Имеющиейся айди синхронизации не получены');
    }
    serverIds.removeFrom(clientIds);
    final resp = await connection.request(db.getSyncFrame(serverIds));
    if (resp is! MsgDone) {
      throw StateError('Неправильный ответ получения фреймов синхронизации');
    }

    return serverIds.isNotEmpty;
  }
}
