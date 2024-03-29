import 'dart:async';

import 'i_msg.dart';

abstract class IMsgConnection {
  /// For implement only
  IMsgConnection._();

  /// Генератор айди для новых сообщений (чётные у сервеа, нечётные у клиента)
  int get mewMsgId;

  /// Отправляет сообщение в одну сторону
  void send(IMsg msg);

  /// Отправляет сообщение и ждёт ответ на него
  Future<IMsg> request(IMsg msg);

  /// Отправляет запрос на открытие стрима
  Stream<IMsg> openStream(IMsg msg);

  void close();
}

abstract class IMsgConnectionClient implements IMsgConnection {
  /// For implement only
  IMsgConnectionClient._();

  /// Адресс подключения
  String get remoteAdress;

  /// Порт подключения
  int get remotePort;

  /// Состояние подключения код состояния
  ConnectionStatus get statusCode;

  /// Состояние подключения доп сообщение
  String get statusMsg;

  /// Стрим обновлений статуса подключений
  Stream<IMsgConnectionClient> get statusUpdates;

  /// Переподключение (Вернётся успешно только когда подклюились)
  Future<void> reconnect([String? adress, int? port]);

  void dispose();
}

/// Код состояния подключения
enum ConnectionStatus {
  /// Неподключен
  unconnected,

  /// В процессе подключения
  connecting,

  /// Подключён (Произошёл Handshake)
  connected,

  /// Ошибка во время подключения
  error,
}
