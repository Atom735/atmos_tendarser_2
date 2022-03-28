import 'dart:async';
import 'dart:io';

import 'package:atmos_logger/src/logger.dart';

import '../common/common_connection.dart';
import '../interfaces/i_msg_connection.dart';
import '../messages/msg_handshake.dart';
import 'frontend_app.dart';

class FrontendWebSocketConnection extends CommonMsgConnection
    implements IMsgConnectionClient {
  FrontendWebSocketConnection(this.app);

  final FrontendApp app;
  @override
  Logger get logger => app.logger;

  @override
  int get version => 1;
  @override
  late Socket ws;

  int remoteVersion = 1;

  @override
  String get adress => app.serverAdress;
  @override
  ConnectionStatus statusCode = ConnectionStatus.unconnected;
  @override
  String statusMsg = '';
  @override
  Stream<FrontendWebSocketConnection> get statusUpdates => sc.stream;

  final sc =
      StreamController<FrontendWebSocketConnection>.broadcast(sync: true);

  void _status(ConnectionStatus code, [String message = '']) {
    statusCode = code;
    statusMsg = message;
    sc.add(this);
  }

  int _id = 1;

  @override
  int get mewMsgId => _id += 2;

  @override
  Future<void> reconnect() async {
    try {
      app.logger.debug('WebSocket: reconnect');
      _status(ConnectionStatus.connecting);
      ws = await Socket.connect(adress, 49735);
      app.logger.debug('WebSocket: connected');
      ws.listen(handleDataRaw, onDone: handleDone, onError: handleError);
      final v = await request(MsgHandshake(mewMsgId, app.version));
      remoteVersion = (v as MsgHandshake).version;
      app.logger.debug('WebSocket: handshaked');
      _status(ConnectionStatus.connected);
    } on Object catch (e) {
      _status(
        ConnectionStatus.error,
        'Оишбка при подключении:\n$e',
      );
    }
  }

  void handleDone() {
    app.logger.debug('WebSocket: done');
    _status(ConnectionStatus.unconnected);
    close();
  }

  void handleError(Object? e) {
    app.logger.debug('WebSocket: error', e.toString());
    _status(ConnectionStatus.error, e.toString());
    close();
  }

  @override
  void dispose() {
    close();
    if (statusCode == ConnectionStatus.connected) {
      ws.close();
    }
    sc.close();
  }
}
