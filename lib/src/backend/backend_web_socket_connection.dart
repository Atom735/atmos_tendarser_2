import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:atmos_logger/atmos_logger_io.dart';

import '../common/common_connection.dart';
import '../interfaces/i_msg.dart';
import '../interfaces/i_msg_connection.dart';
import '../messages/messages_decoder.dart';
import '../messages/msg_done.dart';
import '../messages/msg_error.dart';
import '../messages/msg_handshake.dart';

class BackendWebSocketConnection extends CommonMsgConnection
    implements IMsgConnection {
  BackendWebSocketConnection(
    this.ws,
    this.version,
    this.logger,
    this.handler,
    this.onClose,
  ) {
    logger.debug('$this: new connection');
    ws.listen(handleDataRaw, onDone: handleDone, onError: handleError);
  }

  /// Версия приложения
  @override
  final int version;
  @override
  final Logger logger;
  final bool Function(IMsgConnection connection, IMsg msg) handler;
  final void Function(IMsgConnection connection) onClose;
  @override
  final Socket ws;
  bool handshaked = false;

  @override
  Future<void> handleData(Uint8List request) async {
    try {
      logger.debug('recived: ${request.length}');
      final msg = const MessagesDecoder().convert(request);
      logger.debug('WebSocket: New MSG', msg.toString());
      requestsCompleters.remove(msg.id)?.complete(msg);
      streamControllers[msg.id]?.add(msg);
      if (msg is MsgDone) {
        await streamControllers.remove(msg.id)?.close();
      }
      logger.debug('$this: New MSG', msg.toString());
      if (!handshaked) {
        if (msg is! MsgHandshake) {
          send(MsgError(msg.id, 'Needs to handshake'));
        } else {
          handshaked = true;
          send(MsgHandshake(msg.id, version));
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
        final msg = MsgError(mewMsgId, 'Erorr on process message $e');
        return send(msg);
      }
      final id = BinaryReader(request).readSize();
      final msg = MsgError(id, 'Erorr on process message $e');
      return send(msg);
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
    super.close();
    onClose(this);
  }

  @override
  String toString() => 'WebSocket[${ws.hashCode.toRadixString(16)}]';

  int _id = 2;

  @override
  int get mewMsgId => _id += 2;
}
