import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

import '../common/common_connection.dart';
import '../interfaces/i_msg_connection.dart';
import '../messages/msg_handshake.dart';

class FrontendMsgConnection extends CommonMsgConnection
    implements IMsgConnectionClient {
  FrontendMsgConnection(this.version);

  @override
  late String remoteAdress;

  @override
  late int remotePort;

  @override
  final Logger logger = Logger('Connection');

  @override
  late Socket ws;

  final int version;

  int remoteVersion = 1;

  @override
  ConnectionStatus statusCode = ConnectionStatus.unconnected;
  @override
  String statusMsg = '';
  @override
  Stream<FrontendMsgConnection> get statusUpdates => sc.stream;

  final sc = StreamController<FrontendMsgConnection>.broadcast(sync: true);

  void _status(ConnectionStatus code, [String message = '']) {
    statusCode = code;
    statusMsg = message;
    sc.add(this);
  }

  int _id = 1;

  @override
  int get mewMsgId => _id += 2;

  @override
  Future<void> reconnect([String? adress, int? port]) async {
    try {
      if (statusCode == ConnectionStatus.connected) {
        close();
      }
      remoteAdress = adress ?? remoteAdress;
      remotePort = port ?? remotePort;
      logger.info('reconnect');
      _status(ConnectionStatus.connecting);
      ws = await Socket.connect(remoteAdress, remotePort);
      logger.info('connected');
      ws.listen(handleDataRaw, onDone: handleDone, onError: handleError);
      final respMsg = await request(MsgHandshake(mewMsgId, version));
      if (respMsg is! MsgHandshake) {
        throw Exception('Unknown message responsed from handshake');
      }
      remoteVersion = respMsg.version;
      logger.info('handshaked');
      _status(ConnectionStatus.connected);
    } on Object catch (e) {
      logger.severe('erorr while connecting', e);
      _status(
        ConnectionStatus.error,
        'Оишбка при подключении:\n$e',
      );
    }
  }

  void handleDone() {
    logger.info('done');
    _status(ConnectionStatus.unconnected);
    close();
  }

  void handleError(Object? e) {
    logger.severe('error', e);
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
