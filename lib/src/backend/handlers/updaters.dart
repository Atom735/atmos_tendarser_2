import 'dart:math' show min;

import '../../data/data_interval_ids.dart';
import '../../data/updater_data.dart';
import '../../interfaces/i_msg.dart';
import '../../interfaces/i_msg_connection.dart';
import '../../messages/msg_done.dart';
import '../../messages/msg_error.dart';
import '../../messages/msg_updater_get.dart';
import '../../messages/msg_updater_spawn_new_etpgpb.dart';
import '../backend_app.dart';

bool handleUpdatersMsg(BackendApp app, IMsgConnection connection, IMsg msg) {
  if (msg is MsgUpdaterSpawnNewEtpGpb) {
    try {
      app.spawnNewEtpGpbUpdater(msg.start, msg.end);
      connection.send(MsgDone(msg.id));
    } on Object catch (e) {
      connection.send(MsgError(msg.id, e.toString()));
    }
    return true;
  }
  if (msg is MsgUpdaterLengthRequest) {
    try {
      final table = app.db.tableUpdaters;
      final length = table.sqlSelectCount();
      connection.send(MsgUpdaterLengthResponse(msg.id, length));
      return true;
    } on Object catch (e) {
      connection.send(MsgError(msg.id, e.toString()));
      return true;
    }
  }
  if (msg is MsgUpdaterGetInterval) {
    try {
      final noCache = msg.noCache;
      final data =
          app.db.getUpdaterInterval(msg.offset, msg.length, msg.sort, msg.asc);
      if (noCache) {
        connection.send(MsgUpdaterResponse(msg.id, data));
        return true;
      }
      final ids_ = data.map((e) => e.state.timestamp);
      final idsBase = ids_.reduce(min);
      final ids = DataIntervalIds.e1(ids_.map((e) => e - idsBase).toList());

      connection
          .request(MsgUpdaterInterval(
        msg.id,
        idsBase,
        ids,
      ))
          .then((resp) async {
        try {
          if (resp is! MsgUpdaterInterval) {
            throw InvalidateMsg(resp);
          }
          final idsNeeds = ids.getDiff(resp.ids).map((e) => e + idsBase);
          data.removeWhere((e) => !idsNeeds.contains(e.state.timestamp));
          connection.send(MsgUpdaterResponse(resp.id, data));
          return true;
        } on Object catch (e) {
          connection.send(MsgError(resp.id, e.toString()));
          return true;
        }
      });
      return true;
    } on Object catch (e) {
      connection.send(MsgError(msg.id, e.toString()));
      return true;
    }
  }

  if (msg is MsgUpdaterGetRequest) {
    try {
      final table = app.db.tableUpdaters;
      final data = table.sqlSelect('''
        WHERE ${table.vColumnsTimestamp.name} > ${msg.timestamp}
        ''').toList();
      connection.send(MsgUpdaterResponse(msg.id, data));
      return true;
    } on Object catch (e) {
      connection.send(MsgError(msg.id, e.toString()));
      return true;
    }
  }
  return false;
}
