import '../../data/data_interval_ids.dart';
import '../../data/updater_data.dart';
import '../../interfaces/i_msg.dart';
import '../../messages/msg_done.dart';
import '../../messages/msg_updater_get.dart';
import '../../messages/msg_updater_spawn_new_etpgpb.dart';
import '../frontend_app.dart';

extension FrontendAppXUpdaters on FrontendApp {
  Future<void> spawnNewUpdater(DateTime start, DateTime end) async {
    if (!isOnline) {
      throw UnsupportedError('Needs to connect to server');
    }
    final resp = await connection.request(
      MsgUpdaterSpawnNewEtpGpb(connection.mewMsgId, start, end),
    );
    if (resp is! MsgDone) {
      throw InvalidateMsg(resp);
    }
    return;
  }

  Future<int> getUpdaterLength() async {
    if (!isOnline) {
      return db.tableUpdaters.sqlSelectCount();
    }
    final resp = await connection.request(
      MsgUpdaterLengthRequest(connection.mewMsgId),
    );
    if (resp is! MsgUpdaterLengthResponse) {
      throw InvalidateMsg(resp);
    }
    return resp.length;
  }

  Future<List<UpdaterData>> getUpdaterInterval(
      int offset, int length, UpdaterDataSortType sort, bool asc) async {
    final noCache = this.noCache;
    final table = db.tableUpdaters;
    if (!isOnline) {
      return db.getUpdaterInterval(offset, length, sort, asc);
    }
    var resp = await connection.request(
      MsgUpdaterGetInterval(
        connection.mewMsgId,
        offset,
        length,
        sort,
        asc,
        noCache,
      ),
    );
    if (noCache) {
      if (resp is! MsgUpdaterResponse) {
        throw InvalidateMsg(resp);
      }
      return resp.data;
    }
    if (resp is! MsgUpdaterInterval) {
      throw InvalidateMsg(resp);
    }
    final idsBase = resp.base;
    final ids = resp.ids.decodedNums(idsBase);
    final datas = table.sqlSelectByColumns({
      table.vColumnsTimestamp: [ids],
    }).toList();
    final idsContained = datas.map((e) => e.state.timestamp - idsBase).toList();
    resp = await connection.request(
      MsgUpdaterInterval(
        connection.mewMsgId,
        idsBase,
        DataIntervalIds.e2(
          idsContained,
          resp.ids,
        ),
      ),
    );
    if (resp is! MsgUpdaterResponse) {
      throw InvalidateMsg(resp);
    }
    db.upsertUpdaters(resp.data);
    datas.addAll(resp.data);
    return ids.map((e) => datas.firstWhere((d) => d.settings.id == e)).toList();
  }

  Future<List<UpdaterData>> getUpdaterRefresh() async {
    if (!isOnline) {
      throw UnsupportedError('Needs to connect to server');
    }
    final table = db.tableUpdaters;
    final resp = await connection.request(
      MsgUpdaterGetRequest(connection.mewMsgId, table.sql.select('''
        SELECT max(${table.vColumnsTimestamp.name}) FROM ${table.name}
        ''').rows.first as int? ?? 0),
    );
    if (resp is! MsgUpdaterResponse) {
      throw InvalidateMsg(resp);
    }
    db.upsertUpdaters(resp.data);
    return resp.data;
  }
}
