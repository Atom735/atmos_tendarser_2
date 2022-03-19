import 'dart:async';
import 'dart:io';

import 'package:atmos_logger/atmos_logger_io.dart';

import '../database/database_app_server.dart';
import '../database/database_app_server_sync_process.dart';
import '../interfaces/i_msg.dart';
import '../interfaces/i_msg_connection.dart';
import '../interfaces/i_web_client.dart';
import '../messages/msg_sync_request.dart';
import 'backend_web_socket_connection.dart';
import 'updater_etpgpb.dart';
import 'web_client.dart';

/// Интерфейс серверного приложения
class BackendApp {
  /// Версия приложения
  int get version => 1;

  final db = DatabaseAppServer('backend.db');
  final Logger logger = LoggerConsole(LoggerFile(File('backend.log')));
  late HttpServer server;
  final connections = <IMsgConnection>[];
  late final IWebClient webClient = WebClient(logger);
  final updaters = <UpdaterEtpGpb>[];

  void _updaterStateUpdate(UpdaterEtpGpb updater) {
    db.updateUpdaterStates([updater.state]);
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
    if (msg is MsgSyncRequest) {
      DatabaseAppServerSyncProcess(db, connection, msg);
    }
    return false;
  }

  Future<void> handleRequest(HttpRequest httpRequest) async {
    if (WebSocketTransformer.isUpgradeRequest(httpRequest)) {
      // ignore: close_sinks
      final socket = await WebSocketTransformer.upgrade(httpRequest);
      connections.add(BackendWebSocketConnection(
          socket, version, logger, handleMsg, connections.remove));
    } else {
      logger.debug('Server new HTTP request');
      httpRequest.response
        ..statusCode = 403
        ..writeln('No access');
      await httpRequest.response.close();
    }
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
    server = await HttpServer.bind(InternetAddress.anyIPv4, 49735);
    server.serverHeader = 'Atmos Tendarser (Server version = $version)';
    logger.info('Server spawned and listen port', server.port.toString());
    server.listen(
      handleRequest,
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
