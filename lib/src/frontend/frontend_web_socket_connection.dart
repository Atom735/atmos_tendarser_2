import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../interfaces/i_msg.dart';
import '../interfaces/i_msg_connection.dart';
import '../messages/messages_decoder.dart';
import '../messages/msg_done.dart';
import '../messages/msg_handshake.dart';
import 'frontend_app.dart';

class FrontendWebSocketConnection implements IMsgConnection {
  FrontendWebSocketConnection(this.app);

  final FrontendApp app;
  late WebSocket ws;

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
  int get msgId => _id += 2;

  @override
  Future<void> reconnect() async {
    try {
      app.logger.debug('WebSocket: reconnect');
      _status(ConnectionStatus.connecting);
      ws = await WebSocket.connect('ws://$adress');
      _status(ConnectionStatus.connected);
      app.logger.debug('WebSocket: connected');
      ws.listen(handleData, onDone: handleDone, onError: handleError);
      final v = await request(MsgHandshake(msgId, app.version));
      remoteVersion = (v as MsgHandshake).version;
    } on Object catch (e) {
      _status(
        ConnectionStatus.error,
        'Оишбка при подключении:\n$e',
      );
    }
  }

  @override
  void send(IMsg msg) {
    ws.add(msg.toBytes);
  }

  @override
  Future<IMsg> request(IMsg msg) {
    final completer = Completer<IMsg>.sync();
    requestsCompleters[msg.id] = completer;
    send(msg);
    return completer.future;
  }

  final requestsCompleters = <int, Completer<IMsg>>{};

  @override
  Stream<IMsg> openStream(IMsg msg) {
    // ignore: close_sinks
    final controller = StreamController<IMsg>(sync: true);
    streamControllers[msg.id] = controller;
    send(msg);
    return controller.stream;
  }

  final streamControllers = <int, StreamController<IMsg>>{};

  Future<void> handleData(Object? request) async {
    if (request is Uint8List) {
      final msg = const MessagesDecoder().convert(request);
      app.logger.debug('WebSocket: New MSG', msg.toString());
      requestsCompleters.remove(msg.id)?.complete(msg);
      streamControllers[msg.id]?.add(msg);
      if (msg is MsgDone) {
        await streamControllers.remove(msg.id)?.close();
      }
    } else {
      app.logger.warn('WebSocket: New unknown MSG', request.toString());
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
  void close() {
    for (final controller in streamControllers.values) {
      controller
        ..addError(const SocketException.closed())
        ..close();
    }
    streamControllers.clear();
    for (final completer in requestsCompleters.values) {
      completer.completeError(const SocketException.closed());
    }
    requestsCompleters.clear();
    ws.close(0);
  }
}
