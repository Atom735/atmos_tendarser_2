import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:atmos_binary_buffer/atmos_binary_buffer.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../interfaces/i_msg.dart';
import '../interfaces/i_msg_connection.dart';
import '../messages/messages_decoder.dart';
import '../messages/msg_done.dart';

const kServerPortDefault = 49735;

abstract class CommonMsgConnection implements IMsgConnection {
  Logger? get logger;
  Socket get ws;

  @override
  void send(IMsg msg) {
    final data = msg.write(BinaryWriter()).takeBytes();
    final length = data.length;
    logger?.fine('sended: $length');
    ws.add((BinaryWriter()
          ..writeSize(length)
          ..writeListUint8(data))
        .takeBytes());
  }

  @override
  Future<IMsg> request(IMsg msg) {
    logger?.finer('request: ${msg.id}');
    final completer = Completer<IMsg>.sync();
    requestsCompleters[msg.id] = completer;
    send(msg);
    return completer.future;
  }

  final requestsCompleters = <int, Completer<IMsg>>{};

  @override
  Stream<IMsg> openStream(IMsg msg) {
    logger?.finer('openStream: ${msg.id}');
    // ignore: close_sinks
    final controller = StreamController<IMsg>(sync: true);
    streamControllers[msg.id] = controller;
    send(msg);
    return controller.stream;
  }

  final streamControllers = <int, StreamController<IMsg>>{};

  int? _msgBuildLength;
  BinaryWriter? _msgBuilder;

  void handleDataRaw(Uint8List request) {
    if (_msgBuilder == null) {
      final r = BinaryReader(request);
      _msgBuildLength = r.readSize();
      if (r.peek < _msgBuildLength!) {
        _msgBuilder = BinaryWriter()
          ..writeListUint8(request.sublist(r.offset),
              size: request.length - r.offset);
        return;
      } else {
        handleData(r.readListUint8(size: _msgBuildLength!));
        _msgBuildLength = null;
      }
    } else {
      _msgBuilder!.writeListUint8(request, size: request.length);
      final l = _msgBuilder!.length;
      if (l >= _msgBuildLength!) {
        final r = BinaryReader(_msgBuilder!.takeBytes());
        _msgBuildLength = r.readSize();
        handleData(r.readListUint8(size: _msgBuildLength!));
        _msgBuildLength = null;
        _msgBuilder = null;
      }
    }
  }

  Future<void> handleData(Uint8List request) async {
    logger?.fine('recived: ${request.length}');
    final msg = const MessagesDecoder().convert(request);
    logger?.fine('new msg', msg.toString());
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

  @override
  String toString() => 'Connection[${hashCode.toRadixString(16)}]';
}
