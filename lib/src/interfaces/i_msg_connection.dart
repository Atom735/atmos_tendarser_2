import 'i_msg.dart';

abstract class IMsgConnection {
  IMsgConnection._();

  String get adress;
  ConnectionStatus get statusCode;
  String get statusMsg;
  Stream<IMsgConnection> get statusUpdates;

  Future<void> reconnect();

  void send(IMsg msg);

  Future<IMsg> request(IMsg msg);

  Stream<IMsg> openStream(IMsg msg);

  void close();

  int get msgId;
}

enum ConnectionStatus {
  unconnected,
  connecting,
  connected,
  error,
}
