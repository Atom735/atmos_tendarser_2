import 'dart:io';

import 'package:atmos_logger/atmos_logger_io.dart';
import 'package:sqlite3/sqlite3.dart';

import '../interfaces/i_web_client.dart';
import 'backend_module_etpgpb.dart';
import 'backend_web_socket_connection.dart';
import 'web_client.dart';

/// Интерфейс серверного приложения
class BackendApp {
  /// Версия приложения
  int get version => 1;

  final db = sqlite3.open('backend.db')
    ..execute('PRAGMA JOURNAL_MODE=OFF')
    ..execute('PRAGMA SYNCHRONOUS=OFF');

  final Logger logger = LoggerConsole(LoggerFile(File('backend.log')));
  late HttpServer server;
  final connections = <BackendWebSocketConnection>[];
  late final IWebClient webClient = WebClient(logger);

  late final BackendModuleEtpGpb pEtpGpb = BackendModuleEtpGpb(this);

  Future<void> handleRequest(HttpRequest httpRequest) async {
    if (WebSocketTransformer.isUpgradeRequest(httpRequest)) {
      // ignore: close_sinks
      final socket = await WebSocketTransformer.upgrade(httpRequest);
      logger.debug(
        'Server new WebSocket request',
        'WebSocket[${socket.hashCode.toRadixString(16)}]',
      );
      connections.add(BackendWebSocketConnection(this, socket));
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
    logger.info('Start');
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
    await pEtpGpb.init();
    logger.info('Modules initialized');
  }

  Future<void> dispose() async {
    await pEtpGpb.dispose();
    await webClient.dispose();
    logger.info('Modules disposed');
  }
}
