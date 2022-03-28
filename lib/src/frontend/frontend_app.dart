import 'dart:async';
import 'dart:io';

import 'package:atmos_logger/atmos_logger_io.dart';
import 'package:flutter/foundation.dart';
import 'package:yaml/yaml.dart';

import '../database/database_app_client.dart';
import '../interfaces/i_msg_connection.dart';
import '../interfaces/i_router.dart';
import '../routes/router_delegate.dart';
import 'frontend_app_tender_list.dart';
import 'frontend_app_updates_list.dart';
import 'frontend_web_socket_connection.dart';

/// Интерфейс клиентского приложения
class FrontendApp {
  /// Версия приложения
  int get version => 1;

  final db = DatabaseAppClient('frontend.db');

  final Logger logger = LoggerConsole(LoggerFile(File('frontend.log')));
  late final IRouter router = MyRouterDelegate(this);
  final vnThemeModeDark = ValueNotifier(true);
  late String serverAdress;
  late final IMsgConnectionClient connection =
      FrontendWebSocketConnection(this);
  late final updatesList = FrontendAppUpdatesList(this);
  late final tenderList = FrontendAppTenderList(this);

  bool get isOnline => connection.statusCode == ConnectionStatus.connected;

  final _settingFile = File('frontend.settings.yaml');
  late StreamSubscription<FileSystemEvent> _settingFileSS;
  void _onSettingsChanged([FileSystemEvent? event]) {
    if (!_settingFile.existsSync()) {
      throw const FileSystemException('Settings file not found');
    }
    final yaml = loadYamlDocument(
      _settingFile.readAsStringSync(),
    ).contents as YamlMap;

    vnThemeModeDark.value = yaml['theme_mode'] == 'dark';
    serverAdress = yaml['server_adress'] ?? 'example.com';
  }

  Future<void> run(List<String> args) async {
    logger.info('Start');
    await init();
    logger.info('Initialized');
    (router as MyRouterDelegate).handleInitizlizngEnd();
  }

  void onConnected(IMsgConnectionClient connection) {
    if (connection.statusCode == ConnectionStatus.connected) {}
  }

  Future<void> init() async {
    if (!_settingFile.existsSync()) {
      throw const FileSystemException('Settings file not found');
    }
    _settingFileSS = _settingFile.watch().listen(_onSettingsChanged);
    _onSettingsChanged();
    unawaited(connection.reconnect());
    connection.statusUpdates.listen(onConnected);
  }

  Future<void> dispose() async {
    await _settingFileSS.cancel();
    connection.dispose();
    await (connection as FrontendWebSocketConnection).sc.close();
    vnThemeModeDark.dispose();
    (router as MyRouterDelegate).dispose();
    db.dispose();
    logger.info('Disposed');
  }
}
