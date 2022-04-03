import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import '../database/database_app_client.dart';
import '../interfaces/i_msg_connection.dart';
import '../interfaces/i_router.dart';
import '../routes/router_delegate.dart';
import 'frontend_app_logger.dart';
import 'frontend_app_settings.dart';
import 'frontend_app_tender_list.dart';
import 'frontend_app_updates_list.dart';
import 'frontend_connection.dart';

/// Интерфейс клиентского приложения
class FrontendApp {
  FrontendApp() {}

  /// Версия приложения
  int get version => 1;

  final db = DatabaseAppClient('frontend.db');
  final settings = FrontendAppSettings();
  late final IMsgConnectionClient connection = FrontendMsgConnection();
  late final IRouter router = MyRouterDelegate(this);
  final Logger logger = Logger('app');

  bool get isOnline => connection.statusCode == ConnectionStatus.connected;

  void run(List<String> args) {
    frontendAppLoggerAttach();
    logger.info('Start');
    connection.statusUpdates.listen(onConnected);
    connection.reconnect(
      settings.vnServerAdress.value,
      settings.vnServerPort.value,
    );
    logger.info('Initialized');
    (router as MyRouterDelegate).handleInitizlizngEnd();
  }

  void onConnected(IMsgConnectionClient connection) {
    if (connection.statusCode == ConnectionStatus.connected) {}
  }

  Future<void> dispose() async {
    settings.dispose();
    connection.dispose();
    (router as MyRouterDelegate).dispose();
    db.dispose();
    logger.info('Disposed');
    frontendAppLoggerClose();
  }
}
