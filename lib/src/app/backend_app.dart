import 'dart:io';

import 'package:atmos_logger/atmos_logger_io.dart';

/// Интерфейс серверного приложения
class BackendApp {
  /// Версия приложения
  int get version => 1;

  final Logger logger = LoggerConsole(LoggerFile(File('backend.log')));
  late HttpServer server;
  final connections = <BackendWebSocketConnection>[];

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
  }

  void handleServerDone() {
    logger.info('Server shutdown');
    server.close();
  }

  Future<void> run(List<String> args) async {
    logger.info('Start');
    server = await HttpServer.bind(InternetAddress.anyIPv4, 49735);
    server.serverHeader = 'Atmos Tendarser (Server version = $version)';
    logger.info('Server spawned and listen port', server.port.toString());
    server.listen(
      handleRequest,
      onError: handleServerError,
      onDone: handleServerDone,
    );
  }
}

class BackendWebSocketConnection {
  BackendWebSocketConnection(this.app, this.socket) {
    socket.listen(handleData);
  }

  final BackendApp app;
  final WebSocket socket;

  Future<void> handleData(Object? request) async {
    app.logger.debug('New WebSocket msg', request.toString());
  }

  Future<void> close() async {
    app.connections.remove(this);
    return socket.close(0, 'OK');
  }
}
