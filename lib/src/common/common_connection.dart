import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:atmos_logger/atmos_logger.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';
import '../interfaces/i_msg_connection.dart';
import '../messages/messages_decoder.dart';
import '../messages/msg_done.dart';

abstract class CommonMsgConnection implements IMsgConnection {
  Logger get logger;
  int get version;
  Socket get ws;

  @override
  void send(IMsg msg) {
    final data = msg.toBytes;
    logger.debug('sended: ${data.length}');

    final w = BinaryWriter()..writeListUint8(data);
    ws.add(w.takeBytes());
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

  int? msgBuildLength;
  BinaryWriter? msgBuilder;

  void handleDataRaw(Uint8List request) {
    if (msgBuilder == null) {
      final r = BinaryReader(request);
      msgBuildLength = r.readSize();
      if (r.peek < msgBuildLength!) {
        msgBuilder = BinaryWriter()
          ..writeListUint8(request, size: request.length);
        return;
      } else {
        handleData(r.readListUint8(size: msgBuildLength!));
        msgBuildLength = null;
      }
    } else {
      msgBuilder!.writeListUint8(request, size: request.length);
      final l = msgBuilder!.length;
      if (l >= msgBuildLength!) {
        final r = BinaryReader(msgBuilder!.takeBytes());
        msgBuildLength = r.readSize();
        handleData(r.readListUint8(size: msgBuildLength!));
        msgBuildLength = null;
        msgBuilder = null;
      }
    }
  }

  Future<void> handleData(Uint8List request) async {
    logger.debug('recived: ${request.length}');
    final msg = const MessagesDecoder().convert(request);
    logger.debug('WebSocket: New MSG', msg.toString());
    requestsCompleters.remove(msg.id)?.complete(msg);
    streamControllers[msg.id]?.add(msg);
    if (msg is MsgDone) {
      await streamControllers.remove(msg.id)?.close();
    }
  }

  @override
  @mustCallSuper
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
  }
}
