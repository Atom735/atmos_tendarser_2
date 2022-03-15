import 'dart:io';

import 'backend_app.dart';

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
