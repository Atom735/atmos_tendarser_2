import 'dart:async';
import 'dart:io';

import 'package:atmos_logger/atmos_logger_io.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:yaml/yaml.dart';

import '../interfaces/i_router.dart';
import '../routes/router_delegate.dart';
import 'frontend_web_socket_connection.dart';

/// Интерфейс клиентского приложения
class FrontendApp {
  /// Версия приложения
  int get version => 1;

  final db = sqlite3.open('frontend.db')
    ..execute('PRAGMA JOURNAL_MODE=OFF')
    ..execute('PRAGMA SYNCHRONOUS=OFF');

  final Logger logger = LoggerConsole(LoggerFile(File('frontend.log')));
  late final IRouter router = MyRouterDelegate(this);
  final vnThemeModeDark = ValueNotifier(true);
  late String serverAdress;
  late final FrontendWebSocketConnection connection =
      FrontendWebSocketConnection(this);

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

  Future<void> init() async {
    if (!_settingFile.existsSync()) {
      throw const FileSystemException('Settings file not found');
    }
    _settingFileSS = _settingFile.watch().listen(_onSettingsChanged);
    _onSettingsChanged();
    unawaited(connection.reconnect());
  }

  Future<void> dispose() async {
    await _settingFileSS.cancel();
    connection.close();
    vnThemeModeDark.dispose();
    (router as MyRouterDelegate).dispose();
    logger.info('Disposed');
  }
}
