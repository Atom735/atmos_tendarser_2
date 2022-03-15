import 'dart:async';
import 'dart:io';

import 'package:stream_channel/stream_channel.dart';

import 'frontend_app.dart';

class FrontendWebSocketConnection {
  FrontendWebSocketConnection(this.app);

  final FrontendApp app;
  String get serverAdress => app.serverAdress;
  WebSocket? _socket;
  FrontendWebSocketConnectionStatus statusCode =
      FrontendWebSocketConnectionStatus.unconnected;
  String statusMsg = '';

  final _sc =
      StreamController<FrontendWebSocketConnection>.broadcast(sync: true);

  Stream<FrontendWebSocketConnection> get updates => _sc.stream;

  void _status(FrontendWebSocketConnectionStatus code, [String message = '']) {
    statusCode = code;
    statusMsg = message;
    _sc.add(this);
  }

  Future<void> reconnect() async {
    try {
      _status(FrontendWebSocketConnectionStatus.connecting);
      _socket = await WebSocket.connect('ws://$serverAdress');
      _socket!.listen(_handleData, onDone: _handleDone, onError: _handleError);
      _status(FrontendWebSocketConnectionStatus.connected);
    } on Object catch (e) {
      _status(
        FrontendWebSocketConnectionStatus.error,
        'Оишбка при подключении:\n$e',
      );
    }
  }

  Future<void> _handleData(Object? request) async {}
  void _handleDone() => _status(FrontendWebSocketConnectionStatus.unconnected);

  void _handleError(Object? e) {
    _status(
      FrontendWebSocketConnectionStatus.error,
      'Ошибка внутри сокета:\n$e',
    );
  }

  void close() {
    _sc.close();
    _socket?.close(0, 'OK');
  }
}

enum FrontendWebSocketConnectionStatus {
  unconnected,
  connecting,
  connected,
  error,
}
