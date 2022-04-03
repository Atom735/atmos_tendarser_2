import '../../data/data_interval_ids.dart';
import '../../data/updater_data.dart';
import '../../interfaces/i_msg.dart';
import '../../messages/msg_done.dart';
import '../../messages/msg_updater_get.dart';
import '../../messages/msg_updater_spawn_new_etpgpb.dart';
import '../frontend_app.dart';

extension FrontendAppXUpdaters on FrontendApp {
  Future<void> spawnNewUpdater(DateTime start, DateTime end) async {
    final resp = await connection.request(
      MsgUpdaterSpawnNewEtpGpb(connection.mewMsgId, start, end),
    );
    if (resp is! MsgDone) {
      throw InvalidateMsg(resp);
    }
    return;
  }

  Future<int> getUpdaterLength() async {
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
    final newIds = resp.data.map((e) => e.settings.id).toList();
    final newIdsContains =
        table.sqlSelectByIds(newIds).map((e) => e.settings.id).toList();
    newIds.removeWhere(newIdsContains.contains);
    for (final item in newIdsContains) {
      db.updateUpdaterStates(
          resp.data.firstWhere((e) => e.state.id == item).state);
    }

    table.sqlInsert(resp.data.where((e) => newIds.contains(e.state.id)));
    datas.addAll(resp.data);
    return ids.map((e) => datas.firstWhere((d) => d.settings.id == e)).toList();
  }
}
