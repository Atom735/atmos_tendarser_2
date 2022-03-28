import 'dart:async';
import 'dart:io';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:atmos_logger/atmos_logger_io.dart';

import '../data/data_tender_db_etpgpb.dart';
import '../database/database_app_server.dart';
import '../interfaces/i_msg.dart';
import '../interfaces/i_msg_connection.dart';
import '../interfaces/i_web_client.dart';
import '../messages/msg_db_get_interval_request.dart';
import '../messages/msg_db_get_interval_response.dart';
import '../messages/msg_db_get_length_request.dart';
import '../messages/msg_db_get_length_response.dart';
import '../messages/msg_error.dart';
import 'backend_web_socket_connection.dart';
import 'updater_etpgpb.dart';
import 'web_client.dart';

/// Интерфейс серверного приложения
class BackendApp {
  /// Версия приложения
  int get version => 1;

  final db = DatabaseAppServer('backend.db');
  final Logger logger = LoggerConsole(LoggerFile(File('backend.log')));
  late ServerSocket server;
  final connections = <IMsgConnection>[];
  late final IWebClient webClient = WebClient(const LoggerVoid());
  final updaters = <UpdaterEtpGpb>[];

  void _updaterStateUpdate(UpdaterEtpGpb updater) {
    db.updateUpdaterStates(updater.state);
  }

  void spawnNewUpdater(DateTime start, DateTime end) {
    final res =
        UpdaterEtpGpb(webClient, db, db.createNewUpdaterEtpGpb(start, end))
          ..updates.listen(_updaterStateUpdate)
          ..run();
    updaters.add(res);
    res.done.whenComplete(() => updaters.remove(res));
  }

  void spawnOldUpdaters() {
    final s = db.getActiveUpdaters();
    for (final item in s) {
      final res = UpdaterEtpGpb(webClient, db, item)
        ..updates.listen(_updaterStateUpdate)
        ..run();
      updaters.add(res);
      res.done.whenComplete(() => updaters.remove(res));
    }
  }

  bool handleMsg(IMsgConnection connection, IMsg msg) {
    // if (msg is MsgSyncRequest) {
    //   DatabaseAppServerSyncProcess(db, connection, msg);
    //   return true;
    // }
    if (msg is MsgDbGetLengthRequest) {
      switch (msg.table) {
        case 0:
          late int count;
          if (msg.search.isEmpty) {
            count = db.tableTenders.sqlSelectCount();
          } else {
            count = db.tableTenders.sqlSelectCountFts(
              'WHERE ${db.tableTenders.nameFts} = ?',
              [msg.search],
            );
          }
          connection.send(
            MsgDbGetLengthResponse(
              msg.id,
              count,
            ),
          );
          return true;
        default:
          connection.send(MsgError(msg.id, 'Unknown table id'));
          return true;
      }
    }
    if (msg is MsgDbGetIntervalRequest) {
      switch (msg.table) {
        case 0:
          late List<DataTenderDbEtpGpb> tenders;
          if (msg.search.isEmpty) {
            tenders = db.tableTenders.sqlSelect(
              '''
                ORDER BY timestamp DESC
                LIMIT ? OFFSET ?
              ''',
              [msg.length, msg.offset],
            ).toList();
          } else {
            tenders = db.tableTenders.sqlSelectFtsHl(
              '''
                WHERE ${db.tableTenders.nameFts} = ?
                ORDER BY ${db.tableTenders.name}.timestamp DESC
                LIMIT ? OFFSET ?
              ''',
              [msg.search, msg.length, msg.offset],
            ).toList();
          }
          final ids = tenders.map((e) => e.rowid).toList();

          final tendersW = BinaryWriter();
          for (final item in tenders) {
            db.tableTenders.binWrite(item, tendersW);
          }
          final companiesW = BinaryWriter();
          for (final item in db.tableCompanies
              .sqlSelectByIdsRaw(tenders.map((e) => e.organizerId).toList())) {
            db.tableCompanies.binWriteRaw(item, companiesW);
          }
          final regionsRefs = db.tableRegionsRefs.getByA(ids).toList();
          final regionsRefsW = BinaryWriter();
          for (final item in regionsRefs) {
            db.tableRegionsRefs.binWrite(item, regionsRefsW);
          }
          final propsRefs = db.tablePropsRefs.getByA(ids).toList();
          final propsRefsW = BinaryWriter();
          for (final item in propsRefs) {
            db.tablePropsRefs.binWrite(item, propsRefsW);
          }
          final regionsW = BinaryWriter();
          for (final item in db.tableRegions.sqlSelectByIdsRaw(
            regionsRefs.map((e) => e.idB).toList(),
          )) {
            db.tableRegions.binWriteRaw(item, regionsW);
          }
          final propsW = BinaryWriter();
          for (final item in db.tableProps.sqlSelectByIdsRaw(
            propsRefs.map((e) => e.idB).toList(),
          )) {
            db.tableProps.binWriteRaw(item, propsW);
          }

          final w = BinaryWriter();
          db.tableTenders.binWrite(tenders.first, w);
          final t = db.tableTenders.binRead(BinaryReader(w.takeBytes()));

          connection.send(MsgDbGetIntervalResponse(
            msg.id,
            0,
            MsgDbGetIntervalResponseTenderData(
              ids,
              tendersW.takeBytes(),
              companiesW.takeBytes(),
              regionsW.takeBytes(),
              propsW.takeBytes(),
              regionsRefsW.takeBytes(),
              propsRefsW.takeBytes(),
            ),
          ));

          return true;
        default:
          connection.send(MsgError(msg.id, 'Unknown table id'));
          return true;
      }
    }
    return false;
  }

  // Future<void> handleRequest(HttpRequest httpRequest) async {
  //   logger.debug('Server new HTTP request');
  //   if (WebSocketTransformer.isUpgradeRequest(httpRequest)) {
  //     // ignore: close_sinks
  //     final socket = await WebSocketTransformer.upgrade(httpRequest);
  //     connections.add(BackendWebSocketConnection(
  //         socket, version, logger, handleMsg, connections.remove));
  //   } else {
  //     logger.debug('Server new HTTP request');
  //     httpRequest.response
  //       ..statusCode = 403
  //       ..writeln('No access');
  //     await httpRequest.response.close();
  //   }
  // }

  void handleNewConnection(Socket socket) {
    connections.add(BackendWebSocketConnection(
        socket, version, logger, handleMsg, connections.remove));
  }

  void handleServerError(Object error, StackTrace stackTrace) {
    logger.fatal('Server error', 'Error: $error\n$stackTrace');
    server.close();
    dispose();
  }

  void handleServerDone() {
    logger.info('Server shutdown');
    server.close();
    dispose();
  }

  Future<void> run(List<String> args) async {
    logger.info('Server Start');
    await init();
    server = await ServerSocket.bind(InternetAddress.anyIPv4, 49735);
    // server.serverHeader = 'Atmos Tendarser (Server version = $version)';
    logger.info('Server spawned and listen port', server.port.toString());
    server.listen(
      handleNewConnection,
      onError: handleServerError,
      onDone: handleServerDone,
    );
  }

  Future<void> init() async {
    spawnOldUpdaters();
    logger.info('Modules initialized');
  }

  Future<void> dispose() async {
    for (final item in connections) {
      item.close();
    }
    for (final item in updaters) {
      unawaited(item.dispose());
    }
    await webClient.dispose();
    db.dispose();
    logger.info('Modules disposed');
  }
}
