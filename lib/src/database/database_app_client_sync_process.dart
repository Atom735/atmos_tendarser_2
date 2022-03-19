import '../data/dto_database_sync_data.dart';
import '../interfaces/i_msg_connection.dart';
import '../messages/msg_done.dart';
import '../messages/msg_sync_data_frame.dart';
import '../messages/msg_sync_data_intervals.dart';
import '../messages/msg_sync_request.dart';
import 'database_app_client.dart';

class DatabaseAppClientSyncProcess {
  DatabaseAppClientSyncProcess(
    this.db,
    this.connection,
  ) {
    syncData = db.getLastSyncData();
    done = syncingStart();
  }

  final DatabaseAppClient db;
  final IMsgConnection connection;
  late final msgId = connection.mewMsgId;
  late final DtoDatabaseSyncData syncData;
  late final Future<void> done;

  Future<void> syncingStart() async {
    final msgSyncDataMax =
        await connection.request(MsgSyncRequest(msgId, syncData));
    if (msgSyncDataMax is! MsgSyncRequest) {
      throw StateError('Неправильный ответ начала синхронизации');
    }
    while (await syncingStep()) {}
  }

  Future<bool> syncingStep() async {
    final intervals = await connection.request(MsgDone(msgId));
    if (intervals is MsgDone) {
      return false;
    }
    if (intervals is! MsgSyncDataIntervals) {
      throw StateError('Интервалы синхронизации не получены');
    }
    final frame = await connection.request(
      db.getSyncDataHaved(msgId, intervals.begin, intervals.end),
    );

    if (frame is! MsgSyncDataFrame) {
      throw StateError('Фреймы синхронизации не получены');
    }
    db.insertSyncFrame(frame);
    db.tableSync.sqlInsert(db.sql, [intervals.end]);
    return true;
  }
}
