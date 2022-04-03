import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:logging/logging.dart';

import '../common/common_connection.dart';
import '../interfaces/i_msg.dart';
import '../interfaces/i_msg_connection.dart';
import '../messages/messages_decoder.dart';
import '../messages/msg_done.dart';
import '../messages/msg_error.dart';
import '../messages/msg_handshake.dart';

class BackendMsgConnection extends CommonMsgConnection {
  BackendMsgConnection(
    this.ws,
    this.version,
    this.handler,
    this.onClose,
  ) {
    logger.info('new connection');
    ws.listen(handleDataRaw, onDone: handleDone, onError: handleError);
  }

  /// Версия приложения
  final int version;
  @override
  late final Logger logger = Logger(toString());
  final bool Function(IMsgConnection connection, IMsg msg) handler;
  final void Function(IMsgConnection connection) onClose;
  @override
  final Socket ws;
  bool handshaked = false;

  @override
  Future<void> handleData(Uint8List request) async {
    try {
      logger.fine('recived: ${request.length}');
      final msg = const MessagesDecoder().convert(request);
      logger.fine('new msg', msg);
      requestsCompleters.remove(msg.id)?.complete(msg);
      streamControllers[msg.id]?.add(msg);
      if (msg is MsgDone) {
        await streamControllers.remove(msg.id)?.close();
      }
      logger.fine('new msg', msg);
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
    logger.info('done');
    close();
  }

  void handleError(Object? e) {
    logger.severe('error', e.toString());
    close();
  }

  @override
  void close() {
    super.close();
    onClose(this);
  }

  int _id = 2;

  @override
  int get mewMsgId => _id += 2;
}
