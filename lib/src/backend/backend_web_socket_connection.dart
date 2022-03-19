import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:atmos_logger/atmos_logger_io.dart';

import '../interfaces/i_msg.dart';
import '../interfaces/i_msg_connection.dart';
import '../messages/messages_decoder.dart';
import '../messages/msg_done.dart';
import '../messages/msg_error.dart';
import '../messages/msg_handshake.dart';

class BackendWebSocketConnection implements IMsgConnection {
  BackendWebSocketConnection(
    this.ws,
    this.version,
    this.logger,
    this.handler,
    this.onClose,
  ) {
    logger.debug('$this: new connection');
    ws.listen(handleData, onDone: handleDone, onError: handleError);
  }

  /// Версия приложения
  final int version;
  final Logger logger;
  final bool Function(IMsgConnection connection, IMsg msg) handler;
  final void Function(IMsgConnection connection) onClose;
  final WebSocket ws;
  bool handshaked = false;

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
    // final reader = BinaryReader();
    if (request is Uint8List) {
      try {
        final msg = const MessagesDecoder().convert(request);
        logger.debug('$this: New MSG', msg.toString());
        if (!handshaked) {
          if (msg is! MsgHandshake) {
            return send(MsgError(msg.id, 'Needs to handshake'));
          } else {
            handshaked = true;
            return send(MsgHandshake(msg.id, version));
          }
        }

        if (handler(this, msg)) return;
        requestsCompleters.remove(msg.id)?.complete(msg);
        streamControllers[msg.id]?.add(msg);
        if (msg is MsgDone) {
          await streamControllers.remove(msg.id)?.close();
        }
      } on Object catch (e) {
        if (request.isEmpty) {
          return send(MsgError(mewMsgId, 'Erorr on process message $e'));
        }
        final id = BinaryReader(request).readSize();
        return send(MsgError(id, 'Erorr on process message $e'));
      }
    } else {
      logger.warn('$this: New unknown MSG', request.toString());
    }
  }

  void handleDone() {
    logger.debug('$this: done');
    close();
  }

  void handleError(Object? e) {
    logger.debug('$this: error', e.toString());
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
    onClose(this);
  }

  @override
  String toString() => 'WebSocket[${ws.hashCode.toRadixString(16)}]';

  @override
  String get adress => 'remote';

  @override
  Future<void> reconnect() {
    throw UnimplementedError();
  }

  @override
  ConnectionStatus get statusCode => ConnectionStatus.connected;

  @override
  String get statusMsg => '';

  @override
  Stream<IMsgConnection> get statusUpdates => throw UnimplementedError();

  int _id = 2;

  @override
  int get mewMsgId => _id += 2;
}
